EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "ControllerBoard"
Date "2021-09-21"
Rev "1"
Comp "INSA Lyon"
Comment1 "Author: POPOFF Maxime"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:R_POT RV2
U 1 1 6148C1C9
P 1400 1700
F 0 "RV2" V 1193 1700 50  0000 C CNN
F 1 "10k" V 1284 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 1400 1700 50  0001 C CNN
F 3 "~" H 1400 1700 50  0001 C CNN
	1    1400 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV3
U 1 1 6148CA42
P 1900 1700
F 0 "RV3" V 1693 1700 50  0000 C CNN
F 1 "10k" V 1784 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 1900 1700 50  0001 C CNN
F 3 "~" H 1900 1700 50  0001 C CNN
	1    1900 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV4
U 1 1 6148CFB7
P 2400 1700
F 0 "RV4" V 2193 1700 50  0000 C CNN
F 1 "10k" V 2284 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 2400 1700 50  0001 C CNN
F 3 "~" H 2400 1700 50  0001 C CNN
	1    2400 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV5
U 1 1 6148D261
P 2900 1700
F 0 "RV5" V 2693 1700 50  0000 C CNN
F 1 "10k" V 2784 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 2900 1700 50  0001 C CNN
F 3 "~" H 2900 1700 50  0001 C CNN
	1    2900 1700
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0101
U 1 1 61492384
P 2050 950
F 0 "#PWR0101" H 2050 800 50  0001 C CNN
F 1 "VCC" H 2067 1123 50  0000 C CNN
F 2 "" H 2050 950 50  0001 C CNN
F 3 "" H 2050 950 50  0001 C CNN
	1    2050 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV6
U 1 1 6149A68F
P 3400 1700
F 0 "RV6" V 3193 1700 50  0000 C CNN
F 1 "10k" V 3284 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 3400 1700 50  0001 C CNN
F 3 "~" H 3400 1700 50  0001 C CNN
	1    3400 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV7
U 1 1 6149AC52
P 3900 1700
F 0 "RV7" V 3693 1700 50  0000 C CNN
F 1 "10k" V 3784 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 3900 1700 50  0001 C CNN
F 3 "~" H 3900 1700 50  0001 C CNN
	1    3900 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV8
U 1 1 6149B0CA
P 4400 1700
F 0 "RV8" V 4193 1700 50  0000 C CNN
F 1 "10k" V 4284 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 4400 1700 50  0001 C CNN
F 3 "~" H 4400 1700 50  0001 C CNN
	1    4400 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV1
U 1 1 6149B9B5
P 900 1700
F 0 "RV1" V 693 1700 50  0000 C CNN
F 1 "10k" V 784 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Omeg_PC16BU_Vertical" H 900 1700 50  0001 C CNN
F 3 "~" H 900 1700 50  0001 C CNN
	1    900  1700
	0    1    1    0   
$EndComp
Connection ~ 2050 950 
Wire Wire Line
	5800 5150 5500 5150
Wire Wire Line
	5800 5250 5550 5250
$Comp
L power:GND #PWR0103
U 1 1 614CE001
P 8300 5300
F 0 "#PWR0103" H 8300 5050 50  0001 C CNN
F 1 "GND" H 8305 5127 50  0000 C CNN
F 2 "" H 8300 5300 50  0001 C CNN
F 3 "" H 8300 5300 50  0001 C CNN
	1    8300 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 4750 7900 4750
Wire Wire Line
	7900 4750 7900 5200
Wire Wire Line
	7900 5200 8300 5200
Wire Wire Line
	8700 5200 8700 4750
Wire Wire Line
	8700 4750 8550 4750
Wire Wire Line
	8300 5200 8300 5300
Connection ~ 8300 5200
Wire Wire Line
	8300 5200 8700 5200
$Comp
L power:VCC #PWR0104
U 1 1 614D12C3
P 8950 4950
F 0 "#PWR0104" H 8950 4800 50  0001 C CNN
F 1 "VCC" H 8967 5123 50  0000 C CNN
F 2 "" H 8950 4950 50  0001 C CNN
F 3 "" H 8950 4950 50  0001 C CNN
	1    8950 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 4850 8000 4850
Wire Wire Line
	8000 4850 8000 5000
