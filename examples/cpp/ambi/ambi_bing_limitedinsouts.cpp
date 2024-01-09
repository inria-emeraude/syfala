#include <syfala/utilities.hpp>
#include <cmath>

/**
 * /!\ These macros are always required when writing a
 * Syfala C++ program: it will inform the toolchain to use:
 * - audio_in_# (here audio_in_0 and audio_in_1)
 * - audio_out_# (here audio_out_0 and audio_out_1)
 * as audio input and output ports.
 */
#define INPUTS 24
#define OUTPUTS 24

#define NFC1_NMAX 3
#define NFC2_NMAX 5
#define NFC3_NMAX 7
#define NFC4_NMAX 8

static int nbands = 2; // bands
static int decoder_type = 2; // decoder type

static float xover_freq = 400; // crossover frequency in Hz (typically 200-800)
static float lfhf_ratio = 1; // lfhf_balance (typically -+3db but here linear)
static float output_gain = 1; // in dB in original code

static int decoder_order = 4;
static int co[INPUTS] = {0,1,1,1,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4}; // ambisonic order of each input component
static int input_full_set = 1; // use full or reduced input set
static int delay_comp = 1; // delay compensation
static int level_comp = 1; // level compensation
static int nfc_output = 0; // nfc on input or output
static int nfc_input  = 1; // nfc on input or output
static int output_gain_muting = 1; // enable output gain and muting controls
static int ns = OUTPUTS; // number of speakers
static int rs[OUTPUTS] = {5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5}; // radius for each speaker in meters
static float gammas[2][5] = {{1.0f,1.0f,1.0f,1.0f,1.0f},{1.0f,0.9061798459f,0.7317428698f,0.501031171f,0.2457354591f}}; // per order gains, 0 for LF, 1 for HF. Used to implement shelf filters, or to modify velocity matrix for max_rE decoding, and so forth.  See Appendix A of BLaH6.
static float s[24][24] = {{0.0403578957f,0.0315384486f,-0.0212539094f,0.0993972251f,0.0602671588f,-0.0107090211f,-0.0955647382f,-0.0368906951f,0.1038839993f,0.1454646561f,-0.0004433695f,-0.0279028591f,0.0531305524f,-0.1145917801f,-0.0316362958f,0.1657387784f,0.1269482632f,-0.09272844f,-0.0542491425f,0.0355563333f,0.0731720004f,-0.1325209504f,-0.1171055601f,0.1233042411f},
    {0.0403148765f,-0.0224828018f,-0.0210740023f,0.0946525218f,-0.0516281113f,0.0078986142f,-0.0951682623f,-0.0394528856f,0.0978439012f,-0.1430799117f,-0.0009609038f,0.0227523702f,0.0532215977f,-0.1152810099f,-0.0301968023f,0.1663226096f,-0.1357056283f,0.1114426936f,0.0448397644f,-0.0199217489f,0.0685762295f,-0.1253066259f,-0.1376755671f,0.1449530886f},
    {0.0354981675f,  0.0595247373f, -0.0281628385f,  0.0748737053f,  0.0930635516f, -0.0227952918f, -0.0727667572f, -0.0244028061f, -0.0064378448f,  0.1377995786f, -0.0072293288f, -0.0590311425f,  0.1102676979f, -0.0555191473f,  0.0088306704f, -0.1513629092f,  0.0169691474f, -0.1143275611f, -0.0917420251f,  0.0621023246f,  0.1043901031f,  0.0166437674f,  0.1347045988f, -0.2395360875f},
    {0.038921315f, -0.0754705681f, -0.0294308499f,  0.0764397889f, -0.1077615862f,  0.0335495833f,  -0.077478807f, -0.0266461699f, -0.0081961257f, -0.1265714345f,  0.0077851213f,   0.077308326f,  0.1208005165f, -0.0596631867f,  0.0130698163f, -0.1630666042f,  0.0094330399f,  0.0655970953f,  0.1055176293f, -0.0862165007f,  0.1049774357f,  0.0234320331f,   0.141297168f, -0.2446028751f},
    {0.0552916785f,  0.1010604845f, -0.0075794534f,  0.0307551409f,   0.056290039f, -0.0519828959f, -0.0623029578f, -0.0082903368f, -0.0870207443f, -0.1422802095f, -0.0075271433f, -0.1133283373f,  0.1530985659f, -0.0113174807f,  0.0366000216f, -0.1689243862f, -0.1340950589f,  0.1246970072f,    -0.0593328f,  0.1166451102f,  0.0601104025f,  0.1234031747f,  0.1308260478f,  0.1083235394f},
    {0.0586297517f, -0.1034071228f, -0.0053615142f,  0.0312380172f, -0.0519358183f,  0.0493857505f, -0.0614813056f, -0.0066938658f, -0.0880104325f,  0.1433594268f,  0.0101016601f,   0.109966862f,  0.1628325442f, -0.0122914086f,  0.0401795632f, -0.1681418099f,  0.1270229239f,  -0.101332585f,  0.0585881377f, -0.1214552274f,  0.0551148252f,  0.1286887369f,  0.1473182539f,  0.1093934726f},
    {0.0615297076f,  0.1062940485f, -0.0076083366f, -0.0322469053f, -0.0549530681f, -0.0560884627f, -0.0685660135f,  0.0099674219f, -0.0868279114f, -0.1503167609f,  0.0102583374f, -0.1215555014f,  0.1689407314f,  0.0120233347f,  0.0411805803f,  0.1766688158f,  0.1306216404f,  0.1347693713f,  0.0614678944f,   0.121608944f, -0.0658880893f,  0.1288506713f, -0.1391980187f,  0.1117227331f},
    {0.0523764808f, -0.0911967507f, -0.0061004246f,  -0.028963164f,  0.0516413213f,  0.0435343719f, -0.0577174925f,  0.0056725615f, -0.0771455081f,  0.1280042858f, -0.0069370772f,  0.0970173818f,  0.1439240686f,  0.0067143949f,  0.0312898712f,  0.1683878726f, -0.1344825778f, -0.0937177297f,   -0.05447124f, -0.1070286976f, -0.0588224685f,  0.1079796325f, -0.1485599593f,   0.107908098f},
    {0.0368462725f,  0.0645878515f, -0.0282351772f, -0.0824314042f, -0.1051708795f, -0.0248662293f,   -0.07474732f,  0.0246061819f, -0.0009704058f,  0.1549750146f,  0.0066033536f, -0.0648476283f,  0.1124312837f,  0.0626181653f,  0.0086451272f,  0.1325254939f, -0.0183108197f, -0.1286595967f,  0.1017694458f,  0.0660981659f, -0.1067284856f,  0.0114848302f, -0.1149872169f, -0.2427509879f},
    {0.0363072768f, -0.0697690589f, -0.0290646006f, -0.0796253119f,  0.1012049577f,  0.0299896936f, -0.0744870685f,  0.0258803403f, -0.0074642851f, -0.1224519081f, -0.0085982705f,  0.0703879892f,  0.1136777164f,  0.0632596772f,  0.0094767221f,  0.1532656036f,  0.0006670064f,  0.0634946694f, -0.1006648795f, -0.0792207219f, -0.1026854635f,  0.0183623986f, -0.1292048433f, -0.2363477427f},
    {0.0379071701f,  0.0276783123f, -0.0196996512f,  -0.093259108f, -0.0506920227f,  -0.007880048f, -0.0908463996f,  0.0359708837f,  0.0996130991f,  0.1318376692f, -0.0010970235f, -0.0223888216f,  0.0463178684f,  0.1089320231f,  -0.031904047f, -0.1537268594f, -0.1271766587f, -0.0859408225f,  0.0438397442f,  0.0314878991f, -0.0692292206f, -0.1289975026f,  0.1060322633f,  0.1398899854f},
    {0.0417779467f, -0.0295446806f,  -0.022445452f, -0.0910652993f,  0.0599926792f,  0.0104522595f, -0.0973940464f,  0.0404057842f,  0.0950326852f, -0.1567410619f, -0.0006181118f,  0.0297068159f,  0.0604120223f,  0.1147150463f, -0.0270105291f, -0.1577462465f,  0.1387243207f,  0.1232540918f,  -0.054217366f, -0.0270333337f, -0.0645818582f, -0.1188608104f,  0.1279298571f,  0.1177125025f},
    {0.0079265572f, -0.0076346498f,  0.0638357604f,  0.0345202053f,  0.0510292879f,   0.036713198f,  0.0124666511f,  0.1523729209f,  0.0696551854f, -0.0012009055f,  0.0865778343f, -0.0093296199f, -0.1820956264f,  0.0562001993f,  0.1418383342f, -0.0022521515f,  0.0854917572f,  0.3619122528f,  0.0599749085f, -0.1233859647f, -0.1995693613f,  0.1112449293f,  0.1343354738f, -0.0079292319f},
    {0.0132472349f,  0.0032877966f,  0.0769235915f,  0.0406601205f, -0.0437169792f, -0.0330663471f,  0.0294430835f,   0.167986561f,  0.0805643771f,  0.0010610913f, -0.0729025805f,  0.0026232086f, -0.1664172911f,  0.0665274543f,  0.1585265315f,   0.001920003f, -0.0748572188f, -0.3234978663f, -0.0498351266f,  0.0924205841f, -0.2059028632f,  0.1218859567f,  0.1851843483f,  0.0069753009f},
    {-0.0254937201f,  0.0223458981f,  0.0192789143f, -0.0411051128f,  0.0593882815f,  0.1366373831f, -0.0455554217f,  0.0174854922f, -0.0699194322f,  0.0006441375f,  0.0570428729f,  0.0325956371f, -0.3114198783f, -0.0652582589f, -0.1426876773f,  0.0070103325f, -0.1023697215f, -0.1649726188f,  0.0165520666f, -0.2318652216f, -0.2542087701f, -0.1120489408f, -0.3286976584f,  0.0068062979f},
    {-0.0267078001f, -0.0195377323f,   0.016502809f,  -0.033253366f, -0.0659500579f,  -0.143974553f,  -0.058054578f,  0.0267559219f, -0.0745699611f, -0.0004076035f, -0.0695569789f, -0.0287050429f, -0.3366161962f, -0.0560730856f, -0.1464874507f,  -0.006364484f,  0.0835610443f,  0.1261678148f, -0.0259464384f,  0.2633410338f, -0.2433083467f, -0.1125177135f,  -0.314074868f, -0.0051555317f},
    {-0.0245360446f,  0.0221745879f,  0.0171412522f,  0.0392257848f, -0.0600380509f,  0.1444926965f, -0.0542662322f, -0.0202923576f, -0.0740597221f, -0.0006184015f, -0.0612253803f,  0.0399376356f, -0.3192877238f,   0.062274117f, -0.1450084519f, -0.0066967902f,  0.0979538232f, -0.1545344545f, -0.0210672766f,  -0.237333514f,  0.2515497583f, -0.1111628342f,  0.3186657515f, -0.0065196386f},
    {-0.0294725068f, -0.0150251584f,  0.0184432819f,  0.0371021807f,  0.0639305308f, -0.1412516719f, -0.0542230895f, -0.0250094403f, -0.0691685846f,  0.0003873673f,  0.0625224596f, -0.0277687085f, -0.3486510793f,  0.0624240015f, -0.1406130064f,  0.0065512236f, -0.0843088887f,  0.1384119211f,  0.0191781976f,  0.2677410083f,  0.2593430395f, -0.1101800439f,  0.3125560722f,  0.0051207895f},
    {0.0052053684f, -0.0060912341f,  0.0639572667f, -0.0303589386f, -0.0518195066f,   0.034420546f,  0.0135681416f, -0.1521400364f,  0.0702522665f,  0.0011723785f, -0.0856415888f, -0.0129191954f, -0.1933165022f, -0.0494818755f,  0.1377245136f,  0.0019601552f, -0.0811380023f,  0.3588195737f, -0.0581303357f, -0.1215667487f,  0.2206867552f,  0.1056577848f, -0.1269578636f,  0.0076359284f},
    {0.0163090342f,  0.0001335452f,  0.0766535009f, -0.0468594955f,  0.0472694992f, -0.0338285319f,  0.0295665134f, -0.1671221153f,  0.0772706545f, -0.0010382556f,  0.0835741901f,  0.0030065327f, -0.1499761651f, -0.0767298588f,  0.1567345162f, -0.0021457196f,   0.075847124f, -0.3403928209f,  0.0596671473f,   0.088492658f,   0.170943747f,  0.1226574327f, -0.1806088012f,  -0.006942692f},
    {0.0708549137f,  0.0724886888f,   0.113328654f,  0.0899056532f,  0.0165771427f,  0.0630505899f,   0.140852396f,   0.044508787f, -0.0123550452f,   0.000597219f,  0.0904555697f,  0.1183680742f,  0.2429870889f,  0.1456531225f, -0.0249162267f, -0.0029586711f, -0.0027898311f, -0.0373789293f,  0.0954011681f,  0.2239166178f,  0.3599669376f, -0.0194346909f, -0.0356094329f,  0.0021484902f},
    {0.0667791418f, -0.0684328646f,  0.1091035442f,   0.087880853f, -0.0194604679f, -0.0604872793f,  0.1345616631f,  0.0452547081f, -0.0085938599f, -0.0006100975f, -0.0999469598f, -0.1118228037f,  0.2243330644f,  0.1447586384f,  -0.016975026f,  0.0032270179f,  0.0008577435f,  0.0293372967f, -0.1043920628f, -0.2091707355f,   0.352387955f, -0.0130812942f, -0.0639501938f, -0.0021048127f},
    {0.0716758219f,  0.0702854037f,  0.1161892707f, -0.0925080967f, -0.0164342155f,  0.0622651055f,  0.1442347641f, -0.0462209422f, -0.0092654141f, -0.0005849813f, -0.0898379548f,  0.1147544646f,  0.2439152749f, -0.1499054803f, -0.0182895549f,  0.0029674664f,  0.0020565074f,  -0.036318417f, -0.0947762906f,  0.2142642283f, -0.3693934189f, -0.0140888359f,  0.0353637464f, -0.0020739173f},
    {0.069316445f, -0.0728884556f,  0.1117120146f, -0.0849910695f,  0.0189281013f, -0.0654260269f,  0.1376506282f, -0.0436972585f, -0.0117625146f,  0.0005986622f,  0.0976928267f, -0.1189567168f,  0.2340437865f,  -0.140015082f, -0.0236796594f, -0.0031628242f, -0.0008777887f,  0.0363463761f,   0.102120976f, -0.2199815897f, -0.3410100166f, -0.0184515529f,  0.0625106802f,  0.0020669935f}
};
static float temp_celcius = 20.0f;

