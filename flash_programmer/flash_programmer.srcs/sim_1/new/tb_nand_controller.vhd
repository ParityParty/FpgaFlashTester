--------------------------------------------------------------------------------
--
-- File: nand_controller_tb.vhd
-- Testbench for the nand_controller entity.
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi_timings.all; -- Use the constants from the provided package
use std.textio.all;

entity nand_controller_tb is
end nand_controller_tb;

architecture behavior of nand_controller_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component nand_controller is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_activate : in std_logic;
            i_cmd : in std_logic_vector(7 downto 0);
            i_address : in std_logic_vector(39 downto 0);
            io_data : inout std_logic_vector(7 downto 0);
            o_busy : out std_logic;
            o_read_done : out std_logic;
            
            i_nand_rb : in std_logic;
            o_nand_we : out std_logic;
            o_nand_wp : out std_logic;
            o_nand_cle : out std_logic;
            o_nand_ale : out std_logic;
            o_nand_re : out std_logic;
            io_nand_data : inout std_logic_vector(7 downto 0)
        );
    end component;

    -- UUT Signals
    signal s_clk : std_logic := '0';
    signal s_rst : std_logic := '1';
    signal s_activate : std_logic := '0';
    signal s_cmd : std_logic_vector(7 downto 0) := (others => '0');
    signal s_address : std_logic_vector(39 downto 0) := (others => '0');
    signal s_data : std_logic_vector(7 downto 0) := (others => 'Z');
    signal s_busy : std_logic;
    signal s_read_done : std_logic;
    
    -- NAND Flash Device Model Signals
    signal s_nand_rb : std_logic := '1'; -- Default to not busy
    signal s_nand_we : std_logic;
    signal s_nand_wp : std_logic;
    signal s_nand_cle : std_logic;
    signal s_nand_ale : std_logic;
    signal s_nand_re : std_logic;
    
    -- Bidirectional data bus resolution
    signal s_io_nand_data : std_logic_vector(7 downto 0);
    signal s_io_data : std_logic_vector(7 downto 0);
    
    -- Clock period constant
    constant CLK_PERIOD : time := real'pos(clock_cycle) * 1 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: nand_controller
        port map (
            i_clk => s_clk,
            i_rst => s_rst,
            i_activate => s_activate,
            i_cmd => s_cmd,
            i_address => s_address,
            io_data => s_io_data,
            o_busy => s_busy,
            o_read_done => s_read_done,
            i_nand_rb => s_nand_rb,
            o_nand_we => s_nand_we,
            o_nand_wp => s_nand_wp,
            o_nand_cle => s_nand_cle,
            o_nand_ale => s_nand_ale,
            o_nand_re => s_nand_re,
            io_nand_data => s_io_nand_data
        );

    -- Connect the bidirectional buses
    s_io_data <= s_data;
    
    -- Clock generation process
    clock_gen: process
    begin
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
    end process clock_gen;
    
    -- Test stimulus process
    stimulus: process
    begin
        report "Starting simulation..." severity note;

        -- Step 1: Apply reset
        s_rst <= '0';
        s_activate <= '0';
        wait for 5 * CLK_PERIOD;
        
        -- Step 2: Release reset
        s_rst <= '1';
        wait for 2 * CLK_PERIOD;
        report "Reset deasserted, waiting for controller to be idle..." severity note;
        if s_busy /= '0' then
            wait until s_busy = '0';
        end if;
        wait for CLK_PERIOD;
        
        -- Step 3: Send Reset command (FFh)
        report "Sending Reset command (FFh)..." severity note;
        s_cmd <= x"01"; -- The controller's command for Reset
        s_activate <= '1';
        wait for CLK_PERIOD;
        s_activate <= '0';
        report "Reset command sent. Controller should be waiting." severity note;
        wait for CLK_PERIOD;
        
        if s_busy /= '0' then
            wait until s_busy = '0';
        end if;
        report "Busy is low." severity note;
        wait for CLK_PERIOD;
        
        -- Step 5: Send Get Status command (70h)
        report "Sending Get Status command (70h)..." severity note;
        s_cmd <= x"02"; -- The controller's command for Get Status
        s_activate <= '1';
        wait for CLK_PERIOD;
        s_activate <= '0';
               if s_busy /= '0' then
            wait until s_busy = '0';
        end if;
        report "Get Status command sent. Controller should be reading status." severity note;
        
        -- Step 6: End simulation
        report "Simulation finished." severity note;
        wait;
    end process stimulus;
    
    -- NAND Flash Device Model Process
    -- This process simulates the behavior of the NAND chip, specifically the
    -- r/b signal and the data bus.
    nand_model: process
    begin
        -- Drive io_nand_data to high impedance by default
        s_io_nand_data <= (others => 'Z');
        
        -- Check for a valid command sequence from the controller
        if s_nand_cle = '1' and s_nand_we = '0' then
        
            -- Wait for controller to finish command cycle
            if s_nand_we /= '1' then
                wait until s_nand_we = '1';
            end if;

            -- Check for the Reset command (FFh)
            if s_io_nand_data = x"FF" then
                if s_nand_cle /= '0' then
                    wait until s_nand_cle = '0';
                end if;
                wait for CLK_PERIOD;
                
                s_nand_rb <= '0'; -- Go busy
                report "NAND Model: Reset command detected. Going busy." severity note;
                
                wait for 10 * CLK_PERIOD;
                
                s_nand_rb <= '1'; -- Ready
                report "NAND Model: Reset done. Released r/b after 10 cycles." severity note;
                
            -- Check for the Get Status command (70h)
            elsif s_io_nand_data = x"70" then
                if s_nand_re /= '0' then
                    wait until s_nand_re = '0';
                end if;
                s_io_nand_data <= x"C0";
                
                if s_nand_re /= '1' then
                    wait until s_nand_re = '1';
                end if;
                s_io_nand_data <= (others => 'Z');
            end if;
        end if;
        
        
        wait on s_nand_cle, s_nand_we, s_nand_re; -- Trigger on these signals
    end process nand_model;

end behavior;