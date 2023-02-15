/* Author: Jacob Nguyen
 * Course: ECE3829
 * Project: Lab 4
 * Description: Starting project for Lab 4.
 * Implements two functions
 * 1- reading switches and lighting their corresponding LED
 * 2 - It outputs a middle C tone to the AMP2
 * It also initializes the anode and segment of the 7-seg display
 * for future development
 */


// Header Inclusions
/* xparameters.h set parameters names
 like XPAR_AXI_GPIO_0_DEVICE_ID that are referenced in you code
 each hardware module as a section in this file.
*/
#include "xparameters.h"
/* each hardware module type as a set commands you can use to
 * configure and access it. xgpio.h defines API commands for your gpio modules
 */
#include "xgpio.h"
/* this defines the recommend types like u32 */
#include "xil_types.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "sleep.h"
#include "xtmrctr.h"
#include "notes.h"

void check_switches(u32 *sw_data, u32 *sw_data_old, u32 *sw_changes);
void check_buttons(u32 *but_data, u32 *but_data_old, u32 *but_changes);
void update_LEDs(u32 led_data);
void update_amp2(u32 *amp2_data, u32 target_count, u32 *last_count);


// Block Design Details
/* Timer device ID
 */
#define TMRCTR_DEVICE_ID XPAR_TMRCTR_0_DEVICE_ID
#define TIMER_COUNTER_0 0


/* LED are assigned to GPIO (CH 1) GPIO_0 Device
 * DIP Switches are assigned to GPIO2 (CH 2) GPIO_0 Device
 */
#define GPIO0_ID XPAR_GPIO_0_DEVICE_ID
#define GPIO0_LED_CH 1
#define GPIO0_SW_CH 2
// 16-bits of LED outputs (not tristated)
#define GPIO0_LED_TRI 0x00000000
#define GPIO0_LED_MASK 0x0000FFFF
// 16-bits SW inputs (tristated)
#define GPIO0_SW_TRI 0x0000FFFF
#define GPIO0_SW_MASK 0x0000FFFF
#define GPIO0_MASK 0x00000003

/*  7-SEG Anodes are assigned to GPIO (CH 1) GPIO_1 Device
 *  7-SEG Cathodes are assined to GPIO (CH 2) GPIO_1 Device
 */
#define GPIO1_ID XPAR_GPIO_1_DEVICE_ID
#define GPIO1_ANODE_CH 1
#define GPIO1_CATHODE_CH 2
//4-bits of anode outputs (not tristated)
#define GPIO1_ANODE_TRI 0x00000000
#define GPIO1_ANODE_MASK 0x0000000F
//8-bits of cathode outputs (not tristated)
#define GPIO1_CATHODE_TRI 0x00000000
#define GPIO1_CATHODE_MASK 0x000000FF

// Push buttons are assigned to GPIO (CH_1) GPIO_2 Device
#define GPIO2_ID XPAR_GPIO_2_DEVICE_ID
#define GPIO2_BTN_CH 1
// 4-bits of push button (not tristated)
#define GPIO2_BTN_TRI 0x00000000
#define GPIO2_BTN_MASK 0x0000000F

// AMP2 pins are assigned to GPIO (CH1 1) GPIO_3 device
#define GPIO3_ID XPAR_GPIO_3_DEVICE_ID
#define GPIO3_AMP2_CH 1
#define GPIO3_AMP2_TRI 0xFFFFFFF4
#define GPIO3_AMP2_MASK 0x00000001


// Timer Device instance
XTmrCtr TimerCounter;

// GPIO Driver Device
XGpio device0;
XGpio device1;
XGpio device2;
XGpio device3;

