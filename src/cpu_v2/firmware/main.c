// C program to test UART receiver
// Incoming data from serial terminal PUTTY
//Received data (1-9) displayed on FPGA LED
//FPGA tested

#include <stdint.h>
#include <stdlib.h>
//*** LED Address mapping */
#define LED_ADDR 0x10000000   // starting addr of LED
#define LED_DATA *((volatile unsigned int *)(LED_ADDR ))
//********** UART Transmitter Register address map *******
#define UART_DATA_ADDR 0x20000000   // starting addr of UART DATA REG
#define UART_DATA *((volatile unsigned int *)(UART_DATA_ADDR ))
#define UART_CTRL_ADDR 0x30000000   // starting addr of UART CTRL REG
#define UART_CTRL *((volatile unsigned int *)(UART_CTRL_ADDR ))
#define UART_STATUS_ADDR 0x40000000   // starting addr of UART status REG
#define UART_STATUS *((volatile unsigned int *)(UART_STATUS_ADDR ))
//******UART Receiver Register address mapping**************
#define UART_RXDATA_ADDR 0x50000000   // starting addr of UART DATA REG
#define UART_RXDATA *((volatile unsigned int *)(UART_RXDATA_ADDR ))
#define UART_RXCTRL_ADDR 0x60000000   // starting addr of UART CTRL REG
#define UART_RXCTRL *((volatile unsigned int *)(UART_RXCTRL_ADDR ))
#define UART_RXSTATUS_ADDR 0x70000000   // starting addr of UART status REG
#define UART_RXSTATUS *((volatile unsigned int *)(UART_RXSTATUS_ADDR ))
//Delay function
void delay(uint32_t cycles) {
  volatile uint32_t count = 0; // volatile to prevent compiler optimization

  while (count < cycles) {
    count++;
  }
}


//uart function to send a single character
void uart_send(uint8_t my_char)
{
    while(UART_STATUS==0) ;
           
    UART_DATA = my_char;
    UART_CTRL = 1;
    UART_CTRL = 0;
   
}
//UART function to send a string 
void uart_sendline(uint8_t *my_str)
{
    for (uint8_t i = 0; my_str[i] != '\0'; i++)
    {
        uart_send(my_str[i]);
       
    }
}

//UART Receive 
volatile uint32_t uart_receive()
{
	UART_RXCTRL = 1;//enable receiver
   UART_RXCTRL = 0;//disable receiver
   	while(UART_RXSTATUS==0) ;//wait if busy receiving data
    //UART_RXCTRL = 0;//disable receiver
           
   	return UART_RXDATA ;
    
}



// Driver program to test above function
int main(void)
{
  uart_sendline("RISC-V UART is listenting and ready to transmit or receive\n\r");
  
  LED_DATA = 0;

  while(1){
    uart_sendline("Press any key in keyboard: \n\r");
    //Receive data from UART and display to LED
    //subtract 48 to convert ASCII to number
    volatile uint32_t rx_data = uart_receive();
    LED_DATA =  rx_data - 48; //convert to decimal digit of num (valid for 0-9)
    uart_sendline("You pressed:  ");
    uart_send((char)rx_data);
	  uart_sendline("\n\r ");
    delay(100000);

  }
	

	return 0;
}