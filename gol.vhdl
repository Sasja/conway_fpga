library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity golcell is
  port (
    i_clk  : in    std_logic;
    i_ul   : in    std_logic;
    i_u    : in    std_logic;
    i_ur   : in    std_logic;
    i_l    : in    std_logic;
    i_r    : in    std_logic;
    i_dl   : in    std_logic;
    i_d    : in    std_logic;
    i_dr   : in    std_logic;
    o_life : inout std_logic := '0' );
end golcell;

architecture rtl of golcell is

  signal nneighb : natural range 0 to 9;

  begin

    process (i_clk) is
      begin
        if rising_edge(i_clk) then
          if o_life = '1' and not (nneighb = 2 or nneighb = 3) then
            o_life <= '0';
          elsif o_life = '0' and nneighb = 3 then
            o_life <= '1';
          end if;

        end if;
    end process;

    process (i_ul, i_u, i_ur, i_l, i_r, i_dl, i_d, i_dr) is
      variable count : natural range 0 to 9;
      begin
        count := 0;
        if i_ul = '1' then count := count + 1; end if;
        if i_u  = '1' then count := count + 1; end if;
        if i_ur = '1' then count := count + 1; end if;
        if i_l  = '1' then count := count + 1; end if;
        if i_r  = '1' then count := count + 1; end if;
        if i_dl = '1' then count := count + 1; end if;
        if i_d  = '1' then count := count + 1; end if;
        if i_dr = '1' then count := count + 1; end if;

        nneighb <= count;
    end process;

end rtl;