Wire Wire Line
	8600 5000 8600 4850
Wire Wire Line
	8600 4850 8550 4850
Wire Wire Line
	8950 4950 8950 5000
Wire Wire Line
	8000 5000 8600 5000
Connection ~ 8600 5000
Wire Wire Line
	8600 5000 8950 5000
Wire Wire Line
	6300 5450 6300 5650
Wire Wire Line
	6300 5650 6450 5650
Wire Wire Line
	6600 5650 6600 5450
$Comp
L power:GND #PWR0105
U 1 1 614D6350
P 6450 5800
F 0 "#PWR0105" H 6450 5550 50  0001 C CNN
F 1 "GND" H 6455 5627 50  0000 C CNN
F 2 "" H 6450 5800 50  0001 C CNN
F 3 "" H 6450 5800 50  0001 C CNN
	1    6450 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 5650 6450 5800
Connection ~ 6450 5650
Wire Wire Line
	6450 5650 6600 5650
Wire Wire Line
	7750 5050 7750 4350
Wire Wire Line
	7750 4350 8050 4350
Wire Wire Line
	7000 4950 7700 4950
Wire Wire Line
	7700 4950 7700 4450
Wire Wire Line
	7700 4450 7950 4450
Wire Wire Line
	8050 4550 7850 4550
Wire Wire Line
	7650 4550 7650 4850
Wire Wire Line
	7650 4850 7000 4850
Wire Wire Line
	7000 4750 7600 4750
Wire Wire Line
	7600 4750 7600 4650
Wire Wire Line
	7600 4650 7800 4650
Wire Wire Line
	9700 4350 9450 4350
Wire Wire Line
	9450 4350 9450 3800
Wire Wire Line
	9450 3800 8050 3800
Wire Wire Line
	8050 3800 8050 4350
Wire Wire Line
	7950 4450 7950 3700
Wire Wire Line
	7950 3700 9350 3700
Wire Wire Line
	9350 3700 9350 4450
Wire Wire Line
	9350 4450 9700 4450
Connection ~ 7950 4450
Wire Wire Line
	7950 4450 8050 4450
Wire Wire Line
	7850 4550 7850 3600
Wire Wire Line
	7850 3600 9250 3600
Wire Wire Line
	9250 3600 9250 4550
Wire Wire Line
	9250 4550 9700 4550
Connection ~ 7850 4550
Wire Wire Line
	7850 4550 7650 4550
Wire Wire Line
	7800 4650 7800 5600
Wire Wire Line
	7800 5600 9250 5600
Wire Wire Line
	9250 5600 9250 4650
Wire Wire Line
	9250 4650 9700 4650
Connection ~ 7800 4650
Wire Wire Line
	7800 4650 8050 4650
Wire Wire Line
	9700 4850 9700 4950
Wire Wire Line
	10200 4950 10200 4850
Wire Wire Line
	10200 4750 10250 4750
Wire Wire Line
	10250 4750 10250 5050
Wire Wire Line
	9650 5050 9650 4750
Wire Wire Line
	9650 4750 9700 4750
Wire Wire Line
	10250 5050 9950 5050
Wire Wire Line
	9700 4950 10200 4950
$Comp
L power:VCC #PWR0106
U 1 1 614F3360
P 10450 4850
F 0 "#PWR0106" H 10450 4700 50  0001 C CNN
F 1 "VCC" H 10467 5023 50  0000 C CNN
F 2 "" H 10450 4850 50  0001 C CNN
F 3 "" H 10450 4850 50  0001 C CNN
	1    10450 4850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 614F3895
P 9950 5150
F 0 "#PWR0107" H 9950 4900 50  0001 C CNN
F 1 "GND" H 9955 4977 50  0000 C CNN
F 2 "" H 9950 5150 50  0001 C CNN
F 3 "" H 9950 5150 50  0001 C CNN
	1    9950 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	9950 5150 9950 5050
Connection ~ 9950 5050
Wire Wire Line
	9950 5050 9650 5050
Wire Wire Line
	10200 4950 10450 4950
Wire Wire Line
	10450 4950 10450 4850
Connection ~ 10200 4950
Wire Wire Line
	8550 4350 8950 4350
Wire Wire Line
	8950 4350 8950 3900
Wire Wire Line
	8950 3900 10400 3900
