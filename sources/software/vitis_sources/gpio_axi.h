

#ifndef GPIO_AXI_HEADER
#define GPIO_AXI_HEADER

#include "xgpio.h"



#define AXI_GPIO_LED_ID XPAR_AXI_GPIO_0_DEVICE_ID

#define AXI_GPIO_LED_OP_CHANNEL 1U
// LED's are on 1 channel


typedef enum {
	LED0,LED1,LED2,LED3
}AxiGpio_led_out_t;


int axi_led_init(void);

void axi_led_set(AxiGpio_led_out_t pin);
void axi_led_clear(AxiGpio_led_out_t pin);

#endif //end of gpio axi header file
