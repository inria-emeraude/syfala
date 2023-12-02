import("stdfaust.lib");

t60 = 30;
excitation = button("gate [switch:5]") : ba.impulsify;

process = excitation : pm.frenchBellModel(6,0,t60,1,2.5);