Wire Wire Line
	10400 3900 10400 4350
Wire Wire Line
	10400 4350 10200 4350
Wire Wire Line
	10200 4450 10450 4450
Wire Wire Line
	10450 4450 10450 3950
Wire Wire Line
	10450 3950 9000 3950
Wire Wire Line
	9000 3950 9000 4450
Wire Wire Line
	9000 4450 8550 4450
Wire Wire Line
	8550 4550 9050 4550
Wire Wire Line
	9050 4550 9050 4000
Wire Wire Line
	9050 4000 10500 4000
Wire Wire Line
	10500 4000 10500 4550
Wire Wire Line
	10500 4550 10200 4550
Wire Wire Line
	10200 4650 10550 4650
Wire Wire Line
	10550 4650 10550 4050
Wire Wire Line
	10550 4050 9100 4050
Wire Wire Line
	9100 4050 9100 4650
Wire Wire Line
	9100 4650 8550 4650
$Comp
L power:VCC #PWR0108
U 1 1 61508701
P 6450 3900
F 0 "#PWR0108" H 6450 3750 50  0001 C CNN
F 1 "VCC" H 6467 4073 50  0000 C CNN
F 2 "" H 6450 3900 50  0001 C CNN
F 3 "" H 6450 3900 50  0001 C CNN
	1    6450 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 4350 6300 3900
Wire Wire Line
	6300 3900 6450 3900
Wire Wire Line
	6600 4350 6600 3900
Wire Wire Line
	6600 3900 6450 3900
Connection ~ 6450 3900
$Comp
L Device:C C1
U 1 1 615109F8
P 7400 5200
F 0 "C1" V 7148 5200 50  0000 C CNN
F 1 "10p" V 7239 5200 50  0000 C CNN
F 2 "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P2.50mm" H 7438 5050 50  0001 C CNN
F 3 "~" H 7400 5200 50  0001 C CNN
	1    7400 5200
	-1   0    0    1   
$EndComp
$Comp
L Device:R_POT RV12
U 1 1 6156F428
P 5700 1700
F 0 "RV12" V 5493 1700 50  0000 C CNN
F 1 "10k" V 5584 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 5700 1700 50  0001 C CNN
F 3 "~" H 5700 1700 50  0001 C CNN
	1    5700 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV13
U 1 1 6156F42E
P 6200 1700
F 0 "RV13" V 5993 1700 50  0000 C CNN
F 1 "10k" V 6084 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 6200 1700 50  0001 C CNN
F 3 "~" H 6200 1700 50  0001 C CNN
	1    6200 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV14
U 1 1 6156F434
P 6700 1700
F 0 "RV14" V 6493 1700 50  0000 C CNN
F 1 "10k" V 6584 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 6700 1700 50  0001 C CNN
F 3 "~" H 6700 1700 50  0001 C CNN
	1    6700 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV15
U 1 1 6156F43A
P 7200 1700
F 0 "RV15" V 6993 1700 50  0000 C CNN
F 1 "10k" V 7084 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 7200 1700 50  0001 C CNN
F 3 "~" H 7200 1700 50  0001 C CNN
	1    7200 1700
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0109
U 1 1 6156F440
P 6350 950
F 0 "#PWR0109" H 6350 800 50  0001 C CNN
F 1 "VCC" H 6367 1123 50  0000 C CNN
F 2 "" H 6350 950 50  0001 C CNN
F 3 "" H 6350 950 50  0001 C CNN
	1    6350 950 
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV11
U 1 1 6156F458
P 5200 1700
F 0 "RV11" V 4993 1700 50  0000 C CNN
F 1 "10k" V 5084 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 5200 1700 50  0001 C CNN
F 3 "~" H 5200 1700 50  0001 C CNN
	1    5200 1700
	0    1    1    0   
$EndComp
Wire Wire Line
	5050 1700 5050 950 
Wire Wire Line
	5050 950  5550 950 
Wire Wire Line
	5550 1700 5550 950 
Connection ~ 5550 950 
Wire Wire Line
	5550 950  6050 950 
Wire Wire Line
	6050 1700 6050 950 
Connection ~ 6050 950 
Wire Wire Line
	6050 950  6350 950 
Wire Wire Line
	6350 950  6550 950 