// IP Tutorial  Main
int main() {
	u32 sw_data = 0;
	u32 sw_data_old = 0;
	u32 but_data = 0;
	u32 but_data_old = 0;
	// bit[3] = SHUTDOWN_L and bit[1] = GAIN, bit[0] = Audio Input
	u32 amp2_data = 0x8;
	u32 last_count = 0;
	u32 sw_changes = 0;
	u32 but_changes = 0;

	u32 target_count_C3 = 0xffffffff;
	u32 target_count_CS3 = 0xffffffff;
	u32 target_count_D3 = 0xffffffff;
	u32 target_count_DS3 = 0xffffffff;
	u32 target_count_E3 = 0xffffffff;
	u32 target_count_F3 = 0xffffffff;
	u32 target_count_FS3 = 0xffffffff;
	u32 target_count_G3 = 0xffffffff;
	u32 target_count_GS3 = 0xffffffff;
	u32 target_count_A3 = 0xffffffff;
	u32 target_count_AS3 = 0xffffffff;
	u32 target_count_B3 = 0xffffffff;
	u32 target_count_C4 = 0xffffffff;
	u32 target_count_CS4 = 0xffffffff;
	u32 target_count_D4 = 0xffffffff;
	u32 target_count_DS4 = 0xffffffff;
	u32 target_count_E4 = 0xffffffff;
	u32 target_count_F4 = 0xffffffff;
	u32 target_count_FS4 = 0xffffffff;
	u32 target_count_G4 = 0xffffffff;
	u32 target_count_GS4 = 0xffffffff;
	u32 target_count_A4 = 0xffffffff;
	u32 target_count_AS4 = 0xffffffff;
	u32 target_count_B4 = 0xffffffff;
	u32 target_count_C5 = 0xffffffff;
	u32 target_count_CS5 = 0xffffffff;
	u32 target_count_D5 = 0xffffffff;
	u32 target_count_DS5 = 0xffffffff;
	u32 target_count_NONE = 0xffffffff;

	u32 start_time = 0;
	u32 noteArray[] = {(1.0/(2.0*C4*10e-9)), (1.0/(2.0*E4*10e-9)), (1.0/(2.0*G4*10e-9)), (1.0/(2.0*C5*10e-9))};

	XStatus status;


	//Initialize timer
	status = XTmrCtr_Initialize(&TimerCounter, XPAR_TMRCTR_0_DEVICE_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization Timer failed\n\r");
		return 1;
	}
	//Make sure the timer is working
	status = XTmrCtr_SelfTest(&TimerCounter, TIMER_COUNTER_0);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization Timer failed\n\r");
		return 1;
	}
	//Configure the timer to Autoreload
	XTmrCtr_SetOptions(&TimerCounter, TIMER_COUNTER_0, XTC_AUTO_RELOAD_OPTION);
	//Initialize your timer values
	//Start your timer
	XTmrCtr_Start(&TimerCounter, TIMER_COUNTER_0);



	// Initialize the GPIO devices
	status = XGpio_Initialize(&device0, GPIO0_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization GPIO_0 failed\n\r");
		return 1;
	}
	status = XGpio_Initialize(&device1, GPIO1_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization GPIO_1 failed\n\r");
		return 1;
	}
	status = XGpio_Initialize(&device2, GPIO2_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization GPIO_2 failed\n\r");
		return 1;
	}
	status = XGpio_Initialize(&device3, GPIO3_ID);
	if (status != XST_SUCCESS) {
		xil_printf("Initialization GPIO_3 failed\n\r");
		return 1;
	}

	// Set directions for data ports tristates, '1' for input, '0' for output
	XGpio_SetDataDirection(&device0, GPIO0_LED_CH, GPIO0_LED_TRI);
	XGpio_SetDataDirection(&device0, GPIO0_SW_CH, GPIO0_SW_TRI);
	XGpio_SetDataDirection(&device1, GPIO1_ANODE_CH, GPIO1_ANODE_TRI);
	XGpio_SetDataDirection(&device1, GPIO1_CATHODE_CH, GPIO1_CATHODE_TRI);
	XGpio_SetDataDirection(&device2, GPIO2_BTN_CH, GPIO2_BTN_TRI);
	XGpio_SetDataDirection(&device3, GPIO3_AMP2_CH, GPIO3_AMP2_TRI);

	xil_printf("Demo initialized successfully\n\r");

	XGpio_DiscreteWrite(&device3, GPIO3_AMP2_CH, amp2_data);

	// this loop checks for changes in the input switches
	// if they changed it updates the LED outputs to match the switch values.
	// target_count = (period of sound)/(2*10nsec)), 10nsec is the processor clock frequency
	// example count is middle C (C4) = 191110 count (261.62 Hz)
	target_count_C3 = (1.0/(2.0*C3*10e-9));
	target_count_CS3 = (1.0/(2.0*CS3*10e-9));
	target_count_D3 = (1.0/(2.0*D3*10e-9));
	target_count_DS3 = (1.0/(2.0*DS3*10e-9));
	target_count_E3 = (1.0/(2.0*E3*10e-9));
	target_count_F3 = (1.0/(2.0*F3*10e-9));
	target_count_FS3 = (1.0/(2.0*FS3*10e-9));
	target_count_G3 = (1.0/(2.0*G3*10e-9));
	target_count_GS3 = (1.0/(2.0*GS3*10e-9));
	target_count_A3 = (1.0/(2.0*A3*10e-9));
	target_count_AS3 = (1.0/(2.0*AS3*10e-9));
	target_count_B3 = (1.0/(2.0*B3*10e-9));
	target_count_C4 = (1.0/(2.0*C4*10e-9));
	target_count_CS4 = (1.0/(2.0*CS4*10e-9));
	target_count_D4 = (1.0/(2.0*D4*10e-9));
	target_count_DS4 = (1.0/(2.0*DS4*10e-9));
	target_count_E4 = (1.0/(2.0*E4*10e-9));
	target_count_F4 = (1.0/(2.0*F4*10e-9));
	target_count_FS4 = (1.0/(2.0*FS4*10e-9));
	target_count_G4 = (1.0/(2.0*G4*10e-9));
	target_count_GS4 = (1.0/(2.0*GS4*10e-9));
	target_count_A4 = (1.0/(2.0*A4*10e-9));
	target_count_AS4 = (1.0/(2.0*AS4*10e-9));
	target_count_B4 = (1.0/(2.0*B4*10e-9));
	target_count_C5 = (1.0/(2.0*C5*10e-9));
	target_count_CS5 = (1.0/(2.0*CS5*10e-9));
	target_count_D5 = (1.0/(2.0*D5*10e-9));
	target_count_DS5 = (1.0/(2.0*DS5*10e-9));

	target_count_NONE = 0;
	int i;

	// Start up tune
	for (i = 0; i < 4; i++){
		start_time = XTmrCtr_GetValue(&TimerCounter, TIMER_COUNTER_0);
		while(start_time + 50000000 > XTmrCtr_GetValue(&TimerCounter, TIMER_COUNTER_0)){
			update_amp2(&amp2_data, noteArray[i], &last_count);
		}
	}

	while (1) {
		check_switches(&sw_data, &sw_data_old, &sw_changes);
		if (sw_changes) update_LEDs(sw_data);
		check_buttons(&but_data, &but_data_old, &but_changes);

		switch (sw_data & GPIO0_MASK){ // sw_data input
			case (0x00): // Octave 3
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
			switch (but_data & GPIO2_BTN_MASK){ // but_data inout
			case (0b001): // C3
				update_amp2(&amp2_data, target_count_C3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xC6);
				break;
			case (0b010): // D3
				update_amp2(&amp2_data, target_count_D3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xA1);
				break;
			case (0b011): // E3
				update_amp2(&amp2_data, target_count_E3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x86);
				break;
			case (0b100): // F3
				update_amp2(&amp2_data, target_count_F3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x8e);
				break;
			case (0b101): // G3
				update_amp2(&amp2_data, target_count_G3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x90);
				break;
			case (0b110): // A3
				update_amp2(&amp2_data, target_count_A3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xA0);
				break;
			case (0b111): // B3
				update_amp2(&amp2_data, target_count_B3, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x83);
				break;

			default: // Reset Default
				update_amp2(&amp2_data, target_count_NONE, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0x0);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
				break;
			}
			break;

		case (0x01): // Octave 4
			XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
			XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
			switch (but_data & GPIO2_BTN_MASK){ // but_data input
			case (0b001): // C4
				update_amp2(&amp2_data, target_count_C4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xC6);
				break;
			case (0b010): // D4
				update_amp2(&amp2_data, target_count_D4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xA1);
				break;
			case (0b011): // E4
				update_amp2(&amp2_data, target_count_E4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x86);
				break;
			case (0b100): // F4
				update_amp2(&amp2_data, target_count_F4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x8e);
			break;
			case (0b101): // G4
				update_amp2(&amp2_data, target_count_G4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x90);
				break;
			case (0b110): // A4
				update_amp2(&amp2_data, target_count_A4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xA0);
				break;
			case (0b111): // B4
				update_amp2(&amp2_data, target_count_B4, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0x83);
				break;

			default: // Reset Default
				update_amp2(&amp2_data, target_count_NONE, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0x0);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
				break;
			} // case
		break;

		case (0x02): // Octave 5
			XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
			XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
			switch (but_data & GPIO2_BTN_MASK){ // but_data input
			case (0b001): // C5
				update_amp2(&amp2_data, target_count_C5, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xC6);
				break;
			case (0b010): // D5
				update_amp2(&amp2_data, target_count_D5, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0xe);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xA1);
				break;

			default: // Reset Default
				update_amp2(&amp2_data, target_count_NONE, &last_count);
				XGpio_DiscreteWrite(&device1, GPIO1_ANODE_CH, 0x0);
				XGpio_DiscreteWrite(&device1, GPIO1_CATHODE_CH, 0xFF);
				break;
		} // case
		break;

		} // case
	} // while
} // main

