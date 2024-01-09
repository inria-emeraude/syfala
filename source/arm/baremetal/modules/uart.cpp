#include <xuartps.h>
#include <xscugic.h>
#include <syfala/arm/uart.hpp>
#include <syfala/utilities.hpp>
#include <syfala/arm/gpio.hpp>
#include <memory>
#include <atomic>

namespace xuartps {
    using handle                          = XUartPs;
    using config                          = XUartPs_Config;
    constexpr auto lookup_config          = XUartPs_LookupConfig;
    constexpr auto initialize_config      = XUartPs_CfgInitialize;
    constexpr auto set_baud_rate          = XUartPs_SetBaudRate;
    constexpr auto set_handler            = XUartPs_SetHandler;
    constexpr auto send                   = XUartPs_Send;
    constexpr auto receive                = XUartPs_Recv;
    constexpr auto set_receive_timeout    = XUartPs_SetRecvTimeout;
    constexpr auto set_interrupt_mask     = XUartPs_SetInterruptMask;
    constexpr auto interrupt_handler      = XUartPs_InterruptHandler;
    constexpr auto run_self_test          = XUartPs_SelfTest;
    constexpr auto set_data_format        = XUartPs_SetDataFormat;
    constexpr auto set_fifo_threshold     = XUartPs_SetFifoThreshold;
    constexpr auto set_oper_mode          = XUartPs_SetOperMode;
}

namespace xscugic {
    using handle                        = XScuGic;
    using config                        = XScuGic_Config;
    using except_handler                = Xil_ExceptionHandler;
    constexpr auto lookup_config        = XScuGic_LookupConfig;
    constexpr auto initialize_config    = XScuGic_CfgInitialize;
    constexpr auto connect              = XScuGic_Connect;
    constexpr auto enable               = XScuGic_Enable;
    constexpr auto interrupt_handler    = XScuGic_InterruptHandler;
    constexpr auto excreg_handler       = Xil_ExceptionRegisterHandler;
    constexpr auto run_self_test        = XScuGic_SelfTest;
}

using namespace Syfala;
using namespace Syfala::UART;

static xuartps::handle x_uart;
static xscugic::handle x_intc;

/**
 *  The default configuration for the UART after initialization is:
 *  - 9,600 bps or XPAR_DFT_BAUDRATE if defined
 *  - 8 data bits
 *  - 1 stop bit
 *  - no parity
 *  - FIFO's are enabled with a receive threshold of 8 bytes
 *  - The RX timeout is enabled with a timeout of 1 (4 char times)
**/
#define UART_DEVICE_ID  XPAR_XUARTPS_0_DEVICE_ID
#define INTC_DEVICE_ID  XPAR_SCUGIC_0_DEVICE_ID
#define UART_INTR_ID    XPAR_XUARTPS_1_INTR

#define UART_RECEIVE_TIMEOUT  64U

const u32 UART_INTERRUPT_MASK =
      XUARTPS_IXR_TOUT        |
      XUARTPS_IXR_PARITY      |
      XUARTPS_IXR_FRAMING     |
      XUARTPS_IXR_OVER        |
      XUARTPS_IXR_TXEMPTY     |
      XUARTPS_IXR_RXFULL      |
      XUARTPS_IXR_RXEMPTY     |
      XUARTPS_IXR_RXOVR
;

static void interrupt_handler_fn(void* udata, u32 event, u32 event_data) {
    // event: switch case needed
    // data: number of bytes sent/received at the time of the call
    auto d = static_cast<data*>(udata);
    switch (event) {
    case XUARTPS_EVENT_SENT_DATA: {
        /* All of the data has been correctly sent */
        break;
    }
    case XUARTPS_EVENT_RECV_DATA: {
        /* All of the data has been correctly received, continue... */
        xuartps::receive(&x_uart, d->buffer, 8);
        d->nbytes += event_data;
        break;
    }
    case XUARTPS_EVENT_RECV_TOUT: {
        /* Data was received, but not the expected number of bytes, a
         * timeout just indicates the data stopped for 8 character times */
        break;
    }
    case XUARTPS_EVENT_RECV_ERROR: {
      /* Data was received with an error, keep the data but determine
       * what kind of errors occurred */
        break;
    }
    default: {
        break;
    }
    }
}

