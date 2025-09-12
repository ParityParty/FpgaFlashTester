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


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

--entity UART_TX is
--  generic (
--    g_CLKS_PER_BIT : integer := 2604     -- Needs to be set correctly
--    );
--  port (
--    i_Clk       : in  std_logic;
--    i_TX_DV     : in  std_logic;
--    i_TX_Byte   : in  std_logic_vector(7 downto 0);
--    o_TX_Active : out std_logic;
--    o_TX_Serial : out std_logic;
--    o_TX_Done   : out std_logic
--    );
--end UART_TX;
 
 
--architecture rtl_tx of UART_TX is
 
--  type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
--                     s_TX_Stop_Bit, s_Cleanup);
--  signal r_SM_Main : t_SM_Main := s_Idle;
 
--  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
--  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
--  signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
--  signal r_TX_Done   : std_logic := '0';
   
--begin
 
   
--  p_UART_TX : process (i_Clk)
--  begin
--    if rising_edge(i_Clk) then
         
--      case r_SM_Main is
 
--        when s_Idle =>
--          o_TX_Active <= '0';
--          o_TX_Serial <= '1';         -- Drive Line High for Idle
--          r_TX_Done   <= '0';
--          r_Clk_Count <= 0;
--          r_Bit_Index <= 0;
 
--          if i_TX_DV = '1' then
--            r_TX_Data <= i_TX_Byte;
--            r_SM_Main <= s_TX_Start_Bit;
--            o_TX_Active <= '1';
--          else
--            r_SM_Main <= s_Idle;
--          end if;
 
--        -- Send out Start Bit. Start bit = 0
--        when s_TX_Start_Bit =>
--          o_TX_Active <= '1';
--          o_TX_Serial <= '0';
 
--          -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
--          if r_Clk_Count < g_CLKS_PER_BIT-1 then
--            r_Clk_Count <= r_Clk_Count + 1;
--            r_SM_Main   <= s_TX_Start_Bit;
--          else
--            r_Clk_Count <= 0;
--            r_SM_Main   <= s_TX_Data_Bits;
--          end if;
 
--        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish
--        when s_TX_Data_Bits =>
--          o_TX_Serial <= r_TX_Data(r_Bit_Index);
           
--          if r_Clk_Count < g_CLKS_PER_BIT-1 then
--            r_Clk_Count <= r_Clk_Count + 1;
--            r_SM_Main   <= s_TX_Data_Bits;
--          else
--            r_Clk_Count <= 0;
             
--            -- Check if we have sent out all bits
--            if r_Bit_Index < 7 then
--              r_Bit_Index <= r_Bit_Index + 1;
--              r_SM_Main   <= s_TX_Data_Bits;
--            else
--              r_Bit_Index <= 0;
--              r_SM_Main   <= s_TX_Stop_Bit;
--            end if;
--          end if;
 
--        -- Send out Stop bit. Stop bit = 1 
--        when s_TX_Stop_Bit =>
--          o_TX_Serial <= '1';
 
--          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
--          if r_Clk_Count < g_CLKS_PER_BIT-1 then
--            r_Clk_Count <= r_Clk_Count + 1;
--            r_SM_Main   <= s_TX_Stop_Bit;
--          else
--            r_TX_Done   <= '1';
--            r_Clk_Count <= 0;
--            r_SM_Main   <= s_Cleanup;
--          end if;
         
--        -- Stay here 1 clock 
--        when s_Cleanup =>
--          o_TX_Active <= '0';
--          r_TX_Done   <= '1';
--          r_SM_Main   <= s_Idle;
 
--        when others =>
--          r_SM_Main <= s_Idle;
 
--      end case;
--    end if;
--  end process p_UART_TX;
 
--  o_TX_Done <= r_TX_Done;
   
