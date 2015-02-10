EESchema Schematic File Version 2
LIBS:FDN304P
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:resistor
LIBS:uSD_holder
LIBS:tvsd
LIBS:FG6943010R
LIBS:buzzer
LIBS:irf7910
LIBS:a2235-h
LIBS:alpha_trx433s
LIBS:quarter_wave_ant
LIBS:rfm69w
LIBS:adp3335
LIBS:adxl345
LIBS:hmc5883l
LIBS:l3g4200d
LIBS:ms5611-01ba03
LIBS:stm32f405vgt
LIBS:swd
LIBS:avionics-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 7
Title "Avionics Board M14"
Date "23 jan 2015"
Rev "1"
Comp "CU Spaceflight"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 5200 4600 750  1100
U 545BA057
F0 "Radio" 60
F1 "radio.sch" 60
F2 "RX" I L 5200 5500 60 
F3 "TX" O L 5200 5600 60 
F4 "RADIO_CS" I L 5200 4700 60 
F5 "RADIO_MOSI" I L 5200 4800 60 
F6 "RADIO_MISO" O L 5200 4900 60 
F7 "RADIO_CLK" I L 5200 5000 60 
F8 "RADIO_IRQ" O L 5200 5100 60 
F9 "GPS_ON/OFF" I L 5200 5300 60 
F10 "GPS_nRST" I L 5200 5400 60 
$EndSheet
$Sheet
S 5000 2450 1250 1700
U 545BA068
F0 "Datalogging & Pyros" 60
F1 "datalogging.sch" 60
F2 "PY1_TRG" I L 5000 2550 60 
F3 "PY2_TRG" I L 5000 2650 60 
F4 "PY3_TRG" I L 5000 2750 60 
F5 "PY4_TRG" I L 5000 2850 60 
F6 "~PY1_CHK" O L 5000 3000 60 
F7 "~PY2_CHK" O L 5000 3100 60 
F8 "~PY3_CHK" O L 5000 3200 60 
F9 "~PY4_CHK" O L 5000 3300 60 
F10 "µSD_DAT0" B L 5000 3450 60 
F11 "µSD_DAT1" B L 5000 3550 60 
F12 "µSD_DAT2" B L 5000 3650 60 
F13 "µSD_DAT3" B L 5000 3750 60 
F14 "µSD_CLK" I L 5000 3850 60 
F15 "µSD_CMD" B L 5000 3950 60 
F16 "µSD_CD" O L 5000 4050 60 
F17 "PY_OK" I R 6250 2550 60 
F18 "IMU_OK" I R 6250 2650 60 
F19 "RADIO_OK" I R 6250 2750 60 
F20 "BUZZER" I R 6250 3150 60 
F21 "~RADIO_OK" I R 6250 2850 60 
F22 "~IMU_OK" I R 6250 2950 60 
F23 "~PY_OK" I R 6250 3050 60 
$EndSheet
$Sheet
S 7550 3950 800  2000
U 545BA07E
F0 "Inertial Measurement" 60
F1 "imu.sch" 60
F2 "ACCEL_INT" O L 7550 4050 60 
F3 "ACCEL_CS" I L 7550 4150 60 
F4 "ACCEL_MISO" O L 7550 4250 60 
F5 "ACCEL_MOSI" I L 7550 4350 60 
F6 "ACCEL_SCK" I L 7550 4450 60 
F7 "GYRO_SCL" I L 7550 4650 60 
F8 "GYRO_SDA" B L 7550 4750 60 
F9 "GYRO_DRDY" O L 7550 4850 60 
F10 "BARO_SCK" I L 7550 5050 60 
F11 "BARO_MOSI" I L 7550 5150 60 
F12 "BARO_MISO" O L 7550 5250 60 
F13 "BARO_CS" I L 7550 5350 60 
F14 "MAGNO_SCL" I L 7550 5550 60 
F15 "MAGNO_SDA" B L 7550 5650 60 
F16 "MAGNO_DRDY" O L 7550 5750 60 
$EndSheet
Text Notes 600  900  0    250  ~ 0
Avionics Project 2014/15
$Comp
L STM32F405VGT IC?
U 1 1 54D92A29
P 1050 1450
F 0 "IC?" H 2150 1450 60  0000 C CNN
F 1 "STM32F405VGT" H 1500 1450 60  0000 C CNN
F 2 "" H 1050 1450 60  0000 C CNN
F 3 "" H 1050 1450 60  0000 C CNN
	1    1050 1450
	1    0    0    -1  