// reads the value of the input switches and outputs if there were changes from last time
void check_switches(u32 *sw_data, u32 *sw_data_old, u32 *sw_changes) {
	*sw_data = XGpio_DiscreteRead(&device0, GPIO0_SW_CH);
	*sw_data &= GPIO0_SW_MASK;
	*sw_changes = 0;
	if (*sw_data != *sw_data_old) {
		// When any bswitch is toggled, the LED values are updated
		//  and report the state over UART.
		*sw_changes = *sw_data ^ *sw_data_old;
		*sw_data_old = *sw_data;
	}
}

void check_buttons(u32 *but_data, u32 *but_data_old, u32 *but_changes) {
	*but_data = XGpio_DiscreteRead(&device2, GPIO2_BTN_CH);
	*but_data &= GPIO2_BTN_MASK;
	*but_changes = 0;
	if (*but_data != *but_data_old) {
		*but_changes = *but_data ^ *but_data_old;
		*but_data_old = *but_data;
	}
}

// writes the value of led_data to the LED pins
void update_LEDs(u32 led_data) {
	led_data = (led_data) & GPIO0_LED_MASK;
	XGpio_DiscreteWrite(&device0, GPIO0_LED_CH, led_data);
}

// if the current count is - last_count > target_count toggle the amp2 output
void update_amp2(u32 *amp2_data, u32 target_count, u32 *last_count) {
	u32 current_count = XTmrCtr_GetValue(&TimerCounter, TIMER_COUNTER_0);
	if ((current_count - *last_count) > target_count) {
		// toggling the LSB of amp2 data
		*amp2_data = ((*amp2_data & 0x01) == 0) ? (*amp2_data | 0x1) : (*amp2_data & 0xe);
		XGpio_DiscreteWrite(&device3, GPIO3_AMP2_CH, *amp2_data );
		*last_count = current_count;
	}
}