--end rtl_tx;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flash_programmer is
    Generic (
        MAX_COUNT : integer := 25000000 / 1000;
        DELAY_MAX_COUNT : integer := 25000000;
        PAGE_SIZE : integer := 8640;
        PAGES_IN_BLOCK : integer := 128;
        BLOCKS_TO_TEST : integer := 1024
    );
    Port (
    led_light : out STD_LOGIC := '1';
    i_clock  : in  STD_LOGIC;
--    uart_tx : out STD_LOGIC;
    debug : out std_logic := '1';
--    i_reset : in std_logic;

    data_out				: in	std_logic_vector(7 downto 0);
    data_in				: out	std_logic_vector(7 downto 0);
    busy					: in	std_logic := '0';
    activate				: out	std_logic := '0';
    cmd_in				: out	std_logic_vector(7 downto 0);
    nand_reset          : out std_logic := '0';
    nand_enable         : out std_logic := '0';
    
    nand_nce : out std_logic := '1'
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
     signal counter : integer := 0;
     
-- signal i_TX_DV : std_logic := '0';         -- Data Valid for Transmission
--    signal i_TX_Byte : std_logic_vector(7 downto 0) := (others => '0');  -- Byte to transmit
--    signal o_TX_Active : std_logic := '0';
--    signal o_TX_Serial : std_logic := '1';
--    signal o_TX_Done : std_logic := '0';

	type STATE_TYPE is (INIT, WRITE_BLOCK, READ_BLOCK, RELEASE, CTRL_BUSY, INDEX_RESET, DELAY, DONE);
	type INIT_SUBSTATE_TYPE is (INIT_START, RESET_DEV, ENABLE_DEV, READ_PARAM, READ_ID);
	type READ_SUBSTATE_TYPE is (READ_START, READ_LOAD_ADDR, READ, EXTRACT, EXTRACT_READBYTE, SEND_ERR, PAGE_READ_DONE);
	type WRITE_SUBSTATE_TYPE is (WRITE_START, DISABLE_WP, ERASE_LOAD_ADDR, ERASE, PROGRAM_LOAD_ADDR, PROGRAM_WRITE_BYTE, PROGRAM, PAGE_WRITE_DONE);
	
	signal state : STATE_TYPE := INIT;
	signal init_substate :INIT_SUBSTATE_TYPE := INIT_START;
	signal read_substate : READ_SUBSTATE_TYPE := READ_START;
	signal write_substate : WRITE_SUBSTATE_TYPE := WRITE_START;
	
	signal next_state : STATE_TYPE;
	signal delay_counter : integer := 0;
	
	signal startup_done : std_logic := '0';
	signal address_bytes_counter : integer := 0;
	signal data_bytes_counter : integer := 0;
	signal reset_index : std_logic := '0';
	
	signal pages_left : integer := PAGES_IN_BLOCK;
	signal page_address     : integer range 0 to 2**19 - 1 := 0;
	signal blocks_tested : integer := 0;
	
	signal int_activate : std_logic := '0';
begin
--    uart_tx_inst : entity work.UART_TX
--        port map (
--            i_Clk       => CLK25MHZ,
--            i_TX_DV     => i_TX_DV,
--            i_TX_Byte   => i_TX_Byte,
--            o_TX_Active => o_TX_Active,
--            o_TX_Serial => uart_tx,  -- Connect the transmit line
--            o_TX_Done   => o_TX_Done
--        );
	
	debug <= i_clock;
	activate <= int_activate;
        
    process(i_clock)
    begin
    led_light <= '0';
    if rising_edge(i_clock) then
    
--        if i_TX_DV = '1' then
--            i_TX_DV <= '0';
--        end if;
        
        if counter = MAX_COUNT then
            counter <= 1;
--            if o_TX_Active = '0' and i_TX_DV = '0' then
--                i_TX_Byte <= std_logic_vector(to_unsigned(71, 8));
--                i_TX_DV <= '1';
--            end if;
            startup_done <= '1';
            nand_reset <= '1';
        else 
            counter <= counter + 1;
        end if;
        
        if int_activate = '1' then
            int_activate <= '0';
        else
            case state is
            when INIT =>
                case init_substate is
                when INIT_START =>
                    next_state <= INIT;
                    
                    if startup_done = '1' then
                        cmd_in <= x"00";
                        init_substate <= ENABLE_DEV;
                        state <= RELEASE;
                   end if;
                   
               -- Enable device
                when ENABLE_DEV =>
                    nand_nce <= '0';
--                    cmd_in <= x"09";
                    init_substate <= RESET_DEV;
--                    state <= RELEASE;
                
                -- Reset device
                when RESET_DEV =>
                    cmd_in <= x"01";
                    init_substate <= READ_PARAM;
                    state <= RELEASE;
                
                -- Read the parameter page
                when READ_PARAM =>
                    data_in <= x"00";
                    cmd_in <= x"02";
                    init_substate <= READ_ID;
                    state <= RELEASE;
                
                -- Read the device ID
                when READ_ID =>
                    data_in <= x"00";
                    cmd_in <= x"03";
                    next_state <= WRITE_BLOCK;
                    write_substate <= WRITE_START;
                    state <= RELEASE;
               end case;
            
            -- These two states are responsible for releasing the command in cmd_in
            -- and waitng until done
            when RELEASE =>
                int_activate <= '1';
                state <= CTRL_BUSY;
            when CTRL_BUSY =>
                if busy = '0' then
                    if reset_index = '1' then
                        state <= INDEX_RESET;
                    else
                        state <= next_state;
                    end if;
                end if;
            when INDEX_RESET =>
                cmd_in <= x"0d";
                reset_index <= '0';
                state <= RELEASE;
                
            when WRITE_BLOCK =>
                case write_substate is
                when WRITE_START =>
                    pages_left <= PAGES_IN_BLOCK;
                    page_address <= blocks_tested * PAGES_IN_BLOCK;
                    address_bytes_counter <= 5;
                    write_substate <= ERASE_LOAD_ADDR;
                    state <= INDEX_RESET;
                    
                when ERASE_LOAD_ADDR =>
                    case address_bytes_counter is
                        when 5 =>
                            data_in <= x"00";
                        when 4 =>
                            data_in <= x"00";
                        when 3 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(7 downto 0));
                        when 2 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(15 downto 8));
                        when 1 =>
                            data_in <= "00000" & std_logic_vector(to_unsigned(page_address, 19)(18 downto 16));
                        when others => data_in <= x"00";
                    end case;
                    cmd_in <= x"13";
                    address_bytes_counter <= address_bytes_counter - 1;
                    state <= RELEASE;
                    if address_bytes_counter = 1 then
                      write_substate <= DISABLE_WP;
                    end if;
                
                when DISABLE_WP =>
                    cmd_in <= x"0c";
                    write_substate <= ERASE;
                    state <= RELEASE;
                    
                when ERASE =>
                    cmd_in <= x"04";
                    write_substate <= PROGRAM_LOAD_ADDR;
                    reset_index <= '1';
                    address_bytes_counter <= 5;
                    state <= RELEASE;
                    
                when PROGRAM_LOAD_ADDR =>
                    case address_bytes_counter is
                        when 5 =>
                            data_in <= x"00";
                        when 4 =>
                            data_in <= x"00";
                        when 3 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(7 downto 0));
                        when 2 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(15 downto 8));
                        when 1 =>
                            data_in <= "00000" & std_logic_vector(to_unsigned(page_address, 19)(18 downto 16));
                        when others => data_in <= x"00";
                    end case;
                    cmd_in <= x"13";
                    address_bytes_counter <= address_bytes_counter - 1;
                    state <= RELEASE;
                    if address_bytes_counter = 1 then
                      write_substate <= PROGRAM_WRITE_BYTE;
                      data_bytes_counter <= PAGE_SIZE;
                      reset_index <= '1';
                    end if;
                
                when PROGRAM_WRITE_BYTE =>
                    data_in <= x"AA";
                    cmd_in <= x"11";
                    data_bytes_counter <= data_bytes_counter - 1;
                    state <= RELEASE;
                    if data_bytes_counter = 1 then
                      write_substate <= PROGRAM;
                    end if;
                    
                when PROGRAM =>
                    cmd_in <= x"07";
                    write_substate <= PAGE_WRITE_DONE;
                    state <= RELEASE;
                    
                when PAGE_WRITE_DONE =>
                    if pages_left > 1 then
                        pages_left <= pages_left - 1;
                        page_address <= page_address + 1;
                        write_substate <= PROGRAM_LOAD_ADDR;
                        address_bytes_counter <= 5;
                        state <= INDEX_RESET;
                    else
                        -- enable WP
                        cmd_in <= x"0b";
                        next_state <= READ_BLOCK;
                        read_substate <= READ_START;
                        state <= RELEASE;
                    end if;
                    
                end case;
                
            when READ_BLOCK =>
                case read_substate is
                
                when READ_START =>
                    address_bytes_counter <= 5;
                    page_address <= blocks_tested * PAGES_IN_BLOCK;
                    pages_left <= PAGES_IN_BLOCK;
                    read_substate <= READ_LOAD_ADDR;
                    state <= INDEX_RESET;
                    
                
                when READ_LOAD_ADDR =>
                    case address_bytes_counter is
                        when 5 =>
                            data_in <= x"00";
                        when 4 =>
                            data_in <= x"00";
                        when 3 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(7 downto 0));
                        when 2 =>
                            data_in <= std_logic_vector(to_unsigned(page_address, 19)(15 downto 8));
                        when 1 =>
                            data_in <= "00000" & std_logic_vector(to_unsigned(page_address, 19)(18 downto 16));
                        when others => data_in <= x"00";
                    end case;
                    cmd_in <= x"13";
                    address_bytes_counter <= address_bytes_counter - 1;
                    state <= RELEASE;
                    if address_bytes_counter = 1 then
                      read_substate <= READ;
                    end if;
		    
                when READ =>
                    data_in <= x"00";
                    cmd_in <= x"06";
                    reset_index <= '1';
                    read_substate <= EXTRACT;