$EndComp
$Comp
L SWD P?
U 1 1 54D92A54
P 3600 7050
F 0 "P?" H 3850 7350 60  0000 C CNN
F 1 "SWD" H 3300 7350 60  0000 C CNN
F 2 "" H 3950 6850 60  0000 C CNN
F 3 "" H 3950 6850 60  0000 C CNN
	1    3600 7050
	1    0    0    -1  
$EndComp
$Comp
L ADP3335 IC?
U 1 1 54D92A97
P 7000 1500
F 0 "IC?" H 6800 1200 60  0000 C CNN
F 1 "ADP3335" H 6950 1700 60  0000 C CNN
F 2 "" H 7400 1100 60  0000 C CNN
F 3 "" H 7400 1100 60  0000 C CNN
	1    7000 1500
	1    0    0    -1  
$EndComp
$Comp
L +BATT #PWR?
U 1 1 54D992C4
P 6550 1350
F 0 "#PWR?" H 6550 1200 60  0001 C CNN
F 1 "+BATT" H 6550 1490 60  0000 C CNN
F 2 "" H 6550 1350 60  0000 C CNN
F 3 "" H 6550 1350 60  0000 C CNN
	1    6550 1350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 54D992FF
P 6550 1750
F 0 "#PWR?" H 6550 1500 60  0001 C CNN
F 1 "GND" H 6550 1600 60  0000 C CNN
F 2 "" H 6550 1750 60  0000 C CNN
F 3 "" H 6550 1750 60  0000 C CNN
	1    6550 1750
	1    0    0    -1  
$EndComp
$Comp
L +3V3 #PWR?
U 1 1 54D9931E
P 7450 1350
F 0 "#PWR?" H 7450 1200 60  0001 C CNN
F 1 "+3V3" H 7450 1490 60  0000 C CNN
F 2 "" H 7450 1350 60  0000 C CNN
F 3 "" H 7450 1350 60  0000 C CNN
	1    7450 1350
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 54D99379
P 7650 1700
F 0 "C?" H 7700 1800 50  0000 L CNN
F 1 "1n" H 7700 1600 50  0000 L CNN
F 2 "" H 7688 1550 30  0000 C CNN
F 3 "" H 7650 1700 60  0000 C CNN
	1    7650 1700
	0    1    1    0   
$EndComp
$Comp
L CONN_01X02 P?
U 1 1 54D9948C
P 6200 1650
F 0 "P?" H 6200 1800 50  0000 C CNN
F 1 "CONN_01X02" V 6300 1650 50  0000 C CNN
F 2 "" H 6200 1650 60  0000 C CNN
F 3 "" H 6200 1650 60  0000 C CNN
	1    6200 1650
	-1   0    0    1   
$EndComp
$Comp
L C C?
U 1 1 54D9976E
P 6300 1050
F 0 "C?" H 6350 1150 50  0000 L CNN
F 1 "2µ2" H 6350 950 50  0000 L CNN
F 2 "" H 6338 900 30  0000 C CNN
F 3 "" H 6300 1050 60  0000 C CNN
	1    6300 1050
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 54D9978D
P 8050 1500
F 0 "C?" H 8100 1600 50  0000 L CNN
F 1 "2µ2" H 8100 1400 50  0000 L CNN
F 2 "" H 8088 1350 30  0000 C CNN
F 3 "" H 8050 1500 60  0000 C CNN
	1    8050 1500
	1    0    0    -1  
