# UART-VHDL
## Description
A UART implementation in VHDL - No parity bit, 8 bits data, 1 stop bit.
Tested on Mimas V2 (Spartan XC6SLX9 in CSG324 package) on 19200 baud rate.

## Getting Started
In order to use this module you need to take the file UART.vhd and put it in your project.
Initializing your uart component should be like this:
```vhdl
UART1 : UART generic map (19200, 12000000) -- Baud Rate, Clock Frequency
        port map(CLK_12MHz, -- Clock Signal
                 UART_RX, -- RX Signal
                 r_Start_Transmit, -- In order to transmit new byte set this signal to '1'
                 r_Transmit_Byte, -- Byte to transmit
                 r_Is_Byte_Received, -- When new byte arrived this signal will be '1' for one clock
                 r_Is_Tx_Active, -- This signal is equal to '1' while transmitting and equal to '0' while IDLE
                 UART_TX, --TX Signal
                 r_Received_Byte, -- The received byte signal
                 r_TX_Done); -- This signal is set to '1' when finished transmitting
```

### Transmitting data
After inializing the uart component in order to transmit data you need to use 2 signals:
* r_Transmit_Byte
* r_Start_Transmit

When setting the r_Start_Transmit to '1' the uart module will take the 8 bits from the r_Transmit_Byte signal and start transmitting.
On done transmitting the signal r_TX_Done will be set to '1'.

### Receiving data
When new data arrives on the rx line the received 8 bit will be set to the signal r_Received_Byte and the signal r_Is_Byte_Received will be set to '1'

## Loopback example
The loopback example can be found in the loopback.vhdl file.
Every data received on the RX line will be transmitted on the TX.
