#include <syfala/utilities.hpp>

#define INPUTS  2
#define OUTPUTS 2
#define SLOW_CLOCK_DIVIDER 2
#define MCLK_SCLK_RATIO 4
#define SCLK_WS_RATIO 64

/**
 * @brief transceiver
 * @param mclk
 * @param sclk
 * @param ws
 * @param to_dsp_start
 * @param from_ssm_sd
 * @param to_ssm_sd
 * @param from_dsp
 * @param from_dsp_vld
 * @param to_dsp
 */
void transceiver (
         bool mclk,
        bool* sclk,
        bool* ws,
        bool* to_dsp_start,
         bool from_ssm_sd,
        bool* to_ssm_sd,
        sy_ap_int from_dsp[2],
         bool from_dsp_vld[2],
        sy_ap_int to_dsp[2]
) {
#pragma HLS array_partition variable=from_dsp type=complete
#pragma HLS array_partition variable=to_dsp type=complete
    // ------------------------------------------------------------------------
    // Dataflow
    // ------------------------------------------------------------------------
    static bool sclk_int, ws_int;
    *sclk = sclk_int;
    *ws   = ws_int;
    // ------------------------------------------------------------------------
    // sys_clk_event
    // ------------------------------------------------------------------------
    // 1. Fetch incoming data from the DSP kernel, latch it until we get new
    // 'valid' values, store data in 'from_dsp_latched'.
    static sy_ap_int from_dsp_latched[2];
    static bool from_dsp_vld_reg[2];

    for (int n = 0; n < 2; ++n) {
        from_dsp_vld_reg[n] = from_dsp_vld[n];
        if (from_dsp_vld[n]) {
            from_dsp_latched[n] = from_dsp[n];
        }
    }
    // ------------------------------------------------------------------------
    // 2. If we get a new 'dsp_rdy' signal, send the 'ap_start' signal to
    // the DSP kernel.
    // ------------------------------------------------------------------------
    static bool dsp_rdy;
    static bool dsp_rdy_reg;

    dsp_rdy_reg = dsp_rdy;
    if (dsp_rdy && (dsp_rdy != dsp_rdy_reg)) {
        *to_dsp_start = 1;
    } else {
        *to_dsp_start = 0;
    }
    // ------------------------------------------------------------------------
    // mclk events
    // ------------------------------------------------------------------------
    if (mclk) {
        // ----------------------------------------------
        // static variables
        // ----------------------------------------------
        static sy_ap_int to_dsp_int[2];
        static sy_ap_int from_dsp_int[2];
        static int clk_div_cnt = 1;
        static int sclk_cnt, bit_cnt, ws_cnt;
        static bool read_sd_at_next_mclk_sample;
        static bool reset_bit_cnt_next_sclk_cycle;
        static bool ws_int_rx, ws_int_tx, sclk_int;
        // ----------------------------------------------
        clk_div_cnt++;

        if (clk_div_cnt == SLOW_CLOCK_DIVIDER) {
            clk_div_cnt = 1;
            // ----------------------------------------------------------------
            // If we still have bits to receive from the codec:
            // read codec's sd port and add it to 'to_dsp_int'.
            // ----------------------------------------------------------------
            if (sclk_cnt < MCLK_SCLK_RATIO/2-1) {
                sclk_cnt++;
                if (read_sd_at_next_mclk_sample) {
                    ap_int<1> b = from_ssm_sd;
                    if (ws_int_rx == 0) {
                        // Compute left channel
                        to_dsp_int[0] = to_dsp_int[0] & b;
                    } else {
                        // Compute right channel
                        to_dsp_int[1] = to_dsp_int[1] & b;
                    }
                    read_sd_at_next_mclk_sample = false;
                }
            } else {
            // ----------------------------------------------------------------
            // Otherwise, reset sclk count to zero,
            // send audio data to the DSP kernel ('to_dsp'),
            // prepare data to be sent as output to the codec.
            // ----------------------------------------------------------------
                sclk_cnt = 0;
                sclk_int = !sclk_int;
                if (sclk_int) {
                    bit_cnt++;
                    if (reset_bit_cnt_next_sclk_cycle) {
                        bit_cnt = 0;
                        reset_bit_cnt_next_sclk_cycle = false;
                    }
                }
                if (ws_cnt < SCLK_WS_RATIO-1) {
                    ws_cnt++;
                } else {
                    if (sclk_int) {
                        ws_cnt = 0;
                        reset_bit_cnt_next_sclk_cycle = true;
                        if (ws_int == 0) {
                            // Left channels
                            to_dsp[0] = to_dsp_int[0];
                            from_dsp_int[0] = from_dsp_latched[0];
                        } else {
                            // Right channels
                            to_dsp[1] = to_dsp_int[1];
                            from_dsp_int[1] = from_dsp_latched[1];
                        }
                        ws_int = !ws_int;
                    }
                }
            }
            // ----------------------------------------------------------------
            // In any case, if sclk is LOW, and we still have bits to send
            // send data to the audio codec bit by bit.
            // ----------------------------------------------------------------
            if (sclk_int == 0) {
                ws_int_tx = ws_int;
                if (bit_cnt < SYFALA_SAMPLE_WIDTH) {
                    read_sd_at_next_mclk_sample = true;
                    if (ws_int_tx == 0) {
                        // Left channels
                        to_ssm_sd = from_dsp_int[0][SYFALA_SAMPLE_WIDTH-1];
                        from_dsp_int[0] = from_dsp_int[0] & 0;
                    } else {
                        // Right channels
                        to_ssm_sd = from_dsp_int[1][SYFALA_SAMPLE_WIDTH-1];
                        from_dsp_int[1] = from_dsp_int[1] & 0;
                    }
                }
            }
            // ----------------------------------------------------------------
            // ??
            // ----------------------------------------------------------------
            if (ws_cnt == 3 && ws_int == 1) {
                dsp_rdy = true;
            } else {
                dsp_rdy = false;
            }
        }
    }
}
