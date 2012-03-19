----------------------------------------------------------------------------------
--
-- Create Date:		08:55:38 03/12/2012
-- Module Name:		hsync - Behavioral
-- Project Name:		
-- Target Devices: 	Xilinx Spartan 3e
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity hsync is
    Generic
    (
        -- values for 50MHz clock and 60Hz refresh rate
        
        hcount_width    : integer := 11;
        column_width    : integer := 10;
        front_porch     : integer := 96;
        back_porch        : integer := 32;
        display_time    : integer := 1280;
        scan_time        : integer := 1600;
        pulse_width        : integer := 192
        
    );

    Port
    (
        clk_i            : in    STD_LOGIC;
        rst_i            : in    STD_LOGIC;
        hsync_o        : out    STD_LOGIC;
        dataon_o        : out    STD_LOGIC;
        rowclk_o        : out    STD_LOGIC;
        column_o        : out    STD_LOGIC_VECTOR (column_width-1 downto 0)
    );
end hsync;

architecture Behavioral of hsync is
    signal hcount    : STD_LOGIC_VECTOR (hcount_width-1 downto 0);
    signal column    : STD_LOGIC_VECTOR (column_width-1 downto 0);
    signal hsync    : STD_LOGIC;
    signal dataon    : STD_LOGIC;
    signal rowclk    : STD_LOGIC;
begin

    -- I/O assigments
    
    hsync_o        <= hsync;
    dataon_o        <= dataon;
    column_o        <= column;
    rowclk_o        <= rowclk;
    
    -- Processes
    
    -- Counter --------------------------------------
        hsync_cnt : process (clk_i)
        begin
            if (clk_i'event and clk_i = '1') then
                if rst_i = '1' then
                    hcount <= (others => '0');
                elsif (hcount = scan_time - 1) then
                    hcount <= (others => '0');
                else
                    hcount <= hcount + 1;
                end if;
            end if;
        end process;
        
    -- HSync ----------------------------------------
        p_hsync : process (clk_i)
        begin
            if (clk_i'event and clk_i = '1') then
                if rst_i = '1' then
                    hsync <= '1';
                elsif (hcount = display_time + back_porch - 1) then
                    hsync <= '0';
                elsif ( hcount = display_time + back_porch + pulse_width - 1) then
                    hsync <= '1';
                else
                    hsync <= hsync;
                end if;
            end if;
        end process;
    
    -- DataOn ---------------------------------------
        p_dataon : process (clk_i)
        begin
            if (clk_i'event and clk_i = '1') then
                if rst_i = '1' then
                    dataon <= '1';
                elsif (hcount = display_time - 1) then
                    dataon <= '0';
                elsif (hcount = display_time + back_porch + pulse_width + front_porch - 1) then
                    dataon <= '1';
                else
                    dataon <= dataon;
                end if;
            end if;
        end process;
        
    -- Column
    column <= hcount(hcount_width - 1 downto 1);
    
    -- Row Clock ------------------------------------
        p_rowclk : process (clk_i)
        begin
            if (clk_i'event and clk_i = '1') then
                if (hcount = display_time + back_porch + pulse_width + front_porch - 1) then
                    rowclk <= '1';
                else
                    rowclk <= '0';
                end if;
            end if;
        end process;
    
    -- Instantiation
    
    

end Behavioral;

