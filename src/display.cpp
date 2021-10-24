#include "display.h"

void Scale_SSD1306::setup(){
	if(!this->begin(SSD1306_SWITCHCAPVCC, 0x3C)) { 
		Serial.println(F("SSD1306 allocation failed"));
		for(;;);
	}
	this->setRotation(0);
	this->clearDisplay();
	this->setTextSize(3); 
	this->setTextColor(WHITE);
}

void Scale_SSD1306::display_text(char* txt){
	char str_time[7] = {0};
	snprintf(str_time,7,"%s",txt);
	this->setCursor(TIME_DISPLAY_X, TIME_DISPLAY_Y);
	this->println(str_time);	
}

void Scale_SSD1306::display_grams(float grams_avg){
	// Serial.print("Avg grams: ");Serial.print(grams_avg);Serial.println();

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
	// Serial.print("Avg grams str len: ");Serial.print(strlen(str_grams_tmp));Serial.println();
	sprintf(str_grams,"%c%s",minus_or_not ,str_grams_tmp);

	this->setCursor(GRAM_DISPLAY_X, GRAM_DISPLAY_Y);
	this->println(str_grams);
	this->display();
	this->clearDisplay();
}