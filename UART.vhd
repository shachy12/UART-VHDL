----------------------------------------------------------------------------------
-- Company: 
-- Engineer: https://github.com/shachy12/UART-VHDL/blob/master/UART.vhd
-- 
-- Create Date:    14:14:53 06/17/2017 
-- Design Name: 
-- Module Name:    UART - Behavioral 
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

entity UART is
	 generic (
     BAUD_RATE : positive;
	  CLOCK_FREQUENCY : positive
    );
    Port ( i_Clock : in  std_logic;
			  i_Serial_RX : in  std_logic;
			  i_Start_Transmit : in  std_logic;
           i_Transmit_Byte : in  std_logic_vector (7 downto 0);
			  o_Is_Byte_Received : out  std_logic;
           o_Is_TX_Active : out  std_logic;
           o_Serial_TX : out  std_logic;
			  o_Rx_Byte : out std_logic_vector(7 downto 0);
			  o_TX_Done : out std_logic);
end UART;

architecture Behavioral of UART is
	constant c_TICKS_PER_BIT : integer := CLOCK_FREQUENCY / BAUD_RATE;
   -- RX
	signal r_RX_Clk_Count : integer range 0 to c_TICKS_PER_BIT - 1 := 0;
	type t_RX_State is (IDLE, WAITING_FOR_START, WAITING_FOR_BITS, WAITING_FOR_END);
	signal r_RX_State : t_RX_State := IDLE;
	signal r_RX_Bit_Index : integer range 0 to 7 := 0;
	signal r_RX_Byte : std_logic_vector(7 downto 0) := (others => '0');
	
	-- TX
	signal r_TX_Clk_Count : integer range 0 to c_TICKS_PER_BIT - 1 := 0;
	
	--restkhz: add state BIT_FINISHED
	--type t_TX_State is (IDLE, START_BIT, WRITING_BITS, WRITING_END_BIT);
	type t_TX_State is (IDLE, START_BIT, WRITING_BITS, WRITING_END_BIT, BIT_FINISHED);
	
	signal r_TX_State : t_TX_State := IDLE;
	signal r_TX_Byte : std_logic_vector (7 downto 0) := (others => '0');
	signal r_TX_Bit_Index : integer range 0 to 7 := 0;
	signal r_TX_Done : std_logic := '0';
begin

  p_RX : process (i_Clock)
  begin
    if rising_edge(i_Clock) then
		-- Waiting for RX to be equal '0' to start waiting for the start bit
      if i_Serial_RX = '0' and r_RX_State = IDLE then
		  r_RX_State <= WAITING_FOR_START;
		  r_RX_Clk_Count <= c_TICKS_PER_BIT / 2;
		  r_RX_Bit_Index <= 0;
      end if;
		
		if r_RX_State = IDLE then
			o_Is_Byte_Received <= '0';
		end if;
		
      if r_RX_State /= IDLE then
			if r_RX_Clk_Count = c_TICKS_PER_BIT - 1 then -- Check if middle of bit
			
				case r_RX_State is
					when WAITING_FOR_START =>
						if i_Serial_RX = '0' then
							r_RX_State <= WAITING_FOR_BITS;
						else
							r_RX_State <= IDLE;
						end if;
						
					when WAITING_FOR_BITS =>
						r_RX_Byte(r_RX_Bit_Index) <= i_Serial_RX;
						r_RX_Bit_Index <= r_RX_Bit_Index + 1;
						if r_RX_Bit_Index = 7 then
							r_RX_State <= WAITING_FOR_END;
						end if;
						
					when WAITING_FOR_END =>
						o_Is_Byte_Received <= '1';
						o_Rx_Byte <= r_RX_Byte;
						r_RX_State <= IDLE;
						
					when others =>
						r_RX_State <= IDLE;
						
				end case;
				r_RX_Clk_Count <= 0;
			else
				r_RX_Clk_Count <= r_RX_Clk_Count + 1;
			end if;
		 end if;
	  end if;
	end process p_RX;
	
	p_TX : process (i_Clock)
	begin
		if rising_edge(i_Clock) then			
			if r_TX_State = IDLE then
				r_TX_Clk_Count <= 0;
			else
				if r_TX_Clk_Count = c_TICKS_PER_BIT - 1 then
					r_TX_Clk_Count <= 0;
				else
					r_TX_Clk_Count <= r_TX_Clk_Count + 1;
				end if;
			end if;
			
			if r_TX_Clk_Count = 0 then
				
				case r_TX_State is
					when IDLE =>
						r_TX_Done <= '0';
						if i_Start_Transmit = '1' then
							r_TX_Byte <= i_Transmit_Byte;
							r_TX_Bit_Index <= 0;
							r_TX_State <= START_BIT;
							o_Is_TX_Active <= '1';
						else
							o_Is_TX_Active <= '0';
							o_Serial_TX <= '1';
						end if;
					when START_BIT =>
						o_Serial_TX <= '0';
						r_TX_State <= WRITING_BITS;
					when WRITING_BITS =>
						o_Serial_TX <= r_TX_Byte(r_TX_Bit_Index);
						
						if r_TX_Bit_Index = 7 then
							r_TX_State <= WRITING_END_BIT;
						else
							r_TX_Bit_Index <= r_TX_Bit_Index + 1;
						end if;
					when WRITING_END_BIT =>
						o_Serial_TX <= '1';
			 		--restkhz: commented 3 lines below
						--o_Is_TX_Active <= '0';
						--r_TX_State <= IDLE;
						--r_TX_Done <= '1';
			 		--restkhz: added 5 lines below
						r_TX_State <= BIT_FINISHED;
					when BIT_FINISHED =>
		      				o_Is_TX_Active <= '0';
						r_TX_State <= IDLE;
						r_TX_Done <= '1';
					
					when others =>
						r_TX_State <= IDLE;
				end case;
			end if;
		end if;
	end process p_TX;
	o_TX_Done <= r_TX_Done;
end Behavioral;