static void initialize_interrupt_controller(data& d) {
    using namespace xscugic;
    xscugic::config* cfg = xscugic::lookup_config(INTC_DEVICE_ID);
    if (cfg == nullptr) {
        Status::fatal(RN("[uart] ERROR: Couldn't find XSCUGIC configuration"));
    }
    if (xscugic::initialize_config(&x_intc, cfg, cfg->CpuBaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("[uart] ERROR: Couldn't initialize XSCUGIC configuration"));
    }
    if (xscugic::run_self_test(&x_intc) != XST_SUCCESS) {
        Status::fatal(RN("[uart] ERROR: XSCUGIC self test failed"));
    }
    /* Connect the interrupt controller interrupt handler to the
     * hardware interrupt handling logic in the processor */
    Xil_ExceptionInit();
    xscugic::excreg_handler(XIL_EXCEPTION_ID_INT, (except_handler) interrupt_handler, &x_intc);
    /* Connect a device driver handler that will be called when an
     * interrupt for the device occurs, the device driver handler
     * performs the specific interrupt processing for the device */
    if (xscugic::connect(&x_intc, UART_INTR_ID,
            (Xil_ExceptionHandler) xuartps::interrupt_handler, &x_uart) != XST_SUCCESS) {
        Status::fatal(RN("[uart] ERROR: could not connect interrupt_handler"));
    }
    /* Enable the interrupt for the device */
    xscugic::enable(&x_intc, UART_INTR_ID);
    Xil_ExceptionEnable();
    xuartps::receive(&x_uart, d.buffer, 8);
    sy_printf("[uart] Interrupt controller successfully initialized.");
}

/** Initialize the UART driver so that it's ready to use
  * Look up the configuration in the config table and then initialize it. */
void UART::initialize(UART::data& d) {
    using namespace xuartps;
    XUartPsFormat fmt = {
        .BaudRate = SYFALA_UART_BAUD_RATE,
        .DataBits = XUARTPS_FORMAT_8_BITS,
        .Parity   = XUARTPS_FORMAT_NO_PARITY,
        .StopBits = XUARTPS_FORMAT_1_STOP_BIT
    };
    xuartps::config* cfg = xuartps::lookup_config(UART_DEVICE_ID);
    if (cfg == nullptr) {
        Status::fatal(RN("[uart] ERROR: couldn't find XUARTPS configuration"));
    }
    if (xuartps::initialize_config(&x_uart, cfg, cfg->BaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("[uart] ERROR: couldn't initialize XUARTPS configuration"));
    }
    if (xuartps::run_self_test(&x_uart) != XST_SUCCESS) {
        Status::fatal(RN("[uart] ERROR: XUARTPS self-test failed"));
    }
    initialize_interrupt_controller(d);
    xuartps::set_handler(&x_uart, interrupt_handler_fn, &d);
    xuartps::set_interrupt_mask(&x_uart, UART_INTERRUPT_MASK);
    xuartps::set_data_format(&x_uart, &fmt);
    xuartps::set_fifo_threshold(&x_uart, 8);
    xuartps::set_receive_timeout(&x_uart, 4);
    xuartps::set_oper_mode(&x_uart, XUARTPS_OPER_MODE_NORMAL);
    // Do we need this? unclear...
//    XUartPs_EnableUart(&x_uart);
    sy_printf("[uart] XUARTPS successfully initialized.");
}

void UART::send(data& d, Message& m) {
    byte_t* data = reinterpret_cast<byte_t*>(&m);
    xuartps::send(&x_uart, data, sizeof(Message));
}

Result<Message> UART::poll(data& d) {
    Result<Message> r;
    // Poll UART device, increment write index.
    if (d.nbytes >= sizeof(Message)) {
        r.data = *reinterpret_cast<Message*>(d.buffer);
        r.valid = true;
        d.nbytes -= sizeof(Message);
    }
    return r;
}
