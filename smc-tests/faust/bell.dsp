import("stdfaust.lib");

t60 = 30;
excitation = button("gate") : ba.impulsify;

process = excitation : pm.frenchBellModel(6,0,t60,1,2.5);
