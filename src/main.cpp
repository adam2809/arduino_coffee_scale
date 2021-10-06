#include <Arduino.h>

/*
 Example using the SparkFun HX711 breakout board with a scale
 By: Nathan Seidle
 SparkFun Electronics
 Date: November 19th, 2014
 License: This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).
 
 This is the calibration sketch. Use it to determine the calibration_factor that the main example uses. It also
 outputs the zero_factor useful for projects that have a permanent mass on the scale in between power cycles.
 
 Setup your scale and start the sketch WITHOUT a weight on the scale
 Once readings are displayed place the weight on the scale
 Press +/- or a/z to adjust the calibration_factor until the output readings match the known weight
 Use this calibration_factor on the example sketch
 
 This example assumes pounds (lbs). If you prefer kilograms, change the Serial.print(" lbs"); line to kg. The
 calibration factor will be significantly different but it will be linearly related to lbs (1 lbs = 0.453592 kg).
 
 Your calibration factor may be very positive or very negative. It all depends on the setup of your scale system
 and the direction the sensors deflect from zero state
 This example code uses bogde's excellent library:"https://github.com/bogde/HX711"
 bogde's library is released under a GNU GENERAL PUBLIC LICENSE
 Arduino pin 2 -> HX711 CLK
 3 -> DOUT
 5V -> VCC
 GND -> GND

 Most any pin on the Arduino Uno will be compatible with DOUT/CLK.

 The HX711 board can be powered from 2.7V to 5V so the Arduino 5V power should be fine.

*/

#include "HX711.h"
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define LOADCELL_DOUT_PIN  6
#define LOADCELL_SCK_PIN  5

#define AVG_TIMES 20

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

HX711 scale;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

float calibration_factor = 819;

void setup_scale(){
	scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
	scale.set_scale();
	scale.tare();
}

void setup_display(){
	if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
		Serial.println(F("SSD1306 allocation failed"));
		for(;;);
	}
	display.setRotation(0);
	display.clearDisplay();
	display.setTextSize(3); 
	display.setTextColor(WHITE);
}

void setup() {
	Serial.begin(9600);
	Serial.println("Press + or a to increase calibration factor");
	Serial.println("Press - or z to decrease calibration factor");

	setup_scale();
	setup_display();
}

void manual_calibration_serial_input(){
	if(Serial.available()){
		char temp = Serial.read();
		Serial.print("Reading char: ");
		Serial.println(temp);

		if(temp == '+' || temp == 'a')
			calibration_factor += 1;
		else if(temp == '-' || temp == 'z')
			calibration_factor -= 1;
		else if(temp == 't')
		scale.tare();
	}

	scale.set_scale(calibration_factor); 
}

void display_grams(){
	float grams = scale.get_units(AVG_TIMES);
	Serial.print("Reading: ");
	Serial.print(grams, 3);
	Serial.print(" g"); //Change this to kg and re-adjust the calibration factor if you follow SI units like a sane person
	Serial.print(" calibration_factor: ");
	Serial.print(calibration_factor);
	Serial.println();

	char str_grams_tmp[6] = {0};
	char str_grams[6] = {0};

	dtostrf(grams, 4, 1, str_grams_tmp);
	sprintf(str_grams,"%s G", str_grams_tmp);

	display.setTextSize(3); 
	display.setTextColor(WHITE);
	display.setCursor(0, 5);
	display.println(str_grams);
	display.display();
	display.clearDisplay();
}

void loop() {
	display_grams();

	manual_calibration_serial_input();	
}