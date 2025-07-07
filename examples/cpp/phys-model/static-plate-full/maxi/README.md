> Note: prices are for the FPGA chips, not the development boards

- **xc7z010clg400** (Zynq-7000 SoC family)
  - Development board: *Digilent Zybo Z7-10*
  - price ~= 75 € (mouser)
- **xc7z020clg400**-1 (Zynq-7000 SoC family)
  - Development board: *Digilent Zybo Z7-20*	
  - price ~= 150 € (mouser)
- **xc7z035ffg676-1** (Zynq-7000 SoC family)
  - price ~= 2,500 € (mouser)
- **xc7z100ffg900-1** (Zynq-7000 SoC family)
  - price ~= 3,500 € (mouser) 
- **xczu3eg-sfvc784-1-e** (MPSoC UltraScale+ family)
  - Development board: *Digilent Genesys ZU-3EG*
  - price ~= 525 € (mouser)
- **xczu15eg-ffvb1156-1-e** (MPSoC UltraScale+ family)
  - price ~= 6,500 € (mouser)
- **xczu19eg-ffvc1760-1-e** (MPSoC UltraScale+ family)
  - price ~= 6,200 € (mouser)

#### Resource map

| Board                   | DSP      | FF          | LUT        | BRAM     | URAM    |
| ----------------------- | -------- | ----------- | ---------- | -------- | ------- |
| *xc7z010clg400-1*       | 80       | 35200       | 17600      | 120      | 0       |
| *xc7z020clg400-1*       | 220      | 106400      | 53200      | 280      | 0       |
| *xc7z035ffg676-1*       | 900      | 343800      | 171900     | 1000     | 0       |
| *xc7z100ffg900-1*       | 2020     | 554800      | 277400     | 1510     | 0       |
| *xczu3eg-sfvc784-1-e*   | 320      | 141120      | 70560      | 432      | 0       |
| *xczu15eg-ffvb1156-1-e* | **3528** | 682560      | 341280     | 1488     | 112     |
| *xczu19eg-ffvc1760-1-e* | 1968     | **1045440** | **522720** | **1968** | **128** |

### Implementation details & observations:

- All experiments have been conducted with Vitis HLS **2024.1** 

- The implementation DSP algorithm **must fit on the FPGA**, in terms of logic resource utilization, otherwise it wouldn't compile and run at all, not even in a *non real-time* mode. 
- On the other hand, if the implementation stays below logic resources saturation and the latency per-sample goes above 100%, this would be considered as *non real-time* (offline). 
- Estimate reports do not guarantee that the implementation will eventually fit on the FPGA, especially if resource utilization is getting close to saturation. 
- In our case, buffer sizes can be arbitrary: they don't necessarily need to be *power-of-two*, they can significantly impact logic resource utilization, and consequently throughput.
- `x[nmodes]`, `x_prev[nmodes]`,  and`x_next[nmodes]` arrays are stored in the programmable logic (PL). 
- `c1[nmodes]`, `c2[nmodes]`, `c3[nmodes]` and `modes_out[nmodes]` arrays are stored in **DDR memory**, in an **interleaved** way. They are retrieved with a *burst request* for each *mode* iteration, somewhat limiting the impact on latency.  There are no other read/write accesses to DDR memory.
- DSP computation loops are in our case "***inverted***", which has a significantly positive impact on overall performance:

```cpp
int c = 0;
for (int m = 0 ; m < modesNumber; m++) {
#pragma HLS pipeline II=1
    float c1 = coeffs[c++];
    float c2 = coeffs[c++];
    float c3 = coeffs[c++];
    float modes_out = coeffs[c++];
    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
    #pragma HLS unroll
        x_next[m] = c1 * x[m]
                  + c2 * x_prev[m]
                  + c3 * input[n];
        x_prev[m] = x[m];
        x[m] = x_next[m];
        output[n] += x_next[m] * modes_out;
    }
} 
```

### real-time implementations:

| Board                 | Source                                | Number of modes | Buffer size | Buffer latency | Latency per sample     | DSP Latency total            | DSP         | FF           | LUT          | BRAM       |
| --------------------- | ------------------------------------- | --------------- | ----------- | -------------- | ---------------------- | ---------------------------- | ----------- | ------------ | ------------ | ---------- |
| xc7z010clg400-1       | Implementation report                 | 12,000          | 24          | 0,5 ms         | 2518 cycles (**98%**)  | 60,448 cycles (0.492 ms)     | 68% (55)    | 51% (18011)  | 62% (10999)  | 67% (81)   |
| xc7z020clg400-1       | Implementation report                 | 30,000          | 64          | 1,33 ms        | 2360 cycles (**92%**)  | 151,040 cycles (1.229 ms)    | 65%   (143) | 40% (42896)  | 50% (26309)  | 52% (145)  |
| xczu3eg-sfvc784-1-e   | Estimate report (crash at synth/impl) | 45,000          | 80          | 1,66 ms        | 2264 cycles (**88%**)  | 181156 cycles (1.474 ms)     | 88% (320)   | 44% (63364)  | 70% (49494)  | 45% (197)  |
| xc7z035ffg676-1       | Estimate report                       | 120,000         | 384         |                | 2516 cycles (**98%**)  | 966227 cycles (7.863 ms)     | 59% (534)   | 41% (141037) | 88% (152720) | 54% (541)  |
| xc7z100ffg900-1       | Estimate report                       | 200,000         | 600         |                | 2348 cycles (**91%**)  | 1,409,085 cycles (12.941 ms) | 47% (956)   | 39% (220141) | 91% (253801) | 69% (1053) |
| xczu15eg-ffvb1156-1-e | Estimate report                       | 300,000         | 768         | ...            | 2747 cycles (**107%**) | 2110062 cycles (17.172 ms)   | 34% (1211)  | 42% (290224) | 68% (234023) | 73% (1101) |
| xczu19eg-ffvc1760-1-e | Estimate report                       | **400,000**     | 1024        | ...            | 2356 cycles (**92%**)  | 2413380 (19.640 ms)          | 95% (1881)  | 35% (374592) | 64% (339599) | 73% (1453) |

> **Note:** HLS for xczu15eg with 300,000 modes took more than 50 hours T_T, and since I didn't really want to do a second HLS run in order to make the latency go below 100%, it will stay like this for now... 

### TODOs:

- [ ] Further optimization should be tried in order to **improve DDR access latency**, e.g.: retrieving more coefficients in a single *burst request*, which would require reorganizing the code to add another loop level, maybe also store `x[], x_next[], x_prev[]` arrays on DDR, etc.
- [ ] Re-do implementation report with Genesys ZU3EG (crash due to lack of RAM)
- [ ] Implementation reports for Z35, Z100, 15EG and 19EG FPGAs (requires licensing, but we could use the one-month trial for this...).
- [ ] Use the DSP IP from the ARM as an *hardware accelerator*?
- [ ] Implementation on large FPGAs, such as the ZU19EG, or the Z7-100 could maybe have the coefficients stored in the programmable logic (URAM?), potentially leading to completely different results.
