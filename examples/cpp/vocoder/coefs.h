#define OPSF_ATK_COEF 0.9979188352992993 // OPSF = one-pole switching filter
#define OPSF_REL_COEF 0.99584200184511 // OPSF = one-pole switching filter
#define A_ONE_COEF 2
#define B_ONE_COEF 3
#define NUM_FILTERS 70
#define A_SIZE 140
#define B_SIZE 210
float b[B_SIZE] = {2.886955666661675e-05f,5.77391133332335e-05f,2.886955666661675e-05f,0.00032061247253528966f,0.0f,-0.00032061247253528966f,0.00033014163106104966f,0.0f,-0.00033014163106104966f,0.0003497660092359474f,0.0f,-0.0003497660092359474f,0.000370556473401733f,0.0f,-0.000370556473401733f,0.00039258225981826726f,0.0f,-0.00039258225981826726f,0.00041591670917079545f,0.0f,-0.00041591670917079545f,0.00044063750909438374f,0.0f,-0.00044063750909438374f,0.00046682695093190407f,0.0f,-0.00046682695093190407f,0.0004945722015489745f,0.0f,-0.0004945722015489745f,0.000523965591075591f,0.0f,-0.000523965591075591f,0.0005551049174926f,0.0f,-0.0005551049174926f,0.000588093769032509f,0.0f,-0.000588093769032509f,0.0006230418654175619f,0.0f,-0.0006230418654175619f,0.0006600654190146609f,0.0f,-0.0006600654190146609f,0.0006992875170459018f,0.0f,-0.0006992875170459018f,0.0007408385260556959f,0.0f,-0.0007408385260556959f,0.0007848565199005674f,0.0f,-0.0007848565199005674f,0.0008314877325963102f,0.0f,-0.0008314877325963102f,0.0008808870374284698f,0.0f,-0.0008808870374284698f,0.0009332184538073183f,0.0f,-0.0009332184538073183f,0.0009886556834265068f,0.0f,-0.0009886556834265068f,0.0010473826773666722f,0.0f,-0.0010473826773666722f,0.00110959423587035f,0.0f,-0.00110959423587035f,0.00117549664260376f,0.0f,-0.00117549664260376f,0.0012453083353134776f,0.0f,-0.0012453083353134776f,0.0013192606148822626f,0.0f,-0.0013192606148822626f,0.0013975983948885174f,0.0f,-0.0013975983948885174f,0.00148058099387726f,0.0f,-0.00148058099387726f,0.0015684829726577303f,0.0f,-0.0015684829726577303f,0.0016615950190537493f,0.0f,-0.0016615950190537493f,0.0017602248826466735f,0.0f,-0.0017602248826466735f,0.001864698362168815f,0.0f,-0.001864698362168815f,0.0019753603483249563f,0.0f,-0.0019753603483249563f,0.0020925759249430602f,0.0f,-0.0020925759249430602f,0.0022167315314810566f,0.0f,-0.0022167315314810566f,0.0023482361900436094f,0.0f,-0.0023482361900436094f,0.002487522800192099f,0.0f,-0.002487522800192099f,0.00263504950496085f,0.0f,-0.00263504950496085f,0.0027913011316226923f,0.0f,-0.0027913011316226923f,0.0029567907108762155f,0.0f,-0.0029567907108762155f,0.0031320610782546152f,0.0f,-0.0031320610782546152f,0.0033176865616812404f,0.0f,-0.0033176865616812404f,0.003514274759217409f,0.0f,-0.003514274759217409f,0.003722468411163581f,0.0f,-0.003722468411163581f,0.003942947370782204f,0.0f,-0.003942947370782204f,0.00417643067801025f,0.0f,-0.00417643067801025f,0.004423678740615089f,0.0f,-0.004423678740615089f,0.004685495627322479f,0.0f,-0.004685495627322479f,0.004962731477499997f,0.0f,-0.004962731477499997f,0.005256285032016462f,0.0f,-0.005256285032016462f,0.0055671062899114955f,0.0f,-0.0055671062899114955f,0.00589619929549388f,0.0f,-0.00589619929549388f,0.00624462506044163f,0.0f,-0.00624462506044163f,0.006613504625393773f,0.0f,-0.006613504625393773f,0.0070040222653984345f,0.0f,-0.0070040222653984345f,0.007417428843409774f,0.0f,-0.007417428843409774f,0.007855045315797612f,0.0f,-0.007855045315797612f,0.008318266393545097f,0.0f,-0.008318266393545097f,0.008808564362452018f,0.0f,-0.008808564362452018f,0.009327493065224512f,0.0f,-0.009327493065224512f,0.009876692047808775f,0.0f,-0.009876692047808775f,0.01045789087170954f,0.0f,-0.01045789087170954f,0.011072913593304586f,0.0f,-0.011072913593304586f,0.011723683410326272f,0.0f,-0.011723683410326272f,0.012412227474706616f,0.0f,-0.012412227474706616f,0.013140681869868557f,0.0f,-0.013140681869868557f,0.013911296749277968f,0.0f,-0.013911296749277968f,0.014307267217917289f,0.0f,-0.014307267217917289f,0.6773067934863989f,-1.3546135869727978f,0.6773067934863989f};
float a[A_SIZE] = {-1.984745119065662f,0.9848605972923284f,-1.9992425561506535f,0.9993587750549292f,-1.9992092604397278f,0.9993397167378778f,-1.999154038806843f,0.999300467981528f,-1.999094529525062f,0.9992588870531967f,-1.9990303547661281f,0.9992148354803636f,-1.998961099203801f,0.9991681665816586f,-1.9988863059465631f,0.9991187249818112f,-1.998805472004099f,0.9990663460981362f,-1.9987180432324745f,0.999010855596902f,-1.9986234086963655f,0.9989520688178489f,-1.9985208943792832f,0.9988897901650146f,-1.9984097561644882f,0.9988238124619349f,-1.998289171999996f,0.9987539162691649f,-1.9981582331507266f,0.9986798691619707f,-1.99801593442921f,0.9986014249659084f,-1.9978611632832588f,0.9985183229478882f,-1.9976926876044547f,0.9984302869601989f,-1.9975091421049798f,0.9983370245348074f,-1.9973090130921027f,0.9982382259251428f,-1.99709062144919f,0.9981335630923851f,-1.9968521036092866f,0.9980226886331467f,-1.9965913902817818f,0.9979052346452667f,-1.9963061826641044f,0.9977808115282591f,-1.995993925838504f,0.9976490067147924f,-1.9956517790183053f,0.9975093833293732f,-1.9952765822682346f,0.9973614787702356f,-1.994864819278974f,0.9972048032102228f,-1.9944125757265372f,0.9970388380122457f,-1.9939154926918017f,0.9968630340546846f,-1.993368714553989f,0.9966768099618925f,-1.9927668307033357f,0.9964795502347066f,-1.992103810342011f,0.9962706032756622f,-1.9913729295576514f,0.9960492793033501f,-1.9905666897599246f,0.995814848150114f,-1.9896767264663953f,0.9955665369370381f,-1.9886937073087212f,0.9953035276199128f,-1.9876072180029043f,0.9950249543996157f,-1.9864056348869488f,0.9947299009900782f,-1.9850759824748805f,0.9944173977367546f,-1.9836037743066774f,0.9940864185782473f,-1.9819728351883645f,0.9937358778434908f,-1.9801651027145808f,0.9933646268766375f,-1.978160405746772f,0.9929714504815653f,-1.975936217283478f,0.9925550631776728f,-1.9734673789051742f,0.9921141052584359f,-1.9707257937054343f,0.9916471386439796f,-1.967680084334372f,0.99115264251877f,-1.9642952124818587f,0.9906290087453553f,-1.960532055820917f,0.9900745370449998f,-1.9563469381216267f,0.989487429935967f,-1.9516911079409702f,0.9888657874201768f,-1.9465101610054596f,0.9882076014090124f,-1.9407434011460734f,0.9875107498791165f,-1.9343231344390572f,0.9867729907492125f,-1.9271738910777023f,0.985991955469203f,-1.9192115694836205f,0.9851651423131804f,-1.9103424973053695f,0.9842899093684052f,-1.9004624043043548f,0.9833634672129098f,-1.8894553027649015f,0.9823828712750963f,-1.8771922720788292f,0.9813450138695504f,-1.8635301456601734f,0.9802466159043823f,-1.8483101004873423f,0.9790842182565812f,-1.8313561525284499f,0.9778541728133908f,-1.8124735653041624f,0.9765526331793474f,-1.791447184156978f,0.9751755450505868f,-1.768039715764174f,0.9737186362602633f,-1.7419899814650275f,0.9721774065014444f,-1.713729073832054f,0.9713854655641653f,-1.2476208183060224f,0.4616063556395727f};