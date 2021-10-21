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
#include <limits.h>
#include <deque>

#define LOADCELL_DOUT_PIN  6
#define LOADCELL_SCK_PIN  5

#define AVG_TIMES 1
#define AVG_FILTER_SIZE 5

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define GRAM_DISPLAY_X 0
#define GRAM_DISPLAY_Y 5
#define TIME_DISPLAY_X 0
#define TIME_DISPLAY_Y 35

#define DOUBLE_CLICKS_MAX_GAP 300

HX711 scale;
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

struct button_t{
	bool is_clicked;
	unsigned long last_clicked;
	bool is_single_clicked;
	int pin;
};
button_t button{
	false,
	0,
	false,
	2
};

unsigned long timer_start_millis = ULONG_MAX;

float calibration_factor = 819;
std::deque<float> gram_vals_for_avg;

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

void button_click_cb(){
	Serial.println("Interrupt");
	button.is_clicked = true;
}

void setup() {
	Serial.begin(9600);
	Serial.println("Press + or a to increase calibration factor");
	Serial.println("Press - or z to decrease calibration factor");

	setup_scale();
	setup_display();
	pinMode(INPUT_PULLUP,button.pin);
	attachInterrupt(digitalPinToInterrupt(button.pin), button_click_cb, FALLING);
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

float get_avg_filter_value(){
	float sum = 0.0;
	for (int i = 0; i < gram_vals_for_avg.size(); i++){
		sum+=gram_vals_for_avg[i];
	}
	return sum/gram_vals_for_avg.size();
}

void display_grams(){
	float grams_avg = get_avg_filter_value();
	Serial.print("Avg grams: ");Serial.print(grams_avg);Serial.println();

	char str_grams_tmp[7] = {0};
	char str_grams[7] = {0};
	char minus_or_not;

	if (grams_avg < 0){
		grams_avg*=-1;
		minus_or_not = '-';
	}else{
		minus_or_not = ' ';
	}

	if(grams_avg >= 1000){
		grams_avg = 999.9;
	}

	dtostrf(grams_avg, 3, 1, str_grams_tmp);
	Serial.print("Avg grams str len: ");Serial.print(strlen(str_grams_tmp));Serial.println();
	sprintf(str_grams,"%c%s",minus_or_not ,str_grams_tmp);

	display.setCursor(GRAM_DISPLAY_X, GRAM_DISPLAY_Y);
	display.println(str_grams);
	display.display();
	display.clearDisplay();
}

void display_time(){
	long millis_to_display;
	if (timer_start_millis == ULONG_MAX){
		millis_to_display = 0;
	}else{
		millis_to_display = millis() - timer_start_millis;
	}
	int seconds_to_display = (millis_to_display/1000)%60;
	int minutes_to_display = (millis_to_display/1000)/60;
	char str_time[7] = {0};
	snprintf(str_time,7," %02d:%02d",minutes_to_display,seconds_to_display);
	display.setCursor(TIME_DISPLAY_X, TIME_DISPLAY_Y);
	display.println(str_time);	
}

void loop() {
	float grams = scale.get_units(AVG_TIMES);
	Serial.print("Reading: ");
	Serial.print(grams, 3);
	Serial.print(" g"); //Change this to kg and re-adjust the calibration factor if you follow SI units like a sane person
	Serial.print(" calibration_factor: ");
	Serial.print(calibration_factor);
	Serial.println();
	gram_vals_for_avg.push_front(grams);
	if (gram_vals_for_avg.size() > AVG_FILTER_SIZE){
		gram_vals_for_avg.pop_back();
	}
	
	
	display_grams();
	display_time();

	unsigned long curr_millis = millis();

	if (button.is_single_clicked && curr_millis - button.last_clicked > DOUBLE_CLICKS_MAX_GAP){
		Serial.println("Taring");
		scale.tare();
		button.is_single_clicked = false;
	}
	if(button.is_clicked){
		Serial.println("Clicked");
		if(curr_millis - button.last_clicked > DOUBLE_CLICKS_MAX_GAP){
			if (!button.is_single_clicked){
				Serial.println("Single click");
				button.is_single_clicked = true;
			}
		}else{
			Serial.println("Double click");
			timer_start_millis = curr_millis;
			button.is_single_clicked = false;
		}
		button.last_clicked = curr_millis;
		button.is_clicked = false;
	}

	manual_calibration_serial_input();
}