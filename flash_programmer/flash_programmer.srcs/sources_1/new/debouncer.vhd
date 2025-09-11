library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Port ( 
        clk     : in  std_logic;
        btn_in  : in  std_logic;
        rst_out : out std_logic
    );
end debouncer;

architecture Behavioral of debouncer is
    constant DEBOUNCE_TIME_MS : natural := 20;  -- Czas odskoku w milisekundach
    constant CLK_FREQ_HZ      : natural := 25_000_000; -- Częstotliwość zegara w Hz (np. 50 MHz)
    constant DEBOUNCE_CYCLES  : integer := (DEBOUNCE_TIME_MS * CLK_FREQ_HZ) / 1000;

    signal btn_sync_reg : std_logic_vector(1 downto 0) := (others => '0');
    signal count        : integer range 0 to DEBOUNCE_CYCLES := 0;
    signal btn_stable   : std_logic := '0';
    signal rst_active   : std_logic := '0';

begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Rejestr synchronizujący wejście przycisku
            btn_sync_reg(0) <= btn_in;
            btn_sync_reg(1) <= btn_sync_reg(0);

            -- Zliczanie stabilnych stanów
            if btn_sync_reg(0) = btn_sync_reg(1) then
                if count < DEBOUNCE_CYCLES then
                    count <= count + 1;
                else
                    btn_stable <= btn_sync_reg(1);
                end if;
            else
                count <= 0;
            end if;

            -- Generowanie impulsu resetu
            if btn_stable = '0' then -- Zakładamy, że przycisk jest aktywny stanem niskim
                rst_active <= '1';
            else
                rst_active <= '0';
            end if;
        end if;
    end process;

    -- Wyjście debouncera
    rst_out <= rst_active;

end Behavioral;