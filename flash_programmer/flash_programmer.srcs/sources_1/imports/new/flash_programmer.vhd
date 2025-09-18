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
use IEEE.NUMERIC_STD.ALL;

entity flash_programmer is
    Generic (
        MAX_COUNT : integer := 25000000 / 1000;
        DELAY_MAX_COUNT : integer := 3;
        PAGE_SIZE : integer := 8640;
        PAGES_IN_BLOCK : integer := 128;
        BLOCKS_TO_TEST : integer := 1024
    );
    Port (
    led_light : out STD_LOGIC := '0';
    i_clock  : in  STD_LOGIC;
--    uart_tx : out STD_LOGIC;
--    debug : out std_logic := '1';
    i_reset : in std_logic := '0';

    data_out				: in	std_logic_vector(7 downto 0);
    data_in				: out	std_logic_vector(7 downto 0);
    busy					: in	std_logic := '0';
    activate				: out	std_logic := '0';
    cmd_in				: out	std_logic_vector(7 downto 0);
    nand_enable         : out std_logic := '0';
    
    i_TX_DV : out std_logic := '0';         -- Data Valid for Transmission
    i_TX_Byte : out std_logic_vector(7 downto 0) := (others => '0');  -- Byte to transmit
    o_TX_Active : in std_logic;
    o_TX_Done : in std_logic := '0';
    
    nand_nce : out std_logic := '1'
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
     signal counter : integer := 0;
    signal delay_counter : integer := 0;
    

	type STATE_TYPE is (IDLE, INIT,  WRITE_BLOCK, READ_BLOCK, RELEASE, CTRL_BUSY, INDEX_RESET, GET_STATUS, DONE);
	type INIT_SUBSTATE_TYPE is (INIT_START, RESET_DEV, ENABLE_DEV, READ_PARAM, READ_ID);
	type WRITE_SUBSTATE_TYPE is (WRITE_START, DISABLE_WP, ERASE_LOAD_ADDR, ERASE, ERASE_CHECK, PROGRAM_LOAD_ADDR, PROGRAM_WRITE_BYTE, PROGRAM, PAGE_WRITE_DONE);
	type READ_SUBSTATE_TYPE is (READ_START, READ_LOAD_ADDR, READ, EXTRACT, EXTRACT_READBYTE, SEND_ERR, PAGE_READ_DONE);
	
	signal state : STATE_TYPE := IDLE;
	signal init_substate :INIT_SUBSTATE_TYPE := INIT_START;
	signal write_substate : WRITE_SUBSTATE_TYPE := WRITE_START;
	signal read_substate : READ_SUBSTATE_TYPE := READ_START;
	
	signal next_state : STATE_TYPE;
	
	signal address_bytes_counter : integer := 0;
	signal data_bytes_counter : integer := 0;
	
	signal reset_index_after_release : std_logic := '0';
	signal get_status_after_release : std_logic := '0';
	
	signal pages_left : integer := PAGES_IN_BLOCK;
	signal page_address     : integer range 0 to 2**19 - 1 := 0;
	signal blocks_tested : integer := 0;
	
	signal int_activate : std_logic := '0';
	signal int_uart_dv : std_logic := '0';
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
	
--	debug <= busy;
	activate <= int_activate;
	i_TX_DV <= int_uart_dv;
        
    process(i_clock, i_reset)
    begin
    if i_reset = '0' then
        state <= IDLE;
    
    elsif rising_edge(i_clock) then
    
        if int_uart_dv = '1' then
            int_uart_dv <= '0';
        end if;
        
        case state is
        when IDLE =>
            counter                   <= 0;
            state                     <= INIT;
            init_substate             <= INIT_START;
            write_substate            <= WRITE_START;
            read_substate             <= READ_START;
            next_state                <= INIT;
            delay_counter             <= 0;
            address_bytes_counter     <= 0;
            data_bytes_counter        <= 0;
            reset_index_after_release <= '0';
            get_status_after_release  <= '0';
            pages_left                <= PAGES_IN_BLOCK;
            page_address              <= 0;
            blocks_tested             <= 0;
            int_activate              <= '0';
            int_uart_dv               <= '0';
    
            led_light                 <= '0';
            data_in                   <= (others => '0');
            cmd_in                    <= (others => '0');
            nand_enable               <= '0';
            i_TX_Byte                 <= (others => '0');
            nand_nce                  <= '1';
            
        -- These two states are responsible for releasing the command in cmd_in
        -- and waitng until done
        when RELEASE =>
            if int_activate = '1' then
                int_activate <= '0';
                state <= CTRL_BUSY;
            else
                int_activate <= '1';
            end if;
            
        when CTRL_BUSY =>
            if busy = '0' and delay_counter > DELAY_MAX_COUNT then
                if reset_index_after_release = '1' then
                    state <= INDEX_RESET;
                elsif get_status_after_release = '1' then
                    state <= GET_STATUS;
                else 
                    state <= next_state;
                end if;
                delay_counter <= 0;
            else
                delay_counter <= delay_counter + 1;
            end if;
            
        when INDEX_RESET =>
            cmd_in <= x"0d";
            reset_index_after_release <= '0';
            state <= RELEASE;
        when GET_STATUS =>
            cmd_in <= x"05";
            get_status_after_release <= '0';
            state <= RELEASE;
            
        when INIT =>
            case init_substate is
            when INIT_START =>
                next_state <= INIT;
                
                if counter = MAX_COUNT then
        --            if o_TX_Active = '0' and int_uart_dv = '0' then
        --                i_TX_Byte <= std_logic_vector(to_unsigned(71, 8));
        --                int_uart_dv <= '1';
        --            end if;
                    cmd_in <= x"00";
                    init_substate <= ENABLE_DEV;
                    state <= RELEASE;
                else 
                    counter <= counter + 1;
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
                write_substate <= ERASE_CHECK;
                reset_index_after_release <= '1';
                get_status_after_release <= '1';
                address_bytes_counter <= 5;
                state <= RELEASE;
            
            when ERASE_CHECK =>
                if data_out(5) = '1' then 
                    if data_out(0) = '1' then
                        state <= DONE;
                    else
                        write_substate <= PROGRAM_LOAD_ADDR;
                    end if;
                else
                    state <= GET_STATUS;
                end if;
                
                
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
                  reset_index_after_release <= '1';
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
                reset_index_after_release <= '1';
                read_substate <= EXTRACT;
--                    next_state <= DONE;
                data_bytes_counter <= 0;
                state <= RELEASE;
            
            when EXTRACT =>
--                    cmd_in <= x"08";
                cmd_in <= x"10";
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
                if data_out = x"AA" then
                    read_substate <= EXTRACT;
                else
                    read_substate <= SEND_ERR; 
                end if;
            
            when SEND_ERR => 
                if o_TX_Active = '0' and int_uart_dv = '0' then
                    i_TX_Byte <= data_out;
                    int_uart_dv <= '1';
                    read_substate <= EXTRACT;
                end if;
            
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
    end process;

end Behavioral;
