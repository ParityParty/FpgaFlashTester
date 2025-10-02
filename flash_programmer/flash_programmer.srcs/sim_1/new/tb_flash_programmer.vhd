library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_flash_programmer is
end tb_flash_programmer;

architecture behavior of tb_flash_programmer is

    -- Component Declaration
    component flash_programmer
        generic (
            MAX_COUNT : integer := 5;
            DELAY_MAX_COUNT : integer := 3;
            PAGE_SIZE : integer := 8640;
            PAGES_IN_BLOCK : integer := 128;
            BLOCKS_TO_TEST : integer := 1024;
            NUM_OF_DEVICES : integer := 2;
            MAX_FAULTS : integer := 5
        );
        port (
            led_light : out STD_LOGIC;
            i_clock : in STD_LOGIC;
            i_reset : in STD_LOGIC;

            o_activate : out std_logic;
            o_cmd : out std_logic_vector(7 downto 0);
            o_address : out std_logic_vector(39 downto 0);
            o_data : out std_logic_vector(7 downto 0);
            i_data : in std_logic_vector(7 downto 0);
            i_busy : in std_logic;
            i_read_done : in std_logic;
            i_command_received : in std_logic;

            o_TX_DV : out std_logic;
            o_TX_Byte : out std_logic_vector(7 downto 0);
            i_TX_Active : in std_logic;
            i_TX_Done : in std_logic
        );
    end component;

    -- Signals to connect to the DUT
    signal clk             : std_logic := '0';
    signal rst             : std_logic := '0';

    signal led_light       : std_logic;
    signal o_activate      : std_logic;
    signal o_cmd           : std_logic_vector(7 downto 0);
    signal o_address       : std_logic_vector(39 downto 0);
    signal o_data          : std_logic_vector(7 downto 0);
    signal i_data          : std_logic_vector(7 downto 0) := (others => '0');
    signal i_busy          : std_logic := '0';
    signal i_read_done     : std_logic := '0';
    signal i_command_received : std_logic := '0';

    signal o_TX_DV         : std_logic;
    signal o_TX_Byte       : std_logic_vector(7 downto 0);
    signal i_TX_Active     : std_logic := '0';
    signal i_TX_Done       : std_logic := '0';

    constant CLK_PERIOD    : time := 10 ns;

begin

    -- Clock Generation
    clk_process : process
    begin
        while now < 5 ms loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- DUT Instantiation
    uut: flash_programmer
        port map (
            led_light => led_light,
            i_clock => clk,
            i_reset => rst,

            o_activate => o_activate,
            o_cmd => o_cmd,
            o_address => o_address,
            o_data => o_data,
            i_data => i_data,
            i_busy => i_busy,
            i_read_done => i_read_done,
            i_command_received => i_command_received,

            o_TX_DV => o_TX_DV,
            o_TX_Byte => o_TX_Byte,
            i_TX_Active => i_TX_Active,
            i_TX_Done => i_TX_Done
        );

    -- Reset Process
    reset_process : process
    begin
        rst <= '0';
        wait for 50 ns;
        rst <= '1';  -- Release reset after some time
        wait;
    end process;

    -- Stimulus Process (simulate external controller responses)
    stimulus_process : process
    begin

        -- Respond to activate signal by toggling busy
        loop
            wait until rising_edge(clk);

            -- Simulate that controller becomes busy during o_activate
            if o_activate = '1' then
                i_busy <= '1';
                wait for 40 ns;
                i_command_received <= '1';
                wait for 40 ns;
--                i_command_received <= '0';
                i_busy <= '0';
            end if;

            -- Respond to read done if a read command is issued
            if o_cmd = x"05" then
                wait for 100 ns;
                i_read_done <= '1';
                i_data <= x"AA";  -- Simulate successful read
                wait for 20 ns;
                i_read_done <= '0';
            end if;

            -- Simulate i_TX_Active being busy for a while
            if o_TX_DV = '1' then
                i_TX_Active <= '1';
                wait for 30 ns;
                i_TX_Active <= '0';
                i_TX_Done <= '1';
                wait for 20 ns;
                i_TX_Done <= '0';
            end if;
        end loop;
    end process;

end behavior;
