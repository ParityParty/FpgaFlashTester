library ieee;
use ieee.std_logic_1164.all;

package onfi_timings is
    constant clock_cycle	: real := 10.0; -- ns
--    constant clock_cycle	: real := 1.0; -- ns

    constant	t_cls		:	integer	:= integer(50.0	/ clock_cycle);
	constant	t_clh		:	integer	:= integer(20.0 	/ clock_cycle);
	constant	t_wp		:	integer	:= integer(50.0 	/ clock_cycle);
	constant	t_wh		:	integer	:= integer(30.0		/ clock_cycle);
	constant	t_wc		:	integer	:= integer(100.0	/ clock_cycle);
	constant	t_ds		:	integer	:= integer(40.0		/ clock_cycle);
	constant	t_dh		:	integer	:= integer(20.0		/ clock_cycle);
	constant	t_als		:	integer	:= integer(50.0	/ clock_cycle);
	constant	t_alh		:	integer	:= integer(20.0		/ clock_cycle);
	constant	t_rr		:	integer	:= integer(40.0	/ clock_cycle);
	constant	t_rea		:	integer	:= integer(40.0	/ clock_cycle);
	constant	t_rp		:	integer	:= integer(50.0	/ clock_cycle);
	constant	t_reh		:	integer	:= integer(30.0		/ clock_cycle);
	constant	t_wb		:	integer	:= integer(200.0	/ clock_cycle);
	constant	t_rst		:	integer	:= integer(5000.0	/ clock_cycle);
	constant	t_bers	:	integer	:=	integer(700000.0 / clock_cycle);
	constant	t_whr		:	integer	:=	integer(120.0	/ clock_cycle);
	constant	t_prog	:	integer	:=	integer(600000.0 / clock_cycle);
	constant	t_adl		:	integer	:=	integer(200.0	/ clock_cycle);
	constant	t_cs		:	integer	:=	integer(70.0	/ clock_cycle);
	
	constant ADDR_LENGTH : integer := 5;
end onfi_timings;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.onfi_timings.all;

entity nand_controller is
    Generic (
        PAGE_SIZE : integer := 10
    );
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_activate : in std_logic;
           i_cmd : in std_logic_vector(7 downto 0);
           i_address : in std_logic_vector(ADDR_LENGTH*8-1 downto 0);
           i_data : in std_logic_vector(7 downto 0);
           o_data : out std_logic_vector(7 downto 0) := (others => '0');
           o_busy : out std_logic := '0';
           o_read_done : out std_logic := '0';
           
           i_nand_rb : in std_logic;
           o_nand_we : out std_logic := '1';
           o_nand_wp : out std_logic := '0';
           o_nand_cle : out std_logic := '0';
           o_nand_ale : out std_logic := '0';
           o_nand_re : out std_logic := '1';
           io_nand_data : inout std_logic_vector(7 downto 0) := (others => 'Z');
           o_nand_ce : out std_logic := '1'
           );
end nand_controller;

architecture Behavioral of nand_controller is
    type state_t is (S_IDLE, S_READY, S_RESET, S_ERASE, S_STATUS, S_PROGRAM, S_READ, S_READ_BYTE, S_WRITE_BYTE, S_HOLD, S_DELAY, S_WAIT, S_ERROR);
    signal state : state_t;
    signal n_state : state_t;
    signal hold_return_state : state_t;
    
    type substate_t is (SS_INIT, SS_WAIT, SS_DELAY, SS_READ, SS_WRITE, SS_WRITE_ADR, SS_DONE);
    signal substate : substate_t;
    
    signal delay : integer := 0;
    signal byte_to_send : std_logic_vector(7 downto 0) := (others => '0');
    signal stage : integer := 0;
    signal byte_counter : integer := 0;
    
    signal write_with_cle : std_logic := '0';
    signal write_with_ale : std_logic := '0';
