import("stdfaust.lib");

t60 = 30;
N = 48;
excitation = button("gate [switch:5]") : ba.impulsify;
process = excitation : pm.frenchBellModel(N,0,t60,1,2.5);
