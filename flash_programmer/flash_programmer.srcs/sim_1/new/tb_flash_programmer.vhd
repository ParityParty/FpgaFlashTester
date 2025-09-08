library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_flash_programmer is
end tb_flash_programmer;

architecture sim of tb_flash_programmer is
    -- DUT component declaration
    component flash_programmer
        generic (
            MAX_COUNT       : integer := 25;
            DELAY_MAX_COUNT : integer := 10
        );
        port (
            led_light   : out STD_LOGIC;
            CLK25MHZ    : in  STD_LOGIC;
            uart_tx     : out STD_LOGIC;
            clk_monitor : out STD_LOGIC;

            nand_cle    : out std_logic;
            nand_ale    : out std_logic;
            nand_nwe    : out std_logic;
            nand_nwp    : out std_logic;
            nand_nce    : out std_logic;
            nand_nre    : out std_logic;
            nand_rnb    : in  std_logic;
            nand_data   : inout std_logic_vector(15 downto 0);
            
            dbg_state   : out std_logic_vector(3 downto 0);
            dbg_data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    -- signals for DUT
    signal clk        : std_logic := '0';
    signal led        : std_logic;
    signal uart_tx    : std_logic;
    signal clk_mon    : std_logic;
    signal nand_cle   : std_logic;
    signal nand_ale   : std_logic;
    signal nand_nwe   : std_logic;
    signal nand_nwp   : std_logic;
    signal nand_nce   : std_logic;
    signal nand_nre   : std_logic;
    signal nand_rnb   : std_logic := '1'; -- NAND ready by default
    signal nand_data  : std_logic_vector(15 downto 0) := (others => 'Z');
    
    signal dbg_state   : std_logic_vector(3 downto 0);
    signal dbg_data_out : std_logic_vector(7 downto 0);

begin
    -- DUT instantiation
    DUT: flash_programmer
        generic map (
            MAX_COUNT       => 25,   -- shorten counters for sim
            DELAY_MAX_COUNT => 10
        )
        port map (
            led_light   => led,
            CLK25MHZ    => clk,
            uart_tx     => uart_tx,
            clk_monitor => clk_mon,

            nand_cle    => nand_cle,
            nand_ale    => nand_ale,
            nand_nwe    => nand_nwe,
            nand_nwp    => nand_nwp,
            nand_nce    => nand_nce,
            nand_nre    => nand_nre,
            nand_rnb    => nand_rnb,
            nand_data   => nand_data,
            
            dbg_state => dbg_state,
            dbg_data_out => dbg_data_out
        );

    -- generate 25 MHz clock (40 ns period)
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 20 ns;
            clk <= '1';
            wait for 20 ns;
        end loop;
    end process;

    -- stimulus process
    stim_proc : process
    begin
--        -- Let the design initialize
--        wait for 200 ns;
        
        wait_loop: loop
            if nand_nre = '0' then  -- mem_done comes from memory entity
                exit wait_loop;
            end if;
            wait for 5ns;
        end loop wait_loop;

--        wait for 155ns;
		nand_data <= x"002c";
		wait for 240ns;
		nand_data <= x"00e5";
		wait for 240ns;
		nand_data <= x"00ff";
		wait for 240ns;
		nand_data <= x"0003";
		wait for 240ns;
		nand_data <= x"0086";
		wait for 240ns;
		nand_data <= "ZZZZZZZZZZZZZZZZ";
		wait for 5ns;
        -- Let the FSM cycle a few times
        wait for 2 us;

        -- finish simulation
        wait;
    end process;
end sim;
