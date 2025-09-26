library ieee;
use ieee.std_logic_1164.all;

package onfi_timings is
    constant clock_cycle	: real := 10.0; -- ns

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
end onfi_timings;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.onfi_timings.all;

entity nand_controller is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_activate : in std_logic;
           i_cmd : in std_logic_vector(7 downto 0);
           i_address : in std_logic_vector(39 downto 0);
           io_data : inout std_logic_vector(7 downto 0) := (others => '0');
           o_busy : out std_logic := '0';
           o_read_done : out std_logic := '0';
           
           i_nand_rb : in std_logic;
           o_nand_we : out std_logic := '1';
           o_nand_wp : out std_logic := '0';
           o_nand_cle : out std_logic := '0';
           o_nand_ale : out std_logic := '0';
           o_nand_re : out std_logic := '1';
           io_nand_data : inout std_logic_vector(7 downto 0) := (others => 'Z')
           );
end nand_controller;

architecture Behavioral of nand_controller is
    type state_t is (S_IDLE, S_READY, S_RESET, S_ERASE, S_STATUS, S_PROGRAM, S_READ, S_READ_BYTE, S_SEND_CMD, S_SEND_ADR, S_HOLD, S_DELAY, S_WAIT);
    signal state : state_t;
    signal n_state : state_t;
    signal hold_return_state : state_t;
    
    type substate_t is (SS_INIT, SS_WAIT, SS_DELAY, SS_READ, SS_WRITE, SS_DONE);
    signal substate : substate_t;
    
    signal delay : integer := 0;
    signal byte_to_send : std_logic_vector(7 downto 0) := (others => '0');
    signal stage : integer := 0;
    signal byte_counter : integer := 0;
begin
    o_busy <= '0' when state = S_READY else '1';

    process(i_clk, i_rst)
    begin
    if i_rst = '0' then
        state <= S_IDLE;
    
    elsif rising_edge(i_clk) then
        case state is
        when S_IDLE =>
            io_data <= (others => '0');
            o_read_done <= '0';
            
            o_nand_we <= '1';
            o_nand_wp <= '0';
            o_nand_cle <= '0';
            o_nand_ale <= '0';
            o_nand_re <= '1';
            io_nand_data <= (others => 'Z');
            
            state <= S_READY;
            n_state <= S_READY;
        
        when S_READY =>
            if i_activate = '1' then
                substate <= SS_INIT;
                case i_cmd is
                when x"01" => state <= S_RESET;
                when x"02" => state <= S_STATUS;
--                when x"03" => state <= S_ERASE;
                when others => state <= S_IDLE; -- error
                end case;
            end if;
            
        when S_RESET =>
            case substate is
            when SS_INIT =>
                byte_to_send <= x"FF";
                stage <= 0;
                state <= S_SEND_CMD;
                n_state <= S_RESET;
                substate <= SS_WAIT;
                
            when SS_WAIT =>
                delay <= t_wb;
                state <= S_WAIT;
                n_state <= S_RESET;
                substate <= SS_DONE;
                
            when SS_DONE => state <= S_READY;
            when others => state <= S_IDLE; -- error
            end case;
        
        when S_STATUS =>
            case substate is
            when SS_INIT =>
                byte_to_send <= x"70";
                stage <= 0;
                state <= S_SEND_CMD;
                n_state <= S_STATUS;
                substate <= SS_DELAY;
            
            when SS_DELAY =>
                delay <= t_whr;
                state <= S_DELAY;
                n_state <= S_STATUS;
                substate <= SS_READ;
            
            when SS_READ =>
                stage <= 0;
                state <= S_READ_BYTE;
                n_state <= S_STATUS;
                substate <= SS_DONE;
                
            when SS_DONE => state <= S_READY;
            when others => state <= S_IDLE; -- error
            end case;
        
--        when S_ERASE =>
--            case substate is
--            when SS_INIT =>
--                byte_to_send <= x"60";
--                stage <= 0;
--                state <= S_SEND_CMD;
--                n_state <= S_ERASE;
--                substate <= SS_WRITE;
--                byte_counter <= 0;
            
--            when SS_WRITE =>
--                delay <= t_whr;
--                state <= S_DELAY;
--                n_state <= S_STATUS;
--                substate <= SS_READ;
            
--            when SS_READ =>
--                stage <= 0;
--                state <= S_READ_BYTE;
--                n_state <= S_STATUS;
--                substate <= SS_DONE;
                
--            when SS_DONE => state <= S_READY;
--            when others => state <= S_IDLE; -- error
--            end case;
            
        
        -- this state performs a read sequence for a single byte
        when S_READ_BYTE =>
            hold_return_state <= S_READ_BYTE;
            case stage is
            when 0 =>
                o_nand_re <= '0';
                delay <= t_rp;
                state <= S_HOLD;
            when 1 =>
                o_nand_re <= '1';
                io_data <= io_nand_data;
                state <= n_state;
            when others => state <= S_IDLE; -- error
            end case;
        
        -- this state performs a single command sequence
        when S_SEND_CMD =>
            hold_return_state <= S_SEND_CMD;
            case stage is
            when 0 =>
                o_nand_we <= '0';
                o_nand_cle <= '1';
                io_nand_data <= byte_to_send;
                delay <= t_wp;
                state <= S_HOLD;
            when 1 =>
                o_nand_we <= '1';
                delay <= t_clh;
                state <= S_HOLD;
            when 2 =>
                o_nand_cle <= '0';
                io_nand_data <= (others => 'Z');
                state <= n_state;
            when others => state <= S_IDLE; -- error
            end case;
        
        -- this state is for general delays, without waiting for anything else
        when S_DELAY =>
            if delay > 1 then
                delay <= delay - 1;
            else 
                state <= n_state;
            end if;
        
        -- this state is for delays between stages of S_SEND_CMD, S_READ_BYTE, etc.
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
        
        when others => state <= S_IDLE;
        end case;
    end if;
    end process;

end Behavioral;