float r_bar;
float c;

float nfc1_d1;
float nfc1_g;
float nfc1_del[NFC1_NMAX];

float nfc2_d1;
float nfc2_d2;
float nfc2_g;
float nfc2_del[NFC2_NMAX][2];

float nfc3_d1;
float nfc3_d2;
float nfc3_d3;
float nfc3_g;
float nfc3_del[NFC3_NMAX][3];

float nfc4_d1;
float nfc4_d2;
float nfc4_d3;
float nfc4_d4;
float nfc4_g;
float nfc4_del[NFC4_NMAX][4];

float xover_k;
float xover_k2;
float xover_d;
float xover_b_hf[3];
float xover_b_lf[3];
float xover_a[2];
float xover_iir_del[INPUTS];
float xover_fir0_del[INPUTS];
float xover_fir1_del[INPUTS][2];
float xover_fir2_del[INPUTS][2];

static bool initialization = true;

void syfala (
        sy_ap_int audio_in_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_0[SYFALA_BLOCK_NSAMPLES],
        sy_ap_int audio_out_1[SYFALA_BLOCK_NSAMPLES],
           int arm_ok,
         bool* i2s_rst,
        float* mem_zone_f,
          int* mem_zone_i,
          bool bypass,
          bool mute,
          bool debug
) {
#pragma HLS INTERFACE ap_fifo port=audio_in_0
#pragma HLS INTERFACE ap_fifo port=audio_out_0
#pragma HLS INTERFACE ap_fifo port=audio_out_1
#pragma HLS INTERFACE s_axilite port=arm_ok
#pragma HLS INTERFACE m_axi port=mem_zone_f latency=30 bundle=ram
#pragma HLS INTERFACE m_axi port=mem_zone_i latency=30 bundle=ram

    // Active high reset, this HAVE TO BE DONE FIRST (crash with *some* dsp if not)
    *i2s_rst = !arm_ok;

    /* Initialization and computations can start after the ARM
     * has been initialized */
    if (arm_ok) {
        /* First function call: initialization */
        if (initialization) {
            for(int i = 0; i < INPUTS; i++){
                r_bar += rs[i];
            }
            r_bar /= ns;
            c = 331.3f * sqrt(1.0f + (temp_celcius/273.15f)); // speed of sound m/s

            float nfc_omega = c/(r_bar*SYFALA_SAMPLE_RATE);
            float nfc_r1 = nfc_omega/2.0f;
            float nfc_r2 = nfc_r1 * nfc_r1;

            float nfc1_b1 = nfc_omega/2.0f;
            float nfc1_g1 = 1.0f + nfc1_b1;
            nfc1_d1 = 0.0f - (2.0f * nfc1_b1) / nfc1_g1;
            nfc1_g = 1.0f/nfc1_g1; // where 1.0f is gain in Faust but it's always 1
            for (int i = 0; i < NFC1_NMAX; ++i) {
                nfc1_del[i] = 0.0f;
            }


            float nfc2_b1 = 3.0f * nfc_r1;
            float nfc2_b2 = 3.0f * nfc_r2;
            float nfc2_g2 = 1.0f + nfc2_b1 + nfc2_b2;
            nfc2_d1 = 0.0f - (2.0f * nfc2_b1 + 4.0f * nfc2_b2) / nfc2_g2;
            nfc2_d2 = 0.0f - (4.0f * nfc2_b2) / nfc2_g2;
            nfc2_g = 1.0f/nfc2_g2; // where 1.0f is gain in Faust but it's always 1
            for (int i = 0; i < NFC2_NMAX; ++i) {
                nfc2_del[i][0] = 0.0f;
                nfc2_del[i][1] = 0.0f;
            }

            float nfc3_b1 = 3.677814645373914f * nfc_r1;
            float nfc3_b2 = 6.459432693483369f * nfc_r2;
            float nfc3_g2 = 1.0f + nfc3_b1 + nfc3_b2;
            nfc3_d1 = 0.0f - (2.0f * nfc3_b1 + 4.0f * nfc3_b2) / nfc3_g2;
            nfc3_d2 = 0.0f - (4.0f * nfc3_b2) / nfc3_g2;
            float nfc3_b3 = 2.322185354626086f * nfc_r1;
            float nfc3_g3 = 1.0f + nfc3_b3;
            nfc3_d3 = 0.0f - (2.0f * nfc3_b3) / nfc3_g3;
            nfc3_g = 1.0f/(nfc3_g3*nfc3_g2); // where 1.0f is gain in Faust but it's always 1
            for (int i = 0; i < NFC3_NMAX; ++i) {
                nfc3_del[i][0] = 0.0f;
                nfc3_del[i][1] = 0.0f;
                nfc3_del[i][2] = 0.0f;
            }

            float nfc4_b1 =  4.207578794359250f * nfc_r1;
            float nfc4_b2 = 11.487800476871168f * nfc_r2;
            float nfc4_g2 = 1.0f + nfc4_b1 + nfc4_b2;
            nfc4_d1 = 0.0f - (2.0f * nfc4_b1 + 4.0f * nfc4_b2) / nfc4_g2;
            nfc4_d2 = 0.0f - (4.0f * nfc4_b2) / nfc4_g2;
            float nfc4_b3 = 5.792421205640748f * nfc_r1;
            float nfc4_b4 = 9.140130890277934f * nfc_r2;
            float nfc4_g3 = 1.0f + nfc4_b3 + nfc4_b4;
            nfc4_d3 = 0.0f - (2.0f * nfc4_b3 + 4.0f * nfc4_b4) / nfc4_g3;
            nfc4_d4 = 0.0f - (4.0f * nfc4_b4) / nfc4_g3;
            nfc4_g = 1.0f/(nfc4_g3*nfc4_g2); // where 1.0f is gain in Faust but it's always 1
            for (int i = 0; i < NFC4_NMAX; ++i) {
                nfc4_del[i][0] = 0.0f;
                nfc4_del[i][1] = 0.0f;
                nfc4_del[i][2] = 0.0f;
                nfc4_del[i][3] = 0.0f;
            }

            xover_k = tan(M_PI*xover_freq/SYFALA_SAMPLE_RATE);
            xover_k2 = xover_k*xover_k;
            xover_d =  xover_k2 + 2.0f*xover_k + 1.0f;
            xover_b_hf[0] = 1.0f/xover_d;
            xover_b_hf[1] = -2.0f/xover_d;
            xover_b_hf[2] = 1.0f/xover_d;
            xover_b_lf[0] = xover_k2/xover_d;
            xover_b_lf[1] = 2.0f*xover_k2/xover_d;
            xover_b_lf[2] = xover_k2/xover_d;
            xover_a[0] = 2.0f * (xover_k2 - 1.0f) / xover_d;
            xover_a[1] = (xover_k2 - 2.0f*xover_k + 1.0f) / xover_d;
            for(int i = 0; i < INPUTS; i++){
                xover_iir_del[i] = 0.0f;
                xover_fir0_del[i] = 0.0f;
                xover_fir1_del[i][0] = 0.0f;
                xover_fir1_del[i][1] = 0.0f;
                xover_fir2_del[i][0] = 0.0f;
                xover_fir2_del[i][1] = 0.0f;
            }

            initialization = false;
        } else {
            /* Every other iterations:
             * either process the bypass & mute switches... */
            if (bypass) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = audio_in_0[n];
                     audio_out_1[n] = audio_in_0[n];
                }
            } else if (mute) {
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                     audio_out_0[n] = 0;
                     audio_out_1[n] = 0;
                }
            } else {
                /* ... or compute samples here
                 * if you need to convert to float, use the following:
                 * (audio inputs and outputs are 24-bit integers) */
                float ins[INPUTS][SYFALA_BLOCK_NSAMPLES] = {0.0f};
                float outs[OUTPUTS][SYFALA_BLOCK_NSAMPLES] = {{0.0f}};

                for(int i = 0; i < INPUTS; i++){
                for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                    ins[i][n] = Syfala::HLS::ioreadf(audio_in_0[n]);
                }
                }

                // this section will be automatically generated in function of the value of co...
                int nfc1_n = 0;
                int nfc2_n = 0;
                int nfc3_n = 0;
                int nfc4_n = 0;
                for(int i = 0; i < INPUTS; i++){
                    if(co[i] == 1){ // NFC 1
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            ins[i][n] = ins[i][n]*nfc1_g + nfc1_del[nfc1_n]*nfc1_d1;
                            nfc1_del[nfc1_n] = ins[i][n] + nfc1_del[nfc1_n];
                        }
                        nfc1_n++;
                    }
                    else if(co[i] == 2){ // NFC 2
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            ins[i][n] = ins[i][n]*nfc2_g + nfc2_del[nfc2_n][0]*nfc2_d1 + nfc2_del[nfc2_n][1]*nfc2_d2;
                            nfc2_del[nfc2_n][0] = ins[i][n] + nfc2_del[nfc2_n][0];
                            nfc2_del[nfc2_n][1] = nfc2_del[nfc2_n][0] + nfc2_del[nfc2_n][1];
                        }
                        nfc2_n++;
                    }
                    else if(co[i] == 3){ // NFC 3
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            ins[i][n] = ins[i][n]*nfc3_g + nfc3_del[nfc3_n][0]*nfc3_d1 + nfc3_del[nfc3_n][1]*nfc3_d2;
                            nfc3_del[nfc3_n][0] = ins[i][n] + nfc3_del[nfc3_n][0];
                            nfc3_del[nfc3_n][1] = nfc3_del[nfc3_n][0] + nfc3_del[nfc3_n][1];
                            ins[i][n] = ins[i][n] + nfc3_del[nfc3_n][2]*nfc3_d3;
                            nfc3_del[nfc3_n][2] = ins[i][n] + nfc3_del[nfc3_n][2];
                        }
                        nfc3_n++;
                    }
                    else if(co[i] == 3){ // NFC 4
                        for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            ins[i][n] = ins[i][n]*nfc4_g + nfc4_del[nfc4_n][0]*nfc4_d1 + nfc4_del[nfc4_n][1]*nfc4_d2;
                            nfc4_del[nfc4_n][1] = ins[i][n] + nfc4_del[nfc4_n][0];
                            nfc4_del[nfc4_n][1] = nfc4_del[nfc4_n][0] + nfc4_del[nfc4_n][1];
                            ins[i][n] = ins[i][n] + nfc4_del[nfc4_n][2]*nfc4_d3 + nfc4_del[nfc4_n][2]*nfc4_d4;
                            nfc4_del[nfc4_n][2] = ins[i][n] + nfc4_del[nfc4_n][2];
                            nfc4_del[nfc4_n][3] = nfc4_del[nfc4_n][3] + nfc4_del[nfc4_n][3];
                        }
                        nfc4_n++;
                    }
                         // shelf filter decoder
                         for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            ins[i][n] = ins[i][n] - xover_iir_del[i];
                            xover_iir_del[i] = ins[i][n]*xover_a[0] + xover_fir0_del[i]*xover_a[1];
                            xover_fir0_del[i] = ins[i][n];
                            float fir1_y = ins[i][n]*xover_b_lf[0] + xover_fir1_del[i][0]*xover_b_lf[1] + xover_fir1_del[i][1]*xover_b_lf[2];
                            xover_fir1_del[i][1] = xover_fir1_del[i][0];
                            xover_fir1_del[i][0] = ins[i][n];
                            float fir2_y = ins[i][n]*xover_b_hf[0] + xover_fir2_del[i][0]*xover_b_hf[1] + xover_fir2_del[i][1]*xover_b_hf[2];
                            xover_fir2_del[i][1] = xover_fir2_del[i][0];
                            xover_fir2_del[i][0] = ins[i][n];
                            ins[i][n] = fir1_y*(gammas[0][co[i]]/lfhf_ratio) - fir2_y*(gammas[1][co[i]]*lfhf_ratio);
                         }
                     }

                     // speaker chain scaling
                     float mix[SYFALA_BLOCK_NSAMPLES] = {0.0f};
                     for(int i = 0; i < OUTPUTS; i++){
                         for(int j = 0; j < INPUTS; j++){
                             for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                                outs[i][n] += ins[j][n]*s[i][j];
                             }
                         }
                         for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                            outs[i][n] *= output_gain;
                            mix[n] += outs[i][n];
                         }
                     }

                    for (int n = 0; n < SYFALA_BLOCK_NSAMPLES; ++n) {
                         Syfala::HLS::iowritef(mix[n], &audio_out_0[n]);
                         Syfala::HLS::iowritef(mix[n], &audio_out_1[n]);
                     }
            }
        }
    }
}
