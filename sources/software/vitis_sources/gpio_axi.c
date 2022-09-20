


#include "gpio_axi.h"


static XGpio         XGpio0Inst;
static XGpio 		*p_XGpio0Inst = &XGpio0Inst;


int axi_led_init(void){
	int status;

	XGpio_Config *p_XGpio0Cfg = NULL;


	//Start config

	 p_XGpio0Cfg = XGpio_LookupConfig(AXI_GPIO_LED_ID);
	 if (p_XGpio0Cfg == NULL)
	 {
		 status = XST_FAILURE;
		 return status;
	 }
	 status = XGpio_CfgInitialize(p_XGpio0Inst, p_XGpio0Cfg, p_XGpio0Cfg->BaseAddress);
	 if (status != XST_SUCCESS)
	 {
	 		 return status;
	 }

	 //set channel as output

	 XGpio_SetDataDirection(p_XGpio0Inst, AXI_GPIO_LED_OP_CHANNEL, 0);
	 //start cleaning
	 axi_led_clear(LED0);
	 axi_led_clear(LED1);
	 axi_led_clear(LED2);
	 axi_led_clear(LED3);
	 return status;

}

void axi_led_set(AxiGpio_led_out_t pin){

	XGpio_DiscreteSet(p_XGpio0Inst, AXI_GPIO_LED_OP_CHANNEL, (1 << pin));

}


void axi_led_clear(AxiGpio_led_out_t pin){

	XGpio_DiscreteClear(p_XGpio0Inst, AXI_GPIO_LED_OP_CHANNEL, (1 << pin));

}