Wire Wire Line
	6550 950  6550 1700
Connection ~ 6350 950 
Wire Wire Line
	6550 950  7050 950 
Wire Wire Line
	7050 950  7050 1700
Connection ~ 6550 950 
Wire Wire Line
	7050 950  7550 950 
Wire Wire Line
	7550 950  7550 1700
Connection ~ 7050 950 
Wire Wire Line
	7550 950  8050 950 
Wire Wire Line
	8050 950  8050 1700
Connection ~ 7550 950 
Wire Wire Line
	8550 950  8550 1700
Wire Wire Line
	8050 950  8550 950 
Connection ~ 8050 950 
Wire Wire Line
	5350 1700 5350 2250
Wire Wire Line
	5350 2250 5850 2250
Wire Wire Line
	5850 1700 5850 2250
Connection ~ 5850 2250
Wire Wire Line
	5850 2250 6350 2250
Wire Wire Line
	6350 1700 6350 2250
Connection ~ 6350 2250
Wire Wire Line
	6850 1700 6850 2250
Wire Wire Line
	7350 1700 7350 2250
Wire Wire Line
	7350 2250 6850 2250
Connection ~ 6850 2250
Wire Wire Line
	7850 1700 7850 2250
Wire Wire Line
	7850 2250 7350 2250
Connection ~ 7350 2250
Wire Wire Line
	8350 1700 8350 2250
Wire Wire Line
	8350 2250 7850 2250
Connection ~ 7850 2250
Wire Wire Line
	8850 1700 8850 2250
Wire Wire Line
	8850 2250 8350 2250
Connection ~ 8350 2250
Connection ~ 6400 2250
Wire Wire Line
	6850 2250 6400 2250
Wire Wire Line
	6350 2250 6400 2250
$Comp
L power:GND #PWR0110
U 1 1 6156F48C
P 6400 2250
F 0 "#PWR0110" H 6400 2000 50  0001 C CNN
F 1 "GND" H 6405 2077 50  0000 C CNN
F 2 "" H 6400 2250 50  0001 C CNN
F 3 "" H 6400 2250 50  0001 C CNN
	1    6400 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 5050 4800 5050
Wire Wire Line
	2900 4950 4750 4950
Wire Wire Line
	2400 4850 4700 4850
Wire Wire Line
	1400 4650 4600 4650
Wire Wire Line
	900  4550 4550 4550
Wire Wire Line
	4400 5250 4400 1850
Wire Wire Line
	3900 5150 3900 1850
Wire Wire Line
	3400 1850 3400 5050
Wire Wire Line
	2900 1850 2900 4950
Wire Wire Line
	2400 1850 2400 4850
Wire Wire Line
	1900 1850 1900 4750
Wire Wire Line
	1400 1850 1400 4650
Wire Wire Line
	900  1850 900  4550
$Comp
L power:GND #PWR0102
U 1 1 614931D4
P 2100 2200
F 0 "#PWR0102" H 2100 1950 50  0001 C CNN
F 1 "GND" H 2105 2027 50  0000 C CNN
F 2 "" H 2100 2200 50  0001 C CNN
F 3 "" H 2100 2200 50  0001 C CNN
	1    2100 2200
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT RV16
U 1 1 6156F446
P 7700 1700
F 0 "RV16" V 7493 1700 50  0000 C CNN
F 1 "10k" V 7584 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 7700 1700 50  0001 C CNN
F 3 "~" H 7700 1700 50  0001 C CNN
	1    7700 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV17
U 1 1 6156F44C
P 8200 1700
F 0 "RV17" V 7993 1700 50  0000 C CNN
F 1 "10k" V 8084 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 8200 1700 50  0001 C CNN
F 3 "~" H 8200 1700 50  0001 C CNN
	1    8200 1700
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV18
U 1 1 6156F452
P 8700 1700
F 0 "RV18" V 8493 1700 50  0000 C CNN
F 1 "10k" V 8584 1700 50  0000 C CNN
F 2 "Potentiometer_THT:Potentiometer_Bourns_PTA6043_Single_Slide" H 8700 1700 50  0001 C CNN
F 3 "~" H 8700 1700 50  0001 C CNN
	1    8700 1700
	0    1    1    0   
