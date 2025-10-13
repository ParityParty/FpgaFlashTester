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
        MAX_COUNT : integer := 50000000;
        PAGE_SIZE : integer := 8640;
        PAGES_IN_BLOCK : integer := 128;
        BLOCKS_TO_TEST : integer := 5;
        MAX_FAULTS : integer := 5;
        UART_MAX_BYTES : integer := 7;
        BLOCK_OFFSET : integer := 3
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
    o_TX_Data    : out  std_logic_vector(UART_MAX_BYTES*8 - 1 downto 0); -- Bytes to transmit
    o_TX_Num_Bytes : out std_logic_vector(2 downto 0);
    i_TX_Active : in std_logic
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
    signal counter : integer := 0;
    signal byte_counter : integer range 0 to 2**16 - 1 := 0;
    signal fault_counter : integer := 0;

	type state_t is (S_IDLE, S_INIT, S_NAND_RESET, S_ERASE_BLOCK, S_PROGRAM_PAGE, S_NEXT_PAGE, S_RELEASE, S_CTRL_BUSY, S_NEXT_BLOCK, S_DONE, S_ERROR);
	type substate_t is (SS_INIT, SS_SEND_CMD, SS_GET_DATA, SS_CHECK_DATA, SS_DONE);
	
	signal state : state_t := S_IDLE;
	signal substate : substate_t := SS_INIT;
	
	signal next_state : state_t;
	
	signal page_address     : integer range 0 to 2**19 - 1 := 0;
	signal blocks_tested : integer := 0;
	
	signal int_activate : std_logic := '0';
	signal int_uart_dv : std_logic := '0';
	
	signal last_bad_byte : std_logic_vector(7 downto 0);
	signal same_bad_byte_counter : integer range 0 to 2**16 - 1 := 0;
	signal test_byte : std_logic_vector(7 downto 0) := x"55";
begin
	o_activate <= int_activate;
	o_TX_DV <= int_uart_dv;
        
    process(i_clock, i_reset)
    begin
    if i_reset = '0' then
        state <= S_IDLE;
    
    elsif rising_edge(i_clock) then
    
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
            test_byte <= x"55";
    
            led_light                 <= '0';
            o_data                   <= (others => '0');
            o_cmd                    <= (others => '0');
            o_TX_Data                 <= (others => '0');
            
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
            if counter = MAX_COUNT / 1000 then
                o_TX_Data(7 downto 0) <= x"53";
                o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                int_uart_dv <= '1';
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
                substate <= SS_DONE;
            
            when SS_DONE => 
                if i_TX_Active = '0' and int_uart_dv = '0' then
                    o_TX_Data(7 downto 0) <= x"A0";
                    o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
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
                page_address <= (blocks_tested + BLOCK_OFFSET) * PAGES_IN_BLOCK;
                substate <= SS_SEND_CMD;
                fault_counter <= 0;
            
            when SS_SEND_CMD =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                o_cmd <= x"03";
                state <= S_RELEASE;
                substate <= SS_GET_DATA;
            
            when SS_GET_DATA => 
                o_cmd <= x"02";
                state <= S_RELEASE;
                substate <= SS_CHECK_DATA;
            
            when SS_CHECK_DATA =>
                if i_data(5) = '1' then 
                    if i_data(0) = '1' and fault_counter < MAX_FAULTS then
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Data(7 downto 0) <= x"E0";
                            o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                            int_uart_dv <= '1';
                            
                            substate <= SS_SEND_CMD;
                            fault_counter <= fault_counter + 1;
                        end if;
                    elsif i_data(0) = '1' then 
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Data(7 downto 0) <= x"E1";
                            o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
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
                    o_TX_Data(7 downto 0) <= x"A1";
                    o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                    int_uart_dv <= '1';
                    
                    state <= S_PROGRAM_PAGE;
                    substate <= SS_INIT;
                end if;
            
            when others => state <= S_ERROR;
            end case;
        
        when S_PROGRAM_PAGE =>
            case substate is
            when SS_INIT =>
                next_state <= S_PROGRAM_PAGE;
                substate <= SS_SEND_CMD;
                fault_counter <= 0;
                
            when SS_SEND_CMD =>
                o_address <= (others => '0');
                o_address(34 downto 16) <= std_logic_vector(to_unsigned(page_address, 19));
                o_cmd <= x"04";
                o_data <= test_byte;
                state <= S_RELEASE;
                substate <= SS_GET_DATA;
            
            when SS_GET_DATA => 
                o_cmd <= x"02";
                state <= S_RELEASE;
                substate <= SS_CHECK_DATA;
            
            when SS_CHECK_DATA =>
                if i_data(5) = '1' then 
                    if i_data(0) = '1' and fault_counter < MAX_FAULTS then
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Data(7 downto 0) <= x"E2";
                            o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                            int_uart_dv <= '1';
                            
                            fault_counter <= fault_counter + 1;
                            substate <= SS_SEND_CMD;
                        end if;
                    elsif i_data(0) = '1' then 
                        if i_TX_Active = '0' and int_uart_dv = '0' then
                            o_TX_Data(7 downto 0) <= x"E3";
                            o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                            int_uart_dv <= '1';
                            
                            state <= S_NEXT_PAGE;
                            substate <= SS_INIT;
                        end if;
                    else
                        substate <= SS_DONE;
                    end if;
                else
                    substate <= SS_GET_DATA;
                end if;
            
            when SS_DONE =>
                if i_TX_Active = '0' and int_uart_dv = '0' then
                    o_TX_Data(7 downto 0) <= x"A2";
                    o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                    int_uart_dv <= '1';
                    
                    state <= S_NEXT_PAGE;
                    substate <= SS_INIT;
                end if;

            when others => state <= S_ERROR;
            end case;
        
        when S_NEXT_PAGE =>
            if page_address + 1 < (blocks_tested + BLOCK_OFFSET + 1) * PAGES_IN_BLOCK then
                page_address <= page_address + 1;
                substate <= SS_INIT;
                state <= S_PROGRAM_PAGE;
            else
                state <= S_NEXT_BLOCK;
            end if;
        
        when S_NEXT_BLOCK =>
            if i_TX_Active = '0' and int_uart_dv = '0' then
                o_TX_Data(7 downto 0) <= x"A5";
                o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                int_uart_dv <= '1';
                
                if blocks_tested + 1 < BLOCKS_TO_TEST then
                    state <= S_ERASE_BLOCK;
                    substate <= SS_INIT;
                    blocks_tested <= blocks_tested + 1;
                else
                    counter <= 0;
                    state <= S_DONE;
                end if;
            end if;
        
        when S_ERROR => null;
        when S_DONE => 
            led_light <= '1';
            if counter = MAX_COUNT then
                o_TX_Data(7 downto 0) <= x"DD";
                o_TX_Num_Bytes <= std_logic_vector(to_unsigned(1, 3));
                int_uart_dv <= '1';
                counter <= 0;
            else 
                counter <= counter + 1;
            end if;
            
        when others => state <= S_ERROR;
        end case;
    end if;
    end process;

end Behavioral;