begin

    process(i_clk, i_rst)
    begin
    if i_rst = '0' then
        state <= S_IDLE;
    
    elsif rising_edge(i_clk) then
        case state is
        when S_IDLE =>
            o_data <= (others => '0');
            o_read_done <= '0';
            
            o_nand_we <= '1';
            o_nand_wp <= '0';
            o_nand_cle <= '0';
            o_nand_ale <= '0';
            o_nand_re <= '1';
            io_nand_data <= (others => 'Z');
            o_nand_ce <= '1';
            
            state <= S_READY;
            n_state <= S_READY;
            write_with_cle <= '0';
            write_with_ale <= '0';
            o_busy <= '1';
            
        when S_READY =>
            o_nand_ce <= '0';
            o_nand_wp <= '1';
            o_busy <= '0';
            if i_activate = '1' then
                o_busy <= '1';
                substate <= SS_INIT;
                case i_cmd is
                when x"01" => state <= S_RESET;
                when x"02" => state <= S_STATUS;
                when x"03" => state <= S_ERASE;
                when x"04" => state <= S_PROGRAM;
                when x"05" => state <= S_READ;
                when others => state <= S_ERROR; -- error
                end case;
            end if;
            
        when S_RESET =>
            case substate is
            when SS_INIT =>
                byte_to_send <= x"FF";
                stage <= 0;
                state <= S_WRITE_BYTE;
                write_with_cle <= '1';
                n_state <= S_RESET;
                substate <= SS_WAIT;
                
            when SS_WAIT =>
                delay <= t_wb;
                state <= S_WAIT;
                substate <= SS_DONE;
                
            when SS_DONE => state <= S_READY;
            when others => state <= S_ERROR; -- error
            end case;
        
        when S_STATUS =>
            case substate is
            when SS_INIT =>
                byte_to_send <= x"70";
                stage <= 0;
                state <= S_WRITE_BYTE;
                write_with_cle <= '1';
                n_state <= S_STATUS;
                substate <= SS_DELAY;
            
            when SS_DELAY =>
                delay <= t_whr;
                state <= S_DELAY;
                substate <= SS_READ;
            
            when SS_READ =>
                stage <= 0;
                state <= S_READ_BYTE;
                substate <= SS_DONE;
                
            when SS_DONE => state <= S_READY;
            when others => state <= S_ERROR; -- error
            end case;
        
        when S_ERASE =>
            case substate is
            when SS_INIT =>
--                o_nand_wp <= '1';
                byte_to_send <= x"60";
                stage <= 0;
                state <= S_WRITE_BYTE;
                write_with_cle <= '1';
                n_state <= S_ERASE;
                substate <= SS_WRITE_ADR;
                byte_counter <= 3;
            
            when SS_WRITE_ADR =>
                if byte_counter > 0 then
                    byte_counter <= byte_counter - 1;
                    byte_to_send <= i_address((ADDR_LENGTH-byte_counter)*8 + 7 downto (ADDR_LENGTH-byte_counter)*8);
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_ale <= '1';
                    substate <= SS_WRITE_ADR;
                else
                    byte_to_send <= x"D0";
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_cle <= '1';
                    substate <= SS_WAIT;
                end if;
            
            when SS_WAIT =>
                delay <= t_wb;
                state <= S_WAIT;
                substate <= SS_DONE;
                
            when SS_DONE => 
                state <= S_READY;
--                o_nand_wp <= '0';
            when others => state <= S_ERROR; -- error
            end case;
        
        when S_PROGRAM =>
            case substate is
            when SS_INIT =>
--                o_nand_wp <= '1';
                byte_to_send <= x"80";
                stage <= 0;
                state <= S_WRITE_BYTE;
                write_with_cle <= '1';
                n_state <= S_PROGRAM;
                substate <= SS_WRITE_ADR;
                byte_counter <= 5;
            
            when SS_WRITE_ADR =>
                if byte_counter > 0 then
                    byte_counter <= byte_counter - 1;
                    byte_to_send <= i_address((ADDR_LENGTH-byte_counter)*8 + 7 downto (ADDR_LENGTH-byte_counter)*8);
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_ale <= '1';
                else
                    delay <= t_adl;
                    state <= S_DELAY;
                    substate <= SS_WRITE;
                    byte_counter <= PAGE_SIZE;
                end if;
            
            when SS_WRITE =>
                if byte_counter > 0 then
                    byte_counter <= byte_counter - 1;
                    byte_to_send <= i_data;
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                else
                    byte_to_send <= x"10";
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_cle <= '1';
                    substate <= SS_WAIT;
                end if;
                
            when SS_WAIT =>
                delay <= t_wb;
                state <= S_WAIT;
                substate <= SS_DONE;
                
            when SS_DONE => 
                state <= S_READY;