$EndComp
Wire Wire Line
	5200 1850 5200 4550
Connection ~ 5200 4550
Wire Wire Line
	5200 4550 5800 4550
Wire Wire Line
	5250 4650 5250 2450
Wire Wire Line
	5250 2450 5700 2450
Wire Wire Line
	5700 2450 5700 1850
Connection ~ 5250 4650
Wire Wire Line
	5250 4650 5800 4650
Wire Wire Line
	6200 1850 6200 2500
Wire Wire Line
	6200 2500 5300 2500
Wire Wire Line
	5300 2500 5300 4750
Connection ~ 5300 4750
Wire Wire Line
	5300 4750 5800 4750
Wire Wire Line
	6700 1850 6700 2550
Wire Wire Line
	6700 2550 5350 2550
Wire Wire Line
	5350 2550 5350 4850
Connection ~ 5350 4850
Wire Wire Line
	5350 4850 5800 4850
Wire Wire Line
	5400 4950 5400 2600
Wire Wire Line
	5400 2600 7200 2600
Wire Wire Line
	7200 2600 7200 1850
Connection ~ 5400 4950
Wire Wire Line
	5400 4950 5800 4950
Wire Wire Line
	7700 1850 7700 2650
Wire Wire Line
	7700 2650 5450 2650
Wire Wire Line
	5450 2650 5450 5050
Connection ~ 5450 5050
Wire Wire Line
	5450 5050 5800 5050
Wire Wire Line
	5500 5150 5500 2700
Wire Wire Line
	5500 2700 8200 2700
Wire Wire Line
	8200 2700 8200 1850
Connection ~ 5500 5150
Wire Wire Line
	5500 5150 4850 5150
Wire Wire Line
	8700 1850 8700 2750
Wire Wire Line
	8700 2750 5550 2750
Wire Wire Line
	5550 2750 5550 5250
Connection ~ 5550 5250
Wire Wire Line
	5550 5250 4900 5250
$Comp
L Switch:SW_Push SW2
U 1 1 616A83AC
P 1250 6500
F 0 "SW2" H 1250 6785 50  0000 C CNN
F 1 "SW_Push" H 1250 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 1250 6700 50  0001 C CNN
F 3 "~" H 1250 6700 50  0001 C CNN
	1    1250 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW3
U 1 1 616A9F4F
P 1850 6500
F 0 "SW3" H 1850 6785 50  0000 C CNN
F 1 "SW_Push" H 1850 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 1850 6700 50  0001 C CNN
F 3 "~" H 1850 6700 50  0001 C CNN
	1    1850 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW4
U 1 1 616AA3CA
P 2400 6500
F 0 "SW4" H 2400 6785 50  0000 C CNN
F 1 "SW_Push" H 2400 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2400 6700 50  0001 C CNN
F 3 "~" H 2400 6700 50  0001 C CNN
	1    2400 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW1
U 1 1 616B6869
P 700 6500
F 0 "SW1" H 700 6785 50  0000 C CNN
F 1 "SW_Push" H 700 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 700 6700 50  0001 C CNN
F 3 "~" H 700 6700 50  0001 C CNN
	1    700  6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW5
U 1 1 616B6C4F
P 2950 6500
F 0 "SW5" H 2950 6785 50  0000 C CNN
F 1 "SW_Push" H 2950 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 2950 6700 50  0001 C CNN
F 3 "~" H 2950 6700 50  0001 C CNN
	1    2950 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW6
U 1 1 616B7034
P 3500 6500
F 0 "SW6" H 3500 6785 50  0000 C CNN
F 1 "SW_Push" H 3500 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 3500 6700 50  0001 C CNN
F 3 "~" H 3500 6700 50  0001 C CNN
	1    3500 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW7
U 1 1 616B73F7
P 4050 6500
F 0 "SW7" H 4050 6785 50  0000 C CNN
F 1 "SW_Push" H 4050 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 4050 6700 50  0001 C CNN
F 3 "~" H 4050 6700 50  0001 C CNN
	1    4050 6500
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW8
U 1 1 616B7717
P 4600 6500
F 0 "SW8" H 4600 6785 50  0000 C CNN
F 1 "SW_Push" H 4600 6694 50  0000 C CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm" H 4600 6700 50  0001 C CNN
F 3 "~" H 4600 6700 50  0001 C CNN
	1    4600 6500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0111
