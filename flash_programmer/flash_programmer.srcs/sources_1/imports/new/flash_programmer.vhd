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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TX is
  generic (
    g_CLKS_PER_BIT : integer := 2604     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end UART_TX;
 
 
architecture rtl_tx of UART_TX is
 
  type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                     s_TX_Stop_Bit, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
 
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_Done   : std_logic := '0';
   
begin
 
   
  p_UART_TX : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case r_SM_Main is
 
        when s_Idle =>
          o_TX_Active <= '0';
          o_TX_Serial <= '1';         -- Drive Line High for Idle
          r_TX_Done   <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if i_TX_DV = '1' then
            r_TX_Data <= i_TX_Byte;
            r_SM_Main <= s_TX_Start_Bit;
            o_TX_Active <= '1';
          else
            r_SM_Main <= s_Idle;
          end if;
 
        -- Send out Start Bit. Start bit = 0
        when s_TX_Start_Bit =>
          o_TX_Active <= '1';
          o_TX_Serial <= '0';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Start_Bit;
          else
            r_Clk_Count <= 0;
            r_SM_Main   <= s_TX_Data_Bits;
          end if;
 
        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish
        when s_TX_Data_Bits =>
          o_TX_Serial <= r_TX_Data(r_Bit_Index);
           
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Data_Bits;
          else
            r_Clk_Count <= 0;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              r_SM_Main   <= s_TX_Data_Bits;
            else
              r_Bit_Index <= 0;
              r_SM_Main   <= s_TX_Stop_Bit;
            end if;
          end if;
 
        -- Send out Stop bit. Stop bit = 1 
        when s_TX_Stop_Bit =>
          o_TX_Serial <= '1';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            r_SM_Main   <= s_TX_Stop_Bit;
          else
            r_TX_Done   <= '1';
            r_Clk_Count <= 0;
            r_SM_Main   <= s_Cleanup;
          end if;
         
        -- Stay here 1 clock 
        when s_Cleanup =>
          o_TX_Active <= '0';
          r_TX_Done   <= '1';
          r_SM_Main   <= s_Idle;
 
        when others =>
          r_SM_Main <= s_Idle;
 
      end case;
    end if;
  end process p_UART_TX;
 
  o_TX_Done <= r_TX_Done;
   
end rtl_tx;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flash_programmer is
    Generic (
        MAX_COUNT : integer := 25000000;
        DELAY_MAX_COUNT : integer := 25000000
    );
    Port (
    led_light : out STD_LOGIC;
    CLK25MHZ  : in  STD_LOGIC;
    uart_tx : out STD_LOGIC;
    clk_monitor : out std_logic;
    
    nand_cle				: out	std_logic := '0';
    nand_ale				: out	std_logic := '0';
    nand_nwe				: out	std_logic := '1';
    nand_nwp				: out	std_logic := '0';
    nand_nce				: out	std_logic := '1';
    nand_nre				: out std_logic := '1';
    nand_rnb				: in	std_logic;
    -- NAND chip data hardware interface. These signals should be boiund to physical pins.
    nand_data			: inout	std_logic_vector(15 downto 0)
    );
end flash_programmer;

architecture Behavioral of flash_programmer is
     signal counter : integer := 0;
     signal led_state : std_logic := '0';
     
 signal i_TX_DV : std_logic := '0';         -- Data Valid for Transmission
    signal i_TX_Byte : std_logic_vector(7 downto 0) := (others => '0');  -- Byte to transmit
    signal o_TX_Active : std_logic := '0';
    signal o_TX_Serial : std_logic := '1';
    signal o_TX_Done : std_logic := '0';
    
    component nand_master
		port
		(
			-- System clock
			clk					: in	std_logic;
			enable : in std_logic;
			-- NAND chip control hardware interface. These signals should be bound to physical pins.
			nand_cle				: out	std_logic := '0';
			nand_ale				: out	std_logic := '0';
			nand_nwe				: out	std_logic := '1';
			nand_nwp				: out	std_logic := '0';
			nand_nce				: out	std_logic := '1';
			nand_nre				: out std_logic := '1';
			nand_rnb				: in	std_logic;
			-- NAND chip data hardware interface. These signals should be boiund to physical pins.
			nand_data			: inout	std_logic_vector(15 downto 0);
			
			-- Component interface
			nreset				: in	std_logic := '1';
			data_out				: out	std_logic_vector(7 downto 0);
			data_in				: in	std_logic_vector(7 downto 0);
			busy					: out	std_logic := '0';
			activate				: in	std_logic := '0';
			cmd_in				: in	std_logic_vector(7 downto 0)
		);
	end component;
	
	signal nreset   : std_logic := '1';
	signal data_out : std_logic_vector(7 downto 0);
	signal data_in  : std_logic_vector(7 downto 0);
	signal busy     : std_logic;
	signal activate : std_logic;
	signal cmd_in   : std_logic_vector(7 downto 0);
	
	type STATE_TYPE is (INIT, ENABLE_ARM, ENABLE_RELEASE, READ_ARM, READ_RELEASE, DELAY);
	signal state : STATE_TYPE := INIT;
	signal delay_counter : integer := 0;
begin
    uart_tx_inst : entity work.UART_TX
        port map (
            i_Clk       => CLK25MHZ,
            i_TX_DV     => i_TX_DV,
            i_TX_Byte   => i_TX_Byte,
            o_TX_Active => o_TX_Active,
            o_TX_Serial => uart_tx,  -- Connect the transmit line
            o_TX_Done   => o_TX_Done
        );
        
    NM:nand_master
	port map
	(
		clk => CLK25MHZ,
		enable => '0',
		nand_cle => nand_cle,
		nand_ale => nand_ale,
		nand_nwe => nand_nwe,
		nand_nwp => nand_nwp,
		nand_nce => nand_nce,
		nand_nre => nand_nre,
		nand_rnb => nand_rnb,
		nand_data=> nand_data,
		nreset   => nreset,
		data_out => data_out,
		data_in  => data_in,
		busy     => busy,
		activate => activate,
		cmd_in   => cmd_in
	);
        
    process(CLK25MHZ)
    begin
    clk_monitor <= CLK25MHZ;
    if CLK25MHZ'event and CLK25MHZ = '1' then
    
        if i_TX_DV = '1' then
            i_TX_DV <= '0';
        end if;
        
        if counter = MAX_COUNT then
            counter <= 1;
            led_light <= led_state;
            led_state <= not led_state;
            
            if o_TX_Active = '0' and i_TX_DV = '0' then
                i_TX_Byte <= std_logic_vector(to_unsigned(71, 8));
                i_TX_DV <= '1';
            end if;
        else 
            counter <= counter + 1;
        end if;
        
        if activate = '1' then
            activate <= '0';
        else
            case state is
            when INIT =>
                nreset <= '1';
                nand_data <= "ZZZZZZZZZZZZZZZZ";
                state <= ENABLE_ARM;
                
            when ENABLE_ARM =>
                cmd_in <= x"09";
                state <= ENABLE_RELEASE;
                
            when ENABLE_RELEASE =>
                activate <= '1';
                state <= READ_ARM;
                
            when READ_ARM =>
                data_in <= x"00";
		        cmd_in <= x"03";
		        state <= READ_RELEASE;
            
            when READ_RELEASE =>
                activate <= '1';
                state <= DELAY;
                
            when DELAY =>
                if delay_counter = DELAY_MAX_COUNT then
                    delay_counter <= 0;
                    state <= READ_ARM;
                else 
                    delay_counter <= delay_counter + 1;
                end if;
                
--            when others => null;
            end case;
        end if;
    end if;
    end process;

end Behavioral;
