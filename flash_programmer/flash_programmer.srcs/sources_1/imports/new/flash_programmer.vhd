----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/03/2025 02:18:54 PM
-- Design Name: 
-- Module Name: flash_programmer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity flash_programmer is
    Generic (
        MAX_COUNT : integer := 25000000
    );
    Port (
    led_light : out STD_LOGIC;
    CLK25MHZ  : in  STD_LOGIC
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
     signal counter : integer := 0;
     signal state : std_logic := '0';
begin
    process(CLK25MHZ)
    begin
    if CLK25MHZ'event and CLK25MHZ = '1' then
        counter <= counter + 1;
        if counter = MAX_COUNT then
            counter <= 1;
            led_light <= state;
            state <= not state;
        else 
            counter <= counter + 1;
        end if;
    end if;
    end process;

end Behavioral;