U 1 1 616B7C59
P 2250 5800
F 0 "#PWR0111" H 2250 5650 50  0001 C CNN
F 1 "VCC" H 2267 5973 50  0000 C CNN
F 2 "" H 2250 5800 50  0001 C CNN
F 3 "" H 2250 5800 50  0001 C CNN
	1    2250 5800
	1    0    0    -1  
$EndComp
Wire Wire Line
	500  6500 500  5850
Wire Wire Line
	500  5850 1050 5850
Wire Wire Line
	2250 5850 2250 5800
Wire Wire Line
	1050 6500 1050 5850
Connection ~ 1050 5850
Wire Wire Line
	1050 5850 1650 5850
Wire Wire Line
	1650 6500 1650 5850
Connection ~ 1650 5850
Wire Wire Line
	1650 5850 2200 5850
Wire Wire Line
	2200 6500 2200 5850
Connection ~ 2200 5850
Wire Wire Line
	2200 5850 2250 5850
Wire Wire Line
	2750 6500 2750 5850
Wire Wire Line
	2750 5850 2250 5850
Connection ~ 2250 5850
Wire Wire Line
	3300 6500 3300 5850
Wire Wire Line
	3300 5850 2750 5850
Connection ~ 2750 5850
Wire Wire Line
	3850 6500 3850 5850
Wire Wire Line
	3850 5850 3300 5850
Connection ~ 3300 5850
Wire Wire Line
	4400 6500 4400 5850
Wire Wire Line
	4400 5850 3850 5850
Connection ~ 3850 5850
$Comp
L power:GND #PWR0112
U 1 1 6171E7FE
P 2600 7150
F 0 "#PWR0112" H 2600 6900 50  0001 C CNN
F 1 "GND" H 2605 6977 50  0000 C CNN
F 2 "" H 2600 7150 50  0001 C CNN
F 3 "" H 2600 7150 50  0001 C CNN
	1    2600 7150
	1    0    0    -1  
$EndComp
$Comp
L Device:R R1
U 1 1 6171FA2E
P 900 6750
F 0 "R1" H 970 6796 50  0000 L CNN
F 1 "10k" H 970 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 830 6750 50  0001 C CNN
F 3 "~" H 900 6750 50  0001 C CNN
	1    900  6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 6171FE0F
P 1450 6750
F 0 "R2" H 1520 6796 50  0000 L CNN
F 1 "10k" H 1520 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 1380 6750 50  0001 C CNN
F 3 "~" H 1450 6750 50  0001 C CNN
	1    1450 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R3
U 1 1 6172003D
P 2050 6750
F 0 "R3" H 2120 6796 50  0000 L CNN
F 1 "10k" H 2120 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 1980 6750 50  0001 C CNN
F 3 "~" H 2050 6750 50  0001 C CNN
	1    2050 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R4
U 1 1 6172022E
P 2600 6750
F 0 "R4" H 2670 6796 50  0000 L CNN
F 1 "10k" H 2670 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 2530 6750 50  0001 C CNN
F 3 "~" H 2600 6750 50  0001 C CNN
	1    2600 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R5
U 1 1 61720431
P 3150 6750
F 0 "R5" H 3220 6796 50  0000 L CNN
F 1 "10k" H 3220 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3080 6750 50  0001 C CNN
F 3 "~" H 3150 6750 50  0001 C CNN
	1    3150 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R6
U 1 1 61720789
P 3700 6750
F 0 "R6" H 3770 6796 50  0000 L CNN
F 1 "10k" H 3770 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 3630 6750 50  0001 C CNN
F 3 "~" H 3700 6750 50  0001 C CNN
	1    3700 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R7
U 1 1 61720AA9
P 4250 6750
F 0 "R7" H 4320 6796 50  0000 L CNN
F 1 "10k" H 4320 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4180 6750 50  0001 C CNN
F 3 "~" H 4250 6750 50  0001 C CNN
	1    4250 6750
	1    0    0    -1  
