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
        BLOCKS_TO_TEST : integer := 1024;
        NUM_OF_DEVICES : integer := 1
    );
    Port (
    led_light : out STD_LOGIC := '0';
    i_clock  : in  STD_LOGIC;
    i_reset : in std_logic := '0';
    
    o_activate : out std_logic := '0';
    o_cmd : out std_logic_vector(7 downto 0) := (others => '0');
    o_address : out std_logic_vector(39 downto 0) := (others => '0');
    o_data : out std_logic_vector(7 downto 0) := (others => '0');
    i_data : in std_logic_vector(7 downto 0);
    i_busy : in std_logic;
    i_read_done : in std_logic;
    
    o_TX_DV : out std_logic := '0';         -- Data Valid for Transmission
    o_TX_Byte : out std_logic_vector(7 downto 0) := (others => '0');  -- Byte to transmit
    i_TX_Active : in std_logic;
    i_TX_Done : in std_logic := '0';
    
    o_nand_nce : out std_logic_vector(NUM_OF_DEVICES-1 downto 0) := (others => '1')
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
    signal counter : integer := 0;
    signal device_counter : integer := 0;

	type STATE_TYPE is (IDLE, INIT,  WRITE_BLOCK, READ_BLOCK, RELEASE, CTRL_BUSY, DONE);
	type WRITE_SUBSTATE_TYPE is (WRITE_START, ERASE, ERASE_GET_STATUS, ERASE_CHECK, PROGRAM, PAGE_WRITE_DONE);
	type READ_SUBSTATE_TYPE is (READ_START, READ, EXTRACT, EXTRACT_READBYTE, SEND_ERR, PAGE_READ_DONE);
	
	signal state : STATE_TYPE := IDLE;
	signal write_substate : WRITE_SUBSTATE_TYPE := WRITE_START;
	signal read_substate : READ_SUBSTATE_TYPE := READ_START;
	
	signal next_state : STATE_TYPE;
	
	signal pages_left : integer := PAGES_IN_BLOCK;
	signal page_address     : integer range 0 to 2**19 - 1 := 0;
	signal blocks_tested : integer := 0;
	
	signal int_activate : std_logic := '0';
	signal int_uart_dv : std_logic := '0';
begin
	o_activate <= int_activate;
	o_TX_DV <= int_uart_dv;
        
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
            device_counter <= 0;
            state                     <= INIT;
            write_substate            <= WRITE_START;
            read_substate             <= READ_START;
            next_state                <= INIT;
            pages_left                <= PAGES_IN_BLOCK;
            page_address              <= 0;
            blocks_tested             <= 0;
            int_activate              <= '0';
            int_uart_dv               <= '0';
    
            led_light                 <= '0';
            o_data                   <= (others => '0');
            o_cmd                    <= (others => '0');
            o_TX_Byte                 <= (others => '0');
            o_nand_nce                  <= (others => '1');
            
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
            if i_busy = '0' then
                state <= next_state;
            end if;
            
        when INIT =>
            if counter = MAX_COUNT then
    --            if o_TX_Active = '0' and int_uart_dv = '0' then
    --                i_TX_Byte <= std_logic_vector(to_unsigned(71, 8));
    --                int_uart_dv <= '1';
    --            end if;
                o_nand_nce <= (others => '0'); -- reset all devices at once
                o_cmd <= x"01";
                next_state <= WRITE_BLOCK;
                write_substate <= WRITE_START;
                state <= RELEASE;
            else 
                counter <= counter + 1;
            end if;
            
        when WRITE_BLOCK =>
            case write_substate is
            when WRITE_START =>
                pages_left <= PAGES_IN_BLOCK;
                page_address <= blocks_tested * PAGES_IN_BLOCK;
                write_substate <= ERASE;
                
            when ERASE =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                
                o_nand_nce <= (others => '0'); -- erase all at once
                o_cmd <= x"03";
                write_substate <= ERASE_GET_STATUS;
                device_counter <= 0;
                state <= RELEASE;
            
            when ERASE_GET_STATUS =>
                if device_counter < NUM_OF_DEVICES then
                    o_nand_nce <= (others => '1');
                    o_nand_nce(device_counter) <= '0';
                    
                    write_substate <= ERASE_CHECK;
                    device_counter <= device_counter + 1;
                    o_cmd <= x"02";
                    state <= RELEASE;
                else
                    write_substate <= PROGRAM;
                end if;
            
            when ERASE_CHECK =>
                if i_data(5) = '1' then 
                    if i_data(0) = '1' then
                        state <= DONE;
                    else
                        write_substate <= ERASE_GET_STATUS;
                    end if;
                else
                    o_cmd <= x"02";
                    state <= RELEASE;
                end if;
                
            when PROGRAM =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                
                o_nand_nce <= (others => '0'); -- program all at once
                o_cmd <= x"04";
                o_data <= x"AA";
                write_substate <= PAGE_WRITE_DONE;
                state <= RELEASE;
                
            when PAGE_WRITE_DONE =>
                if pages_left > 1 then
                    pages_left <= pages_left - 1;
                    page_address <= page_address + 1;
                    write_substate <= PROGRAM;
                else
                    read_substate <= READ_START;
                    state <= READ_BLOCK;
                end if;
                
            end case;
            
        when READ_BLOCK =>
            case read_substate is
            
            when READ_START =>
                device_counter <= 0;
                next_state <= READ_BLOCK;
                page_address <= blocks_tested * PAGES_IN_BLOCK;
                pages_left <= PAGES_IN_BLOCK;
                read_substate <= READ;
        
            when READ =>
                o_nand_nce <= (others => '1');
                o_nand_nce(device_counter) <= '0';
                
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                
                o_cmd <= x"05";
                read_substate <= EXTRACT;
                state <= RELEASE;
            
            when EXTRACT =>
                if i_read_done = '1' then
                    read_substate <= PAGE_READ_DONE;
                else
                    read_substate <= EXTRACT_READBYTE;
                    state <= RELEASE;
                end if;             
            
            when EXTRACT_READBYTE =>
                if i_data = x"AA" then
                    read_substate <= EXTRACT;
                else
                    read_substate <= SEND_ERR; 
                end if;
            
            when SEND_ERR => 
                if i_TX_Active = '0' and int_uart_dv = '0' then
                    o_TX_Byte <= i_data;
                    int_uart_dv <= '1';
                    read_substate <= EXTRACT;
                end if;
            
            when PAGE_READ_DONE =>
                if device_counter + 1 < NUM_OF_DEVICES then
                    device_counter <= device_counter + 1;
                    read_substate <= READ;
                else
                    device_counter <= 0;
                    -- if all devices are done, move to the next page
                    if pages_left > 1 then
                        pages_left <= pages_left - 1;
                        page_address <= page_address + 1;
                        read_substate <= READ;
                    else
                        state <= DONE;
                    end if;
                end if;
            end case;
        
        when DONE =>
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
