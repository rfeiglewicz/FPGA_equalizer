#ifndef IIC_AXI_SSM2603_HEADER
#define IIC_AXI_SSM2603_HEADER

#include"xiic.h"
#include "xparameters.h"

#define SSM2603_IIC_SLAVE_ADDR 0x1A //for Zybo 0b0011010
#define IIC_DEVICE_ID XPAR_IIC_0_DEVICE_ID
#define IIC_BASE_ADDR XPAR_IIC_0_BASEADDR


//define address register  of sm2603 driver
#define L_CHANNEL_ADC_INPUT_VOLUME_REG 0x00
#define R_CHANNEL_ADC_INPUT_VOLUME_REG 0x01
#define L_CHANNEL_DAC_VOLUME_REG       0x02
#define R_CHANNEL_DAC_VOLUME_REG       0x03
#define ANALOG_AUDIO_PATH_REG          0x04
#define DIGITAL_AUDIO_PATH_REG         0x05
#define POWER_MANAGEMENT_REG           0x06
#define DIGITAL_AUDIO_IF_REG           0x07
#define SAMPLING_RATE_REG              0x08
#define ACTIVE_REG                     0x09
#define SOFTWARE_RESET_REG             0x0F
#define ALC_CONTROL_1_REG              0x10
#define ALC_CONTROL_2_REG              0x11
#define NOISE_GATE_REG                 0x12

int axi_iic_master_initialize(void);

int axi_ssm2603_init_codec(void);

XStatus fnAudioWriteToReg(u8 u8RegAddr, u16 u8Data);












#endif //end header of iic sm2603 driver
