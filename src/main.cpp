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
#include "display.h"

#define HX711_DOUT_PIN  6 //orange cable
#define HX711_SCK_PIN  5 //blue cable
// hx711 5v is red cable
// hx711 gnd is brown cable


#define AVG_TIMES 1
#define AVG_FILTER_SIZE 5

#define STEP_COUNT 6

#define DOUBLE_CLICKS_MAX_GAP 300

HX711 scale;
Scale_SSD1306 ssd1306(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

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

struct ingredient_t{
	float grams;
	char* name;
};
ingredient_t pancakes_recipie[STEP_COUNT] = {
	{112.0,"Eggs"},
	{161.0,"Buttermilk"},
	{28.2,"Butter"},
	{42.5,"Honey"},
	{65.0,"Flour"},
	{1.5,"Salt"}
};
int curr_step = 0;

void setup_scale(){
	scale.begin(HX711_DOUT_PIN, HX711_SCK_PIN);
	scale.set_scale();
	scale.tare();
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
	ssd1306.setup();
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

void detect_clicks(){
	unsigned long curr_millis = millis();

	if (!button.is_clicked && button.is_single_clicked && curr_millis - button.last_clicked > DOUBLE_CLICKS_MAX_GAP){
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
			curr_step++;
			button.is_single_clicked = false;
		}
		button.last_clicked = curr_millis;
		button.is_clicked = false;
	}
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
	
	ssd1306.display_grams(get_avg_filter_value());
	ssd1306.display_text(pancakes_recipie[curr_step].name);

	detect_clicks();

	manual_calibration_serial_input();
}