--                o_nand_wp <= '0';
            when others => state <= S_ERROR; -- error
            end case;
        
        when S_READ => 
            case substate is
            when SS_INIT =>
                byte_to_send <= x"00";
                stage <= 0;
                state <= S_WRITE_BYTE;
                write_with_cle <= '1';
                n_state <= S_READ;
                substate <= SS_WRITE_ADR;
                byte_counter <= 5;
                
            when SS_WRITE_ADR =>
                if byte_counter > 0 then
                    byte_counter <= byte_counter - 1;
                    byte_to_send <= i_address((ADDR_LENGTH-byte_counter)*8 + 7 downto (ADDR_LENGTH-byte_counter)*8);
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_ale <= '1';
                else
                    byte_to_send <= x"30";
                    stage <= 0;
                    state <= S_WRITE_BYTE;
                    write_with_cle <= '1';
                    substate <= SS_WAIT;
                end if;
                
            when SS_WAIT =>
                delay <= t_wb;
                state <= S_WAIT;
                substate <= SS_DELAY;
            
            when SS_DELAY =>
                delay <= t_rr;
                state <= S_DELAY;
                substate <= SS_READ;
                byte_counter <= PAGE_SIZE;
                o_read_done <= '0';
            
            when SS_READ =>
                if byte_counter > 0 then
                    if i_activate = '1' then
                        o_busy <= '1';
                        stage <= 0;
                        state <= S_READ_BYTE;
                        byte_counter <= byte_counter - 1;
                    else 
                        o_busy <= '0';
                    end if;
                else
                    o_read_done <= '1';
                    substate <= SS_DONE;
                end if;
                
            when SS_DONE => state <= S_READY;
            when others => state <= S_ERROR; -- error
            end case;
        
        -- this state performs a read sequence of a single byte
        when S_READ_BYTE =>
            hold_return_state <= S_READ_BYTE;
            case stage is
            when 0 =>
                o_nand_re <= '0';
                delay <= t_rp;
                state <= S_HOLD;
            when 1 =>
                o_data <= io_nand_data;
                o_nand_re <= '1';
                delay <= t_reh;
                state <= S_HOLD;
            when 2 =>
                state <= n_state;
            when others => state <= S_ERROR; -- error
            end case;
        
        -- this state performs a write sequence of a single byte
        when S_WRITE_BYTE =>
            hold_return_state <= S_WRITE_BYTE;
            case stage is
            when 0 =>
                o_nand_we <= '0';
                if write_with_ale = '1' then
                    o_nand_ale <= '1';
                elsif write_with_cle = '1' then
                    o_nand_cle <= '1';
                end if;
                io_nand_data <= byte_to_send;
                delay <= t_wp;
                state <= S_HOLD;
            when 1 =>
                o_nand_we <= '1';
                delay <= t_wh;
                state <= S_HOLD;
            when 2 =>
                if write_with_ale = '1' then
                    o_nand_ale <= '0';
                    write_with_ale <= '0';
                elsif write_with_cle = '1' then
                    o_nand_cle <= '0';
                    write_with_cle <= '0';
                end if;
                io_nand_data <= (others => 'Z');
                state <= n_state;
            when others => state <= S_ERROR; -- error
            end case;
        
        -- this state is for general delays, without waiting for anything else
        when S_DELAY =>
            if delay > 1 then
                delay <= delay - 1;
            else 
                state <= n_state;
            end if;
        
        -- this state is for delays between stages of S_READ_BYTE and S_WRITE_BYTE
        when S_HOLD =>
            if delay > 1 then
                delay <= delay - 1;
            else 
                state <= hold_return_state;
                stage <= stage + 1;
            end if;
        
        -- this state is for waiting for the r/b signal
        when S_WAIT =>
            if delay > 1 then
                delay <= delay - 1;
            elsif i_nand_rb = '1' then
                state <= n_state;
            end if;
        
        when S_ERROR => null;
        
        when others => state <= S_IDLE;
        end case;
    end if;
    end process;

end Behavioral;