$EndComp
$Comp
L +BATT #PWR?
U 1 1 54D9986F
P 6300 800
F 0 "#PWR?" H 6300 650 60  0001 C CNN
F 1 "+BATT" H 6300 940 60  0000 C CNN
F 2 "" H 6300 800 60  0000 C CNN
F 3 "" H 6300 800 60  0000 C CNN
	1    6300 800 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 54D99881
P 6300 1300
F 0 "#PWR?" H 6300 1050 60  0001 C CNN
F 1 "GND" H 6300 1150 60  0000 C CNN
F 2 "" H 6300 1300 60  0000 C CNN
F 3 "" H 6300 1300 60  0000 C CNN
	1    6300 1300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 54D999F2
P 8050 1750
F 0 "#PWR?" H 8050 1500 60  0001 C CNN
F 1 "GND" H 8050 1600 60  0000 C CNN
F 2 "" H 8050 1750 60  0000 C CNN
F 3 "" H 8050 1750 60  0000 C CNN
	1    8050 1750
	1    0    0    -1  
$EndComp
Text Notes 6050 2100 0    60   ~ 0
POWER REGULATION
Text Label 4200 6850 0    60   ~ 0
SWDIO
NoConn ~ 4050 7150
$Comp
L GND #PWR?
U 1 1 54DAC1BA
P 2850 7400
F 0 "#PWR?" H 2850 7150 60  0001 C CNN
F 1 "GND" H 2850 7250 60  0000 C CNN
F 2 "" H 2850 7400 60  0000 C CNN
F 3 "" H 2850 7400 60  0000 C CNN
	1    2850 7400
	1    0    0    -1  
$EndComp
Text Label 4200 6950 0    60   ~ 0
SWDCLK
Text Label 4200 7050 0    60   ~ 0
SWO
$Comp
L +3V3 #PWR?
U 1 1 54DBBA22
P 2850 6850
F 0 "#PWR?" H 2850 6700 60  0001 C CNN
F 1 "+3V3" H 2850 6990 60  0000 C CNN
F 2 "" H 2850 6850 60  0000 C CNN
F 3 "" H 2850 6850 60  0000 C CNN
	1    2850 6850
	1    0    0    -1  
$EndComp
Text Label 850  5550 2    60   ~ 0
SWDCLK
Text Label 4200 7250 0    60   ~ 0
nReset
Text Label 800  3650 2    60   ~ 0
nReset
Text Label 850  5450 2    60   ~ 0
SWDIO
Text Label 850  6150 2    60   ~ 0
SWO
Text Label 4900 4700 2    60   ~ 0
RADIO_CS
Wire Wire Line
	6550 1350 6550 1600
Wire Wire Line
	6550 1400 6650 1400
Wire Wire Line
	6550 1500 6650 1500
Connection ~ 6550 1400
Wire Wire Line
	6400 1600 6650 1600
Connection ~ 6550 1500
Wire Wire Line
	6400 1700 6650 1700
Wire Wire Line
	6550 1700 6550 1750
Wire Wire Line
	7350 1400 7950 1400
Wire Wire Line
	7450 1350 7450 1600
Wire Wire Line
	7350 1500 7850 1500
Connection ~ 7450 1400
Wire Wire Line
	7450 1600 7350 1600
Connection ~ 7450 1500
Wire Wire Line
	7350 1700 7450 1700
Wire Wire Line
	7850 1500 7850 1700
Connection ~ 6550 1600
Connection ~ 6550 1700
Wire Wire Line
	6300 1250 6300 1300
Wire Wire Line
	6300 800  6300 850 
Wire Wire Line
	7950 1400 7950 1300
Wire Wire Line
	7950 1300 8050 1300
Wire Wire Line
	8050 1700 8050 1750
Wire Notes Line
	6000 500  6000 2150
Wire Notes Line
	6000 2150 8350 2150
Wire Notes Line
	8350 2150 8350 500 
Wire Notes Line
	8350 500  6000 500 
Wire Wire Line
	4050 6850 4200 6850
Wire Wire Line
	2850 6950 2850 7400
Connection ~ 3100 7250
Wire Wire Line
	3100 7250 2850 7250