--                    next_state <= DONE;
                    data_bytes_counter <= 0;
                    state <= RELEASE;
                
                when EXTRACT =>
                    cmd_in <= x"08";
--                    cmd_in <= x"10";
                    read_substate <= EXTRACT_READBYTE;
                    state <= RELEASE;
                    data_bytes_counter <= data_bytes_counter + 1;
                    if data_bytes_counter = PAGE_SIZE then
                        read_substate <= PAGE_READ_DONE;
    --                    state <= WRITE_BLOCK;
    --                    write_substate <= WRITE_START;
    --                    led_light <= '1'; 
                    end if;             
                
                when EXTRACT_READBYTE =>
--                    if data_out = x"AA" then
                        read_substate <= EXTRACT;
--                    else
--                        read_substate <= SEND_ERR; 
--                    end if;
                
                when SEND_ERR =>
--                    if o_TX_Active = '0' and i_TX_DV = '0' then
--                        i_TX_Byte <= data_out;
--                        i_TX_DV <= '1';
        --                    state <= DELAY;
--                        read_substate <= EXTRACT;
--                    end if;
                
                when PAGE_READ_DONE =>
                    if pages_left > 1 then
                        pages_left <= pages_left - 1;
                        page_address <= page_address + 1;
                        read_substate <= READ_LOAD_ADDR;
                        address_bytes_counter <= 5;
                        state <= INDEX_RESET;
                    else
                        state <= DONE;
                    end if;
                    
            end case;
                
            when DELAY =>
                if delay_counter = DELAY_MAX_COUNT then
                    delay_counter <= 0;
--                    cmd_in <= x"00";
--                    state <= EXTRACT;
--                    state <= RELEASE;
                else 
                    delay_counter <= delay_counter + 1;
                end if;
            
            when DONE => --null;
            
                if blocks_tested + 1 < BLOCKS_TO_TEST then
                    write_substate <= WRITE_START;
                    state <= WRITE_BLOCK;
                    next_state <= WRITE_BLOCK;
                    blocks_tested <= blocks_tested + 1;
                else
                   led_light <= '1'; 
                end if;
                
--            when others => null;
            end case;
        end if;
    end if;
    end process;

end Behavioral;
