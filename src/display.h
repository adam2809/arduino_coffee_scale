#ifndef _DISPLAY_H_
#define _DISPLAY_H_

#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <limits.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define GRAM_DISPLAY_X 0
#define GRAM_DISPLAY_Y 5
#define TIME_DISPLAY_X 0
#define TIME_DISPLAY_Y 35

class Scale_SSD1306 : public Adafruit_SSD1306{
    public:
        Scale_SSD1306(
            uint8_t w, uint8_t h, TwoWire *twi = &Wire,
            int8_t rst_pin = -1, uint32_t clkDuring = 400000UL,
            uint32_t clkAfter = 100000UL
        ):Adafruit_SSD1306(
            w,h,twi,
            rst_pin,clkDuring,
            clkAfter
        ){};

        void setup();
        void display_text(char* txt);
        void display_grams(float grams_avg);

};
#endif