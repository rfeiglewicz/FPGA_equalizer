#include"axi_iic_ssm2603_driver.h"



XIic IicInstance;	/* The instance of the IIC device. */

int axi_iic_master_initialize(void){
	int Status;
	XIic_Config *ConfigPtr;	/* Pointer to configuration data */

	/*
	 * Initialize the IIC driver so that it is ready to use.
	 */
	ConfigPtr = XIic_LookupConfig(IIC_DEVICE_ID);
	if (ConfigPtr == NULL) {
		return XST_FAILURE;
	}

	Status = XIic_CfgInitialize(&IicInstance, ConfigPtr,
			ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
int axi_ssm2603_init_codec(void){
	int status = XST_SUCCESS;

	status |=fnAudioWriteToReg(L_CHANNEL_ADC_INPUT_VOLUME_REG, 0b000010111);
	status |=fnAudioWriteToReg(R_CHANNEL_ADC_INPUT_VOLUME_REG, 0b000010111);
	status |=fnAudioWriteToReg(L_CHANNEL_DAC_VOLUME_REG, 0b001110001);
	status |=fnAudioWriteToReg(R_CHANNEL_DAC_VOLUME_REG, 0b001110001);
	status |=fnAudioWriteToReg(ANALOG_AUDIO_PATH_REG, 	 0b000010010);
	status |=fnAudioWriteToReg(DIGITAL_AUDIO_PATH_REG, 	0b000000000);
	status |=fnAudioWriteToReg(POWER_MANAGEMENT_REG, 	0b000000000);
	status |=fnAudioWriteToReg(DIGITAL_AUDIO_IF_REG,	0b000001010);
	status |=fnAudioWriteToReg(SAMPLING_RATE_REG, 		0b000000000);
	status |=fnAudioWriteToReg(ALC_CONTROL_1_REG, 		0b001111011);
	status |=fnAudioWriteToReg(ALC_CONTROL_2_REG, 		0b000110010);
	status |=fnAudioWriteToReg(NOISE_GATE_REG, 		    0b011111010);

	status |=fnAudioWriteToReg(ACTIVE_REG, 				0b000000001);
	return status;
}


XStatus fnAudioWriteToReg(u8 u8RegAddr, u16 u8Data) {
		u8 u8TxData[2];
		u8 u8BytesSent;

		u8TxData[0] = u8RegAddr << 1;
		u8TxData[0] = u8TxData[0] | ((u8Data>>8) & 0b1);

		u8TxData[1] = u8Data & 0xFF;

		u8BytesSent = XIic_Send(IIC_BASE_ADDR, SSM2603_IIC_SLAVE_ADDR, u8TxData, 2, XIIC_STOP);
		//check if all the bytes where sent
		if (u8BytesSent != 2)
		{
			return XST_FAILURE;
		}

		return XST_SUCCESS;
}