$EndComp
$Comp
L Device:R R8
U 1 1 61720D90
P 4800 6750
F 0 "R8" H 4870 6796 50  0000 L CNN
F 1 "10k" H 4870 6705 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal" V 4730 6750 50  0001 C CNN
F 3 "~" H 4800 6750 50  0001 C CNN
	1    4800 6750
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  6500 900  6600
Wire Wire Line
	1450 6500 1450 6600
Wire Wire Line
	2050 6500 2050 6600
Wire Wire Line
	2600 6500 2600 6600
Wire Wire Line
	3150 6500 3150 6600
Wire Wire Line
	3700 6500 3700 6600
Wire Wire Line
	4250 6500 4250 6600
Wire Wire Line
	4800 6500 4800 6600
Wire Wire Line
	900  6900 900  7150
Wire Wire Line
	900  7150 1450 7150
Wire Wire Line
	2600 6900 2600 7150
Connection ~ 2600 7150
Wire Wire Line
	2050 6900 2050 7150
Connection ~ 2050 7150
Wire Wire Line
	2050 7150 2600 7150
Wire Wire Line
	1450 6900 1450 7150
Connection ~ 1450 7150
Wire Wire Line
	1450 7150 2050 7150
Wire Wire Line
	3150 6900 3150 7150
Wire Wire Line
	3150 7150 2600 7150
Wire Wire Line
	3700 6900 3700 7150
Wire Wire Line
	3700 7150 3150 7150
Connection ~ 3150 7150
Wire Wire Line
	4250 6900 4250 7150
Wire Wire Line
	4250 7150 3700 7150
Connection ~ 3700 7150
Wire Wire Line
	4800 6900 4800 7150
Wire Wire Line
	4800 7150 4250 7150
Connection ~ 4250 7150
Wire Wire Line
	900  6500 900  5350
Wire Wire Line
	900  5350 4550 5350
Wire Wire Line
	4550 5350 4550 4550
Connection ~ 900  6500
Connection ~ 4550 4550
Wire Wire Line
	4550 4550 5200 4550
Wire Wire Line
	1450 6500 1450 5400
Wire Wire Line
	1450 5400 4600 5400
Wire Wire Line
	4600 5400 4600 4650
Connection ~ 1450 6500
Connection ~ 4600 4650
Wire Wire Line
	4600 4650 5250 4650
Wire Wire Line
	1900 4750 4650 4750
Wire Wire Line
	2050 6500 2050 5450
Wire Wire Line
	2050 5450 4650 5450
Wire Wire Line
	4650 5450 4650 4750
Connection ~ 2050 6500
Connection ~ 4650 4750
Wire Wire Line
	4650 4750 5300 4750
Wire Wire Line
	2600 6500 2600 5500
Wire Wire Line
	2600 5500 4700 5500
Wire Wire Line
	4700 5500 4700 4850
Connection ~ 2600 6500
Connection ~ 4700 4850
Wire Wire Line
	4700 4850 5350 4850
Wire Wire Line
	3150 6500 3150 5550
Wire Wire Line
	3150 5550 4750 5550
Wire Wire Line
	4750 5550 4750 4950
Connection ~ 3150 6500
Connection ~ 4750 4950
Wire Wire Line
	4750 4950 5400 4950
Wire Wire Line
	3700 6500 3700 5600
Wire Wire Line
	3700 5600 4800 5600
Wire Wire Line
	4800 5600 4800 5050
Connection ~ 3700 6500
Connection ~ 4800 5050
Wire Wire Line
	4800 5050 5450 5050
Wire Wire Line
	4250 6500 4250 5650
Wire Wire Line
	4250 5650 4850 5650
Wire Wire Line
	4850 5650 4850 5150
Connection ~ 4250 6500
Connection ~ 4850 5150
Wire Wire Line
	4850 5150 3900 5150
Wire Wire Line
	4800 6500 4800 5700
Wire Wire Line
	4800 5700 4900 5700
Wire Wire Line
	4900 5700 4900 5250
Connection ~ 4800 6500
Connection ~ 4900 5250
Wire Wire Line
	4900 5250 4400 5250
$Comp
L Connector_Generic:Conn_02x06_Odd_Even J1
U 1 1 61952628
P 8250 4550
F 0 "J1" H 8300 4967 50  0000 C CNN
F 1 "Conn_02x06_Odd_Even" H 8300 4876 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x06_P2.54mm_Horizontal" H 8250 4550 50  0001 C CNN
F 3 "~" H 8250 4550 50  0001 C CNN
	1    8250 4550
	1    0    0    -1  
