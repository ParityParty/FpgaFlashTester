library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- This library is now essential for the type conversion
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 434;
    g_MAX_BYTES    : integer := 7    
    );
  port (
    i_reset        : in  std_logic := '0';
    i_Clk          : in  std_logic;
    i_TX_DV        : in  std_logic;
    i_TX_Data      : in  std_logic_vector(g_MAX_BYTES*8 - 1 downto 0);
    i_TX_Num_Bytes : in  std_logic_vector(2 downto 0);
    o_TX_Active    : out std_logic;
    o_TX_Serial    : out std_logic
    );
end UART_TX;


architecture rtl_tx of UART_TX is

  type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                     s_TX_Stop_Bit, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
  
  type t_Byte_Array is array (0 to g_MAX_BYTES-1) of std_logic_vector(7 downto 0);
  
  signal r_Clk_Count     : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index     : integer range 0 to 7 := 0;
  signal r_Byte_Index    : integer range 0 to g_MAX_BYTES-1 := 0;
  
  -- MODIFICATION: Changed range to start from 0 to match the std_logic_vector's possible values.
  signal r_Num_Bytes_Reg : integer range 0 to g_MAX_BYTES := 1; 

  signal r_TX_Data_Buf   : t_Byte_Array;
  signal r_TX_Data_Reg   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_Active     : std_logic := '0';
 
begin

  p_Input_Parser: process(i_TX_Data)
  begin
    for i in 0 to g_MAX_BYTES-1 loop
      r_TX_Data_Buf(i) <= i_TX_Data((i*8)+7 downto i*8);
    end loop;
  end process p_Input_Parser;

  
  p_UART_TX : process (i_Clk, i_reset)
  begin
    if i_reset = '0' then
      r_SM_Main       <= s_Idle;
      r_Clk_Count     <= 0;
      r_Bit_Index     <= 0;
      r_Byte_Index    <= 0;
      r_Num_Bytes_Reg <= 1;
      r_TX_Data_Reg   <= (others => '0');
      r_TX_Active     <= '0';
      o_TX_Serial     <= '1';
   
    elsif rising_edge(i_Clk) then
      
      case r_SM_Main is

        when s_Idle =>
          r_TX_Active <= '0';
          o_TX_Serial <= '1';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
          r_Byte_Index<= 0;

          if i_TX_DV = '1' then
            r_TX_Active     <= '1';
            -- MODIFICATION: Convert the std_logic_vector input to an integer before use.
            r_Num_Bytes_Reg <= to_integer(unsigned(i_TX_Num_Bytes));
            r_TX_Data_Reg   <= r_TX_Data_Buf(0);
            r_SM_Main       <= s_TX_Start_Bit;
          end if;

        when s_TX_Start_Bit =>
          r_TX_Active <= '1';
          o_TX_Serial <= '0';

          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
          else
            r_Clk_Count <= 0;
            r_SM_Main   <= s_TX_Data_Bits;
          end if;

        when s_TX_Data_Bits =>
          r_TX_Active <= '1';
          o_TX_Serial <= r_TX_Data_Reg(r_Bit_Index);
          
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
          else
            r_Clk_Count <= 0;
            
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_TX_Stop_Bit;
            end if;
          end if;

        when s_TX_Stop_Bit =>
          r_TX_Active <= '1';
          o_TX_Serial <= '1';

          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
          else
            r_Clk_Count <= 0;
            
            -- This logic now compares against the converted integer value
            if r_Byte_Index < r_Num_Bytes_Reg - 1 then
              r_Byte_Index  <= r_Byte_Index + 1;
              r_TX_Data_Reg <= r_TX_Data_Buf(r_Byte_Index + 1);
              r_SM_Main     <= s_TX_Start_Bit;
            else
              r_SM_Main <= s_Cleanup;
            end if;
          end if;
        
        when s_Cleanup =>
          r_TX_Active <= '0';
          r_SM_Main   <= s_Idle;

        when others =>
          r_SM_Main <= s_Idle;

      end case;
    end if;
  end process p_UART_TX;

  o_TX_Active <= r_TX_Active;
  
end rtl_tx;