Wire Wire Line
	3100 7050 2850 7050
Connection ~ 2850 7250
Wire Wire Line
	3100 6950 2850 6950
Connection ~ 2850 7050
Wire Wire Line
	4050 6950 4200 6950
Wire Wire Line
	4050 7050 4200 7050
Wire Wire Line
	4050 7250 4200 7250
Wire Wire Line
	3100 6850 2850 6850
Wire Wire Line
	2350 2150 2550 2150
Wire Wire Line
	1050 5550 850  5550
Wire Wire Line
	1050 3650 800  3650
Wire Wire Line
	1050 5450 850  5450
Wire Wire Line
	850  6150 1050 6150
Wire Wire Line
	5200 4700 4900 4700
Wire Wire Line
	5200 4800 4900 4800
Text Label 4900 4800 2    60   ~ 0
RADIO_MOSI
Wire Wire Line
	5200 4900 4900 4900
Text Label 4900 4900 2    60   ~ 0
RADIO_MISO
Wire Wire Line
	5200 5000 4900 5000
Text Label 4900 5000 2    60   ~ 0
RADIO_CLK
Wire Wire Line
	5200 5100 4900 5100
Text Label 4900 5100 2    60   ~ 0
RADIO_IRQ
Wire Wire Line
	5200 5300 4900 5300
Text Label 4900 5300 2    60   ~ 0
GPS_ON/OFF
Wire Wire Line
	5200 5400 4900 5400
Text Label 4900 5400 2    60   ~ 0
GPS_nRST
Wire Wire Line
	5200 5500 4900 5500
Text Label 4900 5500 2    60   ~ 0
RX
Wire Wire Line
	5200 5600 4900 5600
Text Label 4900 5600 2    60   ~ 0
TX
Wire Wire Line
	7550 4050 7350 4050
Text Label 7350 4050 2    60   ~ 0
ACCEL_INT
Wire Wire Line
	7550 4150 7350 4150
Text Label 7350 4150 2    60   ~ 0
ACCEL_CS
Wire Wire Line
	7550 4250 7350 4250
Text Label 7350 4250 2    60   ~ 0
ACCEL_MISO
Wire Wire Line
	7550 4350 7350 4350
Text Label 7350 4350 2    60   ~ 0
ACCEL_MOSI
Wire Wire Line
	7550 4450 7350 4450
Text Label 7350 4450 2    60   ~ 0
ACCEL_SCK
Wire Wire Line
	7550 4650 7350 4650
Text Label 7350 4650 2    60   ~ 0
GYRO_SCL
Wire Wire Line
	7550 4750 7350 4750
Text Label 7350 4750 2    60   ~ 0
GYRO_SDA
Wire Wire Line
	7550 4850 7350 4850
Text Label 7350 4850 2    60   ~ 0
GYRO_DRDY
Wire Wire Line
	7550 5050 7350 5050
Text Label 7350 5050 2    60   ~ 0
BARO_SCK
Wire Wire Line
	7550 5150 7350 5150
Text Label 7350 5150 2    60   ~ 0
BARO_MOSI
Wire Wire Line
	7550 5250 7350 5250
Text Label 7350 5250 2    60   ~ 0
BARO_MISO
Wire Wire Line
	7550 5350 7350 5350
Text Label 7350 5350 2    60   ~ 0
BARO_CS
Wire Wire Line
	7550 5550 7350 5550
Text Label 7350 5550 2    60   ~ 0
MAGNO_SCL
Wire Wire Line
	7550 5650 7350 5650
Text Label 7350 5650 2    60   ~ 0
MAGNO_SDA
Wire Wire Line
	7550 5750 7350 5750
Text Label 7350 5750 2    60   ~ 0
MAGNO_DRDY
Wire Wire Line
	6250 2550 6400 2550
Text Label 6400 2550 0    60   ~ 0
PY_OK
Wire Wire Line
	6250 2650 6400 2650
Text Label 6400 2650 0    60   ~ 0
IMU_OK
Wire Wire Line
	6250 2750 6400 2750
