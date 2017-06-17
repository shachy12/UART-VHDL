----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:49:20 06/17/2017 
-- Design Name: 
-- Module Name:    loopback - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity loopback is
	port (CLK_12MHz : in std_logic;
			UART_RX : in std_logic;
			UART_TX : out std_logic;
			LED : out std_logic_vector(7 downto 0));
end loopback;

architecture Behavioral of loopback is
	component UART
	   generic (
        BAUD_RATE : positive;
		  CLOCK_FREQUENCY : positive
      );
		port(i_Clock : in  std_logic;
			  i_Serial_RX : in  std_logic;
			  i_Start_Transmit : in  std_logic;
           i_Transmit_Byte : in  std_logic_vector (7 downto 0);
			  o_Is_Byte_Received : out  std_logic;
           o_Is_TX_Active : out  std_logic;
           o_Serial_TX : out  std_logic;
			  o_Rx_Byte : out std_logic_vector(7 downto 0));
	end component;
	
	--signal r_Start_Transmit : std_logic := '0';
	--signal r_Transmit_Byte : std_logic_vector(7 downto 0);
	signal r_Is_Byte_Received : std_logic := '0';
	signal r_Is_Tx_Active : std_logic := '0';
	signal r_Received_Byte : std_logic_vector(7 downto 0) := (others => '0');
begin

	UART1 : UART generic map (19200, 12000000) 
					 port map(CLK_12MHz,
								 UART_RX,
								 r_Is_Byte_Received,
								 r_Received_Byte,
								 r_Is_Byte_Received,
								 r_Is_Tx_Active,
								 UART_TX,
								 r_Received_Byte);
								 
	LED <= r_Received_Byte;

end Behavioral;

