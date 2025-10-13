-- VHDL Testbench for design_1_wrapper
-- This testbench provides a 25 MHz clock and basic stimulus.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench entity is typically empty
entity tb_design is
end tb_design;

architecture behavior of tb_design is

    -- Component declaration for the Unit Under Test (UUT)
    component design_1_wrapper is
        port (
            CLK25MHZ  : in  STD_LOGIC;
            led_light : out STD_LOGIC;
            nand_ale  : out STD_LOGIC;
            nand_ce   : out STD_LOGIC;
            nand_cle  : out STD_LOGIC;
            nand_data : inout STD_LOGIC_VECTOR(7 downto 0);
            nand_rb   : in  STD_LOGIC;
            nand_re   : out STD_LOGIC;
            nand_we   : out STD_LOGIC;
            nand_wp   : out STD_LOGIC;
            uart_tx   : out STD_LOGIC
        );
    end component;

    -- Constants
    constant SLOW_CLK_PERIOD : time := 40 ns; -- Clock period for 25 MHz (1 / 25e6 = 40 ns)
    constant CLK_PERIOD : time := 10 ns;

    -- Signal declarations to connect to the UUT
    signal tb_clk25mhz  : STD_LOGIC := '0';
    signal tb_led_light : STD_LOGIC;
    signal tb_nand_ale  : STD_LOGIC;
    signal tb_nand_ce   : STD_LOGIC;
    signal tb_nand_cle  : STD_LOGIC;
    signal tb_nand_data : STD_LOGIC_VECTOR(7 downto 0);
    signal tb_nand_rb   : STD_LOGIC;
    signal tb_nand_re   : STD_LOGIC;
    signal tb_nand_we   : STD_LOGIC;
    signal tb_nand_wp   : STD_LOGIC;
    signal tb_uart_tx   : STD_LOGIC;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut_inst : design_1_wrapper
        port map (
            CLK25MHZ  => tb_clk25mhz,
            led_light => tb_led_light,
            nand_ale  => tb_nand_ale,
            nand_ce   => tb_nand_ce,
            nand_cle  => tb_nand_cle,
            nand_data => tb_nand_data,
            nand_rb   => tb_nand_rb,
            nand_re   => tb_nand_re,
            nand_we   => tb_nand_we,
            nand_wp   => tb_nand_wp,
            uart_tx   => tb_uart_tx
        );

    -- Clock generation process
    -- This process generates a 50% duty cycle 25 MHz clock.
    clk_process : process
    begin
        tb_clk25mhz <= '0';
        wait for SLOW_CLK_PERIOD / 2; -- Wait for 20 ns
        tb_clk25mhz <= '1';
        wait for SLOW_CLK_PERIOD / 2; -- Wait for 20 ns
    end process clk_process;
    
    nand_model: process
    begin
        tb_nand_rb   <= '1'; -- Assume NAND flash is ready by default
        tb_nand_data <= (others => 'Z'); -- Set inout bus to high-impedance
        
        -- Check for a valid command sequence from the controller
        if tb_nand_cle = '1' and tb_nand_we = '0' then
        
            -- Wait for controller to finish command cycle
            if tb_nand_we /= '1' then
                wait until tb_nand_we = '1';
            end if;

            -- Check for the Reset command (FFh)
            if tb_nand_data = x"FF" then
                if tb_nand_cle /= '0' then
                    wait until tb_nand_cle = '0';
                end if;
                wait for CLK_PERIOD;
                
--                if fault_sim = '0' then
--                    fault_sim <= '1';
--                else
                    tb_nand_rb <= '0'; -- Go busy
--                    fault_sim <= '0';
--                end if;
                report "NAND Model: Reset command detected. Going busy." severity note;
                
                wait for 10 * CLK_PERIOD;
                
                tb_nand_rb <= '1'; -- Ready
                report "NAND Model: Reset done. Released r/b after 10 cycles." severity note;
            
            elsif tb_nand_data = x"D0" or tb_nand_data = x"10" or tb_nand_data = x"30" then
                if tb_nand_cle /= '0' then
                    wait until tb_nand_cle = '0';
                end if;
                wait for CLK_PERIOD;
--                 if fault_sim = '0' then
--                    fault_sim <= '1';
--                else
                    tb_nand_rb <= '0'; -- Go busy
--                    fault_sim <= '0';
--                end if;
                wait for 20 * CLK_PERIOD;
                tb_nand_rb <= '1'; -- Ready
                
            -- Check for the Get Status command (70h)
            elsif tb_nand_data = x"70" then
                if tb_nand_re /= '0' then
                    wait until tb_nand_re = '0';
                end if;
                tb_nand_data <= x"E0";
                
                if tb_nand_re /= '1' then
                    wait until tb_nand_re = '1';
                end if;
                tb_nand_data <= (others => 'Z');
            end if;
        elsif tb_nand_re = '0' then
            tb_nand_data <= x"55";
            if tb_nand_re /= '1' then
                wait until tb_nand_re = '1';
            end if;
            tb_nand_data <= (others => 'Z');
        end if;
        
        
        wait on tb_nand_cle, tb_nand_we, tb_nand_re; -- Trigger on these signals
    end process nand_model;

end behavior;