Text Label 6400 2750 0    60   ~ 0
RADIO_OK
Wire Wire Line
	6250 2850 6400 2850
Text Label 6400 2850 0    60   ~ 0
~RADIO_OK
Wire Wire Line
	6250 2950 6400 2950
Text Label 6400 2950 0    60   ~ 0
~IMU_OK
Wire Wire Line
	6250 3050 6400 3050
Text Label 6400 3050 0    60   ~ 0
~PY_OK
Wire Wire Line
	6250 3150 6400 3150
Text Label 6400 3150 0    60   ~ 0
BUZZER
Wire Wire Line
	5000 2550 4850 2550
Text Label 4850 2550 2    60   ~ 0
PY1_TRG
Wire Wire Line
	5000 2650 4850 2650
Text Label 4850 2650 2    60   ~ 0
PY2_TRG
Wire Wire Line
	5000 2750 4850 2750
Text Label 4850 2750 2    60   ~ 0
PY3_TRG
Wire Wire Line
	5000 2850 4850 2850
Text Label 4850 2850 2    60   ~ 0
PY4_TRG
Wire Wire Line
	5000 3000 4850 3000
Text Label 4850 3000 2    60   ~ 0
~PY1_CHK
Wire Wire Line
	5000 3100 4850 3100
Text Label 4850 3100 2    60   ~ 0
~PY2_CHK
Wire Wire Line
	5000 3200 4850 3200
Text Label 4850 3200 2    60   ~ 0
~PY3_CHK
Wire Wire Line
	5000 3300 4850 3300
Text Label 4850 3300 2    60   ~ 0
~PY4_CHK
Wire Wire Line
	5000 3450 4850 3450
Text Label 4850 3450 2    60   ~ 0
µSD_DAT0
Wire Wire Line
	5000 3550 4850 3550
Text Label 4850 3550 2    60   ~ 0
µSD_DAT1
Wire Wire Line
	5000 3650 4850 3650
Text Label 4850 3650 2    60   ~ 0
µSD_DAT2
Wire Wire Line
	5000 3750 4850 3750
Text Label 4850 3750 2    60   ~ 0
µSD_DAT3
Wire Wire Line
	5000 3850 4850 3850
Text Label 4850 3850 2    60   ~ 0
µSD_CLK
Wire Wire Line
	5000 3950 4850 3950
Text Label 4850 3950 2    60   ~ 0
µSD_CMD
Wire Wire Line
	5000 4050 4850 4050
Text Label 4850 4050 2    60   ~ 0
µSD_CD
$Comp
L CONN_01X04 P?
U 1 1 54DE8EC0
P 6100 6600
F 0 "P?" H 6100 6850 50  0000 C CNN
F 1 "CONN_01X04" V 6200 6600 50  0000 C CNN
F 2 "" H 6100 6600 60  0000 C CNN
F 3 "" H 6100 6600 60  0000 C CNN
	1    6100 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 6450 5700 6450
$Comp
L +3V3 #PWR?
U 1 1 54DE9D86
P 5700 6450
F 0 "#PWR?" H 5700 6300 60  0001 C CNN
F 1 "+3V3" H 5700 6590 60  0000 C CNN
F 2 "" H 5700 6450 60  0000 C CNN
F 3 "" H 5700 6450 60  0000 C CNN
	1    5700 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 6750 5700 6750
Wire Wire Line
	5700 6750 5700 6850
$Comp
L GND #PWR?
U 1 1 54DEABCF
P 5700 6850
F 0 "#PWR?" H 5700 6600 60  0001 C CNN
F 1 "GND" H 5700 6700 60  0000 C CNN
F 2 "" H 5700 6850 60  0000 C CNN
F 3 "" H 5700 6850 60  0000 C CNN
	1    5700 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	5900 6550 5700 6550
Text Label 5700 6550 2    60   ~ 0
TX
Wire Wire Line
	5900 6650 5700 6650
Text Label 5700 6650 2    60   ~ 0
RX
$EndSCHEMATC
