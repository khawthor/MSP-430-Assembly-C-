#include <msp430.h>
//GLOBAL VARIABLES
//Lab 5
//Looop counter
int i=0;
int LOOPMAX=10;
//Light Variable
int light = 0;
int lightroom = 0;
//Temperature Variables
float temp = 0;
float temproom = 0;
//Touch Variables
int touch =0;
int touchroom = 0;
int togglePermis = 0;
//Array of Values of All 3 Sensors
int ADCReading[3];
//Timer Variables
int lightOn =0;
int tCounter =0;

void ConfigureAdc(void);

int main(void)
{
	///~ in front means LOW, without ~ means HIGH
	//FOR DIR 0 means input and 1 means output
	//& means AND operation | means OR operation 1 OR 0 =
	WDTCTL = WDTPW + WDTHOLD; // Stop WDT

	//Clearing the outputs of garbage values from previous run
	P1OUT &= ~(BIT4 | BIT5); //setting the outputs(LED 1 and LED 2) to zero
	P2OUT &= ~(BIT0); //will set LED 3 to zero

	//Specify the the ports whether they will be input or output
	P1DIR &= ~(BIT0 | BIT1 | BIT2); // set bits 0, 1, 2 as inputs
	P1DIR |= (BIT4 | BIT5);//setting to 1 to specify LED 1 and LED 2 as outputs
	P2DIR |= (BIT0);//setting to 1 to specify LED 3 as output

	ConfigureAdc();						//overhead to tell microcontroller how we want the setting to be

	//SETUP FOR TIMER
	TA0CCR0 = 12000;					// Count limit (16 bit) 12000 = 1 sec

	TA0CCTL0 = 0x10;					// Enable counter interrupts, bit 4=1

	TA0CTL = TASSEL_1 + MC_1; 			// Timer A0 with ACLK @ 12KHz, MC_1=count UP, TASSEL_1= speed is 12KHz

	// reading the initial room values, lightroom, touchroom, temoroom
	for(i=0; i<LOOPMAX ; i++)                                       // read all three analog values 5 times each and average
	{
	       ADC10CTL0 &= ~ENC;
	       while (ADC10CTL1 & BUSY);                              //Wait while ADC is busy
	       ADC10SA = (unsigned)&ADCReading[0]; 					  //RAM Address of ADC Data, must be reset every conversion
	       ADC10CTL0 |= (ENC | ADC10SC);                          //Start ADC Conversion
	       while (ADC10CTL1 & BUSY);                              //Wait while ADC is busy
	       light += ADCReading[0];
	       touch += ADCReading[1];
	       temp += ADCReading[2];  	// sum  all 10 reading for the three variables
	}
	lightroom = light/LOOPMAX;
	touchroom = touch/LOOPMAX;
	temproom = temp/LOOPMAX;          		// Average the 10 reading for the three variables
	temproom=((0.322227) * temproom);//Formula to convert to Farenheit= (3.3/1024 * 0.01) * temproom = (3.3/1024 * 1/10^-2)* temproom =
			//															  =(330/1024) * temproom => 0.32222227 *temproom

	for (;;)//infinite loop to keep looking for a some type of interrupt
	{
		temp = 0;
		light = 0;
		touch = 0; // set all analog values to zsero
		for (i = 0;i<LOOPMAX;i++)
		{
			//Reading ADC Values
			ADC10CTL0 &= ~ENC;// disable ADC1 so we can read vaues because it going fast
			while (ADC10CTL1 & BUSY); //Wait while ADC is busy ADC10SA = (unsigned)&ADCReading[0];
			ADC10SA = (unsigned)&ADCReading[0]; //RAM Address of ADC Data, must be reset every conversion
			ADC10CTL0 |= (ENC | ADC10SC); //Start ADC Conversion
			while (ADC10CTL1 & BUSY); //Wait while ADC is busy
			light += ADCReading [0];
			touch += ADCReading [1];
			temp  += ADCReading [2];
		}
		//Taking average of all the sensors
		light = light/LOOPMAX;
		touch = touch/LOOPMAX;
		temp = temp/LOOPMAX;
		temp = ((0.322227) * temp);//Formula to convert to Farenheit= (3.3/1024 * 0.01) * temp = (3.3/1024 * 1/10^-2)* temp =
		//															  =(330/1024) * temp => 0.32222227 *temp
		//temp is range from 0-1024 because our MICROCONTROLLER uses a ADC10 meaning 10 bits thus 2^10

		if(touch >= touchroom *0.90)// not touching the sensor so give permission to allow to toggle
		{
			togglePermis=1;
		}
		//Touch Controlling LED1
		if(touch <= touchroom *0.80 && togglePermis == 1)//if statemnt is true it means you are touching
		{
			P1OUT ^=  BIT4;
			__delay_cycles(500); // turn LED3 on
			togglePermis=0;
			lightOn++;			//if even it is off if odd it is on
			lightOn = lightOn % 2;//Taking mod to determine whether on or off (0 or 1)
		}

		//Code for 5 second timer enable and disable
		if(togglePermis == 1 && lightOn == 1)	//if statement for if light is on and not touching sensor
		{
			__enable_interrupt(); //enable interrupt to increment timer counter
		}
		else //might want to consider not to keep disabling interrupt when light is off
		{
			tCounter =0;			//must be set back to zero because if you turn on light then turn off before 5 seconds runs up then it
									//must be reset
			__disable_interrupt();	//must disable because it was toogle before 5 seconds or light is not on
		}


		//Light controlling LED2
		if(light >= (lightroom * 1.1) && light <= (lightroom * 1.3)) {} // dead zone, if light between these two limits, do nothing
		else
	    {
			if(light >= (lightroom * 1.3))//turn on when light in room goes 130% higher
			{
				P1OUT |=  BIT5;// turn LED1 on
				__delay_cycles(500);
			}
			if(light <=(lightroom * 1.1))//turn on when light in room goes under 110%
			{
				P1OUT &= ~BIT5; // turn LED1 off
				__delay_cycles(500);
			}
		}

		//Temperature Controlling LED3
		if(temp > (temproom *1.01) && temp < (temproom *1.03)) {} // dead zone, if temp between these two limits, do nothing
		else
		{
			if(temp >= (temproom *1.03)) //if temperature is greater than or equal to 30% greater than temperature in room (temproom)
			{
				P2OUT |= BIT0; // turn LED2 on
				__delay_cycles(500);
			}
		    if(temp <= (temproom *1.01)) //if temperature is less than or equal to 10% of the temperature in room(temproom)
		    {
		    	P2OUT &= ~BIT0; // turn LED2 off
		    	__delay_cycles(500);
		    }
		}

	}


}
	void ConfigureAdc(void)
	{
		ADC10CTL1 = INCH_2 | CONSEQ_1; // A2 + A1 + A0, single sequence
		ADC10CTL0 = ADC10SHT_2 | MSC | ADC10ON;
		while (ADC10CTL1 & BUSY);
		ADC10DTC1 = 0x03; // 3 conversions
		ADC10AE0 |= (BIT0 | BIT1 | BIT2); // ADC10 option select
	}


#pragma vector=ADC10_VECTOR
__interrupt void ADC10_ISR(void)
{
		__bic_SR_register_on_exit(CPUOFF);
}

#pragma vector=TIMER0_A0_VECTOR // Timer0 A0 interrupt service routine
__interrupt void Timer0_A0 (void)
{
	 tCounter++;
	 if(tCounter == 5)
	 {
		 P1OUT ^= BIT4;						// Toggle red LED
		 tCounter = 0;
		 lightOn = 0;
	 }
	 __disable_interrupt();					//disabled so that timer does not continue to count when outside
}

