sms-test: source directory of test used for SMC2022 paper:
-----------------------------
usage: for re-building bell test (SMC2022 fig.7) 
edit script-smc-bell.bash to indicate for which value of N (in faust/bellN.dsp) you want to perform the HLS
1) change the faust version to 2.37.3 (???)
./script-smc-bell.bash build v6.1
2) change the faust version to 2.39.3 
./script-smc-bell.bash build v6.3
3)
cd report; ./script-report-Utilization.bash bell
--> generates report-bell.csv (not sure report-bell.tex is correct)
4) 
cd latex; make
acroread fig4.pdf
--------------------------------
WARNING: For the data published in smc2022 I had to add manually in v6.1-bell-root-*/build/faust_ip/faust_ip.cpp
  #pragma HLS INLINE
in function  instanceConstantsmydsp
otherwise the results wher confusing: i.e after N=3 the complexity dropped and became better than in v6.3...
