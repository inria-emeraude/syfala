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

#define UART_RECEIVE_TIMEOUT  255U

using namespace Syfala;

const u32 UART_INTERRUPT_MASK =
      XUARTPS_IXR_TOUT        |
      XUARTPS_IXR_PARITY      |
      XUARTPS_IXR_FRAMING     |
      XUARTPS_IXR_OVER        |
      XUARTPS_IXR_TXEMPTY     |
      XUARTPS_IXR_RXFULL      |
      XUARTPS_IXR_RXOVR
;

static void interrupt_handler_fn(void* udata, u32 event, u32 nbytes) {
    // event: switch case needed
    // data: number of bytes sent/received at the time of the call
    auto d = static_cast<UART::data*>(udata);
    switch (event) {
    case XUARTPS_EVENT_SENT_DATA: {
        /* All of the data has been correctly sent */
        break;
    }
    case XUARTPS_EVENT_RECV_DATA: {
        /* All of the data has been correctly received */
        d->w = d->w + nbytes;
        break;
    }
    case XUARTPS_EVENT_RECV_TOUT: {
        /* Data was received, but not the expected number of bytes, a
         * timeout just indicates the data stopped for 8 character times */
        d->w = d->w + nbytes;
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

static void initialize_interrupt_controller(UART::data& d) {
    using namespace xscugic;
    config* c = lookup_config(INTC_DEVICE_ID);
    if (c == nullptr) {
        Status::fatal(RN("ERROR: Couldn't find XSCUGIC configuration"));
    }
    if (initialize_config(&x_intc, c, c->CpuBaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: Couldn't initialize XSCUGIC configuration"));
    }
    if (run_self_test(&x_intc) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: XSCUGIC self test failed"));
    }
    /* Connect the interrupt controller interrupt handler to the
     * hardware interrupt handling logic in the processor */
    Xil_ExceptionInit();
    excreg_handler(XIL_EXCEPTION_ID_INT, (except_handler) interrupt_handler, &x_intc);
    /* Connect a device driver handler that will be called when an
     * interrupt for the device occurs, the device driver handler
     * performs the specific interrupt processing for the device */
   if (connect(&x_intc, UART_INTR_ID, (except_handler) xuartps::interrupt_handler, &x_uart) != XST_SUCCESS) {
       Status::fatal(RN("ERROR: could not connect interrupt_handler"));
   }
    /* Enable the interrupt for the device */
    Xil_ExceptionEnable();
    enable(&x_intc, UART_INTR_ID);
    sy_printf("Interrupt controller successfully initialized.");
}

/** Initialize the UART driver so that it's ready to use
  * Look up the configuration in the config table and then initialize it. */
void UART::initialize(UART::data& d) {
    using namespace xuartps;
    config* c = lookup_config(UART_DEVICE_ID);
    if (c == nullptr) {
        Status::fatal(RN("ERROR: couldn't find XUARTPS configuration"));
    }
    if (initialize_config(&x_uart, c, c->BaseAddress) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: couldn't initialize XUARTPS configuration"));
    }
    if (set_baud_rate(&x_uart, SYFALA_UART_BAUD_RATE) != XST_SUCCESS) {
        // note (Pierre): this is pretty much useless, since its already
        // specified as the default baud rate when xuartps header is generated
        Status::fatal(RN("ERROR: couldn't set specified baud rate"));
    }
    if (run_self_test(&x_uart) != XST_SUCCESS) {
        Status::fatal(RN("ERROR: XUARTPS self-test failed"));
    }
//    initialize_interrupt_controller(d, g);
//    set_handler(&d.x_uart, interrupt_handler_fn, &d);
//    set_interrupt_mask(&d.x_uart, UART_INTERRUPT_MASK);
    set_receive_timeout(&x_uart, UART_RECEIVE_TIMEOUT);
    sy_printf("XUARTPS successfully initialized.");
}

void UART::send(UART::data& d, UART::Message& m) {
    byte_t* data = reinterpret_cast<byte_t*>(&m);
    xuartps::send(&x_uart, data, sizeof(UART::Message));
}

Result<UART::Message> UART::poll(UART::data& d) {
    Result<UART::Message> r;
    if (d.w >= UART_RW_BUFFER_LEN) {
        sy_printf("UART r/w buffer saturated, ignoring message");
    } else if (d.r >= UART_RW_BUFFER_LEN) {
        sy_printf("UART read index out of bounds, ignoring message");
    } else {
        d.w += xuartps::receive(&x_uart, &d.buffer[d.r], UART_RECEIVE_TIMEOUT);
        if (d.w >= sizeof(UART::Message)) {
            r.data = *reinterpret_cast<UART::Message*>(&d.buffer[d.r]);
            r.valid = true;
            memset(&d.buffer[d.r], 0, sizeof(UART::Message));
            // update r/w indexes
            d.w  -= sizeof(UART::Message);
            d.r  += sizeof(UART::Message);
        }
        if (d.w == 0) {
            d.r = 0;
        }
    }
//    sy_printf("[UART] write: %d, read: %d", d.w, d.r);
    return r;
}