$EndComp
Connection ~ 8050 4350
$Comp
L Connector_Generic:Conn_02x06_Odd_Even J2
U 1 1 61984E8E
P 9900 4550
F 0 "J2" H 9950 4967 50  0000 C CNN
F 1 "Conn_02x06_Odd_Even" H 9950 4876 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x06_P2.54mm_Vertical" H 9900 4550 50  0001 C CNN
F 3 "~" H 9900 4550 50  0001 C CNN
	1    9900 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	4550 1700 4550 950 
Wire Wire Line
	2050 950  2550 950 
Wire Wire Line
	4050 1700 4050 950 
Connection ~ 4050 950 
Wire Wire Line
	4050 950  4550 950 
Wire Wire Line
	3550 1700 3550 950 
Connection ~ 3550 950 
Wire Wire Line
	3550 950  4050 950 
Wire Wire Line
	3050 1700 3050 950 
Connection ~ 3050 950 
Wire Wire Line
	3050 950  3550 950 
Wire Wire Line
	2550 1700 2550 950 
Connection ~ 2550 950 
Wire Wire Line
	2550 950  3050 950 
Wire Wire Line
	2050 1700 2050 950 
Wire Wire Line
	1550 1700 1550 950 
Connection ~ 1550 950 
Wire Wire Line
	1550 950  2050 950 
Wire Wire Line
	1050 1700 1050 950 
Wire Wire Line
	1050 950  1550 950 
Wire Wire Line
	750  1700 750  2200
Wire Wire Line
	750  2200 1250 2200
Wire Wire Line
	1250 1700 1250 2200
Connection ~ 1250 2200
Wire Wire Line
	1250 2200 1750 2200
Wire Wire Line
	1750 1700 1750 2200
Connection ~ 1750 2200
Wire Wire Line
	1750 2200 2100 2200
Wire Wire Line
	2250 1700 2250 2200
Wire Wire Line
	2250 2200 2100 2200
Connection ~ 2100 2200
Wire Wire Line
	2750 1700 2750 2200
Wire Wire Line
	2750 2200 2250 2200
Connection ~ 2250 2200
Wire Wire Line
	2750 2200 3250 2200
Wire Wire Line
	3250 2200 3250 1700
Connection ~ 2750 2200
Wire Wire Line
	3750 1700 3750 2200
Wire Wire Line
	3750 2200 3250 2200
Connection ~ 3250 2200
Wire Notes Line
	600  650  4700 650 
Wire Notes Line
	4700 650  4700 2550
Wire Notes Line
	4700 2550 600  2550
Wire Notes Line
	600  2550 600  650 
Wire Notes Line
	5100 7500 500  7500
Wire Notes Line
	500  7500 500  5350
Wire Notes Line
	500  5350 5100 5350
Wire Notes Line
	5100 5350 5100 7500
Wire Notes Line
	4850 650  9000 650 
Wire Notes Line
	9000 650  9000 2550
Wire Notes Line
	9000 2550 4850 2550
Wire Notes Line
	4850 2550 4850 650 
Text Notes 2250 650  0    50   ~ 10
Potentiometer\n
Text Notes 6650 650  0    50   ~ 10
Slider\n
Text Notes 1550 5350 0    50   ~ 10
Switch\n
Text Notes 8850 3350 0    89   ~ 18
When you place a controller,\nyou have to choose between \nPotentiometer, Slider or switch
$Comp
L Analog_ADC:MCP3008 U1
U 1 1 61489274
P 6400 4850
F 0 "U1" H 6400 5531 50  0000 C CNN
F 1 "MCP3008" H 6400 5440 50  0000 C CNN
F 2 "Package_DIP:DIP-16_W7.62mm_Socket_LongPads" H 6500 4950 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/21295d.pdf" H 6500 4950 50  0001 C CNN
	1    6400 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	7750 5050 7400 5050
Wire Wire Line
	7000 5050 7400 5050
Connection ~ 7400 5050
Wire Wire Line
	7400 5350 7400 5650
Wire Wire Line
	7400 5650 6600 5650
Connection ~ 6600 5650
$EndSCHEMATC