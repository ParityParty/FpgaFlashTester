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
        MAX_FAULTS : integer := 5
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
    i_command_received : in std_logic;
    
    o_debug : out std_logic := '0';
    
    o_TX_DV : out std_logic := '0';         -- Data Valid for Transmission
    o_TX_Byte : out std_logic_vector(7 downto 0) := (others => '0');  -- Byte to transmit
    i_TX_Active : in std_logic;
    i_TX_Done : in std_logic := '0'
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
    signal counter : integer := 0;
    signal fault_counter : integer := 0;

	type state_t is (S_IDLE, S_INIT, S_SEND_CHECK, S_NAND_RESET, S_ERASE_BLOCK, S_PROGRAM_BLOCK, S_READ_BLOCK, S_RELEASE, S_CTRL_BUSY, S_NEXT_BLOCK, S_DONE, S_ERROR);
	type substate_t is (SS_INIT, SS_SEND_CMD, SS_CHECK_RECEIVED, SS_GET_DATA, SS_CHECK_DATA, SS_NEXT_PAGE, SS_DONE);
	
	type READ_SUBSTATE_TYPE is (READ_START, READ, EXTRACT, EXTRACT_READBYTE, SEND_ERR, PAGE_READ_DONE);
	
	signal state : state_t := S_IDLE;
	signal substate : substate_t := SS_INIT;
	
	signal next_state : state_t;
	
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
        state <= S_IDLE;
    
    elsif rising_edge(i_clock) then
    
        o_debug <= '0';
    
        if int_uart_dv = '1' then
            int_uart_dv <= '0';
        end if;
        
        case state is
        when S_IDLE =>
            counter                   <= 0;
            state                     <= S_INIT;
            next_state                <= S_INIT;
            substate                  <= SS_INIT;
            page_address              <= 0;
            blocks_tested             <= 0;
            int_activate              <= '0';
            int_uart_dv               <= '0';
    
            led_light                 <= '0';
            o_data                   <= (others => '0');
            o_cmd                    <= (others => '0');
            o_TX_Byte                 <= (others => '0');
            
        -- These two states are responsible for releasing the command in cmd_in
        -- and waitng until done
        when S_RELEASE =>
            if int_activate = '1' then
                int_activate <= '0';
                state <= S_CTRL_BUSY;
            else
                int_activate <= '1';
            end if;
            
        when S_CTRL_BUSY =>
            if i_busy = '0' then
                state <= next_state;
            end if;
            
        when S_INIT =>
            if counter = MAX_COUNT then
    --            if o_TX_Active = '0' and int_uart_dv = '0' then
    --                i_TX_Byte <= std_logic_vector(to_unsigned(71, 8));
    --                int_uart_dv <= '1';
    --            end if;
                state <= S_NAND_RESET;
            else 
                counter <= counter + 1;
            end if;
        
        when S_NAND_RESET =>
            case substate is
            when SS_INIT =>
                next_state <= S_NAND_RESET;
                substate <= SS_SEND_CMD;
                
            when SS_SEND_CMD =>
                o_cmd <= x"01";
                state <= S_RELEASE;
                substate <= SS_CHECK_RECEIVED;
            
            when SS_CHECK_RECEIVED =>
                if i_command_received = '0' then
                    if i_TX_Active = '0' and int_uart_dv = '0' then
                        o_TX_Byte <= x"E0";
                        int_uart_dv <= '1';
                        state <= S_ERROR;
                    end if;
                else
                    substate <= SS_DONE;
                end if;
            
            when SS_DONE => 
                if i_TX_Active = '0' and int_uart_dv = '0' then
                    o_TX_Byte <= x"A0";
                    int_uart_dv <= '1';
                    
                    state <= S_ERASE_BLOCK;
                    substate <= SS_INIT;
                end if;
            
            when others => state <= S_ERROR;
            end case;
        
        when S_ERASE_BLOCK =>
            case substate is
            when SS_INIT =>
                next_state <= S_ERASE_BLOCK;
                page_address <= blocks_tested * PAGES_IN_BLOCK;
                substate <= SS_SEND_CMD;
                fault_counter <= 0;
            
            when SS_SEND_CMD =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                o_cmd <= x"03";
                state <= S_RELEASE;
                substate <= SS_CHECK_RECEIVED;
                
            when SS_CHECK_RECEIVED =>
                if i_command_received = '0' then
                    if i_TX_Active = '0' and int_uart_dv = '0' then
                        o_TX_Byte <= x"E1";
                        int_uart_dv <= '1';
                        state <= S_NEXT_BLOCK;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_GET_DATA => 
                o_cmd <= x"02";
                state <= S_RELEASE;
                substate <= SS_CHECK_DATA;
            
            when SS_CHECK_DATA =>
                if i_data(5) = '1' then 
                    if i_data(0) = '1' and fault_counter < MAX_FAULTS then
                        substate <= SS_SEND_CMD;
                        fault_counter <= fault_counter + 1;
                    elsif i_data(0) = '1' then 
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Byte <= x"E2";
                            int_uart_dv <= '1';
                            state <= S_NEXT_BLOCK;
                        end if;
                    else
                        substate <= SS_DONE;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_DONE =>
                if i_TX_Active = '0' and int_uart_dv = '0' then
                    o_TX_Byte <= x"A1";
                    int_uart_dv <= '1';
                    
                    state <= S_PROGRAM_BLOCK;
                    substate <= SS_INIT;
                end if;
            
            when others => state <= S_ERROR;
            end case;
        
        when S_PROGRAM_BLOCK =>
            case substate is
            when SS_INIT =>
                next_state <= S_PROGRAM_BLOCK;
                page_address <= blocks_tested * PAGES_IN_BLOCK;
                substate <= SS_SEND_CMD;
                fault_counter <= 0;
                
            when SS_SEND_CMD =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                o_cmd <= x"04";
                o_data <= x"AA";
                substate <= SS_CHECK_RECEIVED;
                state <= S_RELEASE;
                
            when SS_CHECK_RECEIVED =>
                if i_command_received = '0' then
                    if i_TX_Active = '0' and int_uart_dv = '0' then
                        o_TX_Byte <= x"E3";
                        int_uart_dv <= '1';
                        substate <= SS_NEXT_PAGE;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_GET_DATA => 
                o_cmd <= x"02";
                state <= S_RELEASE;
                substate <= SS_CHECK_DATA;
            
            when SS_CHECK_DATA =>
                if i_data(5) = '1' then 
                    if i_data(0) = '1' and fault_counter < MAX_FAULTS then
                        fault_counter <= fault_counter + 1;
                        substate <= SS_SEND_CMD;
                    elsif i_data(0) = '1' then 
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Byte <= x"E4";
                            int_uart_dv <= '1';
                            substate <= SS_NEXT_PAGE;
                        end if;
                    else
                        substate <= SS_NEXT_PAGE;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_NEXT_PAGE =>
                if page_address + 1 < (blocks_tested + 1) * PAGES_IN_BLOCK then
                    page_address <= page_address + 1;
                    substate <= SS_SEND_CMD;
                else
                    substate <= SS_DONE;
                end if;
            
            when SS_DONE =>
                state <= S_READ_BLOCK;
                substate <= SS_INIT;

            when others => state <= S_ERROR;
            end case;
            
        when S_READ_BLOCK =>
            case substate is
            when SS_INIT =>
                next_state <= S_READ_BLOCK;
                page_address <= blocks_tested * PAGES_IN_BLOCK;
                substate <= SS_SEND_CMD;
        
            when SS_SEND_CMD =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                o_cmd <= x"05";
                substate <= SS_CHECK_RECEIVED;
                state <= S_RELEASE;
            
            when SS_CHECK_RECEIVED =>
                if i_command_received = '0' then
                    if i_TX_Active = '0' and int_uart_dv = '0' then
                        o_TX_Byte <= x"E5";
                        int_uart_dv <= '1';
                        substate <= SS_NEXT_PAGE;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_GET_DATA =>
                o_debug <= '1';
                if i_read_done = '1' then
                    substate <= SS_NEXT_PAGE;
                else
                    substate <= SS_CHECK_DATA;
                    state <= S_RELEASE;
                end if;             
            
            when SS_CHECK_DATA =>
                if i_data = x"AA" then
                    substate <= SS_GET_DATA;
                else
                    if i_TX_Active = '0' and int_uart_dv = '0' then
                        o_TX_Byte <= i_data;
                        int_uart_dv <= '1';
                        substate <= SS_GET_DATA;
                    end if;
                end if;
            
            when SS_NEXT_PAGE =>
                if page_address + 1 < (blocks_tested + 1) * PAGES_IN_BLOCK then
                    page_address <= page_address + 1;
                    substate <= SS_SEND_CMD;
                else
                    substate <= SS_DONE;
                end if;
            
            when SS_DONE =>
                state <= S_NEXT_BLOCK;

            when others => state <= S_ERROR;
            end case;
        
        when S_NEXT_BLOCK =>
            if blocks_tested + 1 < BLOCKS_TO_TEST then
                state <= S_ERASE_BLOCK;
                substate <= SS_INIT;
                blocks_tested <= blocks_tested + 1;
            else
               state <= S_DONE;
            end if;
        
        when S_ERROR => null;
        when S_DONE => led_light <= '1'; 
        when others => state <= S_ERROR;
        end case;
    end if;
    end process;

end Behavioral;
