#include <stdint.h>

extern void clock_init(void);
extern void adc_init(void);
extern uint32_t adc_read(void);
extern void led_init(void);
extern void led_control(void);

uint32_t val;

int main() {
	clock_init();
	led_init();
	adc_init();

	while (1) {
		val = adc_read();
		led_control();
		(void)val;
	}

	return 0;
}


