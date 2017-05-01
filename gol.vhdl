library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- first attempt at a game of life cell implementation
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

----------------------------------------------------------------------

library ieee; -- you have to repeat this for every entity??
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- second approach to a game of life cell
--   Attempt to reuse some counting logic between cells.
--   Now each cell only needs to communicate with 4 neighbours
--   instead of all 8.
--   Also add a way to externally set life value.
entity golcell2 is
  port (
    i_clk   : in    std_logic;

    i_set   : in    std_logic;            -- '1' to o_life <= i_life
    i_life  : in    std_logic;            -- state input (use with i_set)

    i_left  : in    std_logic;            -- state of cell to the left
    i_right : in    std_logic;            -- state of cell to the right

    i_ntop  : in    natural range 0 to 3; -- n living cells on row above
    i_nbot  : in    natural range 0 to 3; -- n living cells on row below

    o_hsum  : out   natural range 0 to 3; -- n living cells on own row
    o_life  : inout std_logic);
end golcell2;

architecture rtl of golcell2 is
  signal nneighb : natural range 0 to 8;

  begin

    -- count the amount of living cells on own row
    process (i_left, i_right, o_life) is
      variable cnt : natural range 0 to 3;
      begin
        cnt := 0;
        if i_left  = '1' then cnt := cnt + 1; end if;
        if i_right = '1' then cnt := cnt + 1; end if;
        if o_life  = '1' then cnt := cnt + 1; end if;
        o_hsum <= cnt;
    end process;

    -- count the amount of living cells around this cell
    process (i_left, i_right, i_ntop, i_nbot) is
      variable cnt : natural range 0 to 8;
      begin
        cnt := i_ntop + i_nbot;
        if i_left  = '1' then cnt := cnt + 1; end if;
        if i_right = '1' then cnt := cnt + 1; end if;
        nneighb <= cnt;
    end process;

    -- to be or not to be on the rising edge
    process (i_clk, i_set, i_life) is
      begin
        if i_set = '0' then   -- folow gol rules on clock
          if rising_edge(i_clk) then
            if (nneighb = 3) or (nneighb = 2 and o_life = '1') then
              o_life <= '1';
            else
              o_life <= '0';
            end if;
          end if;
        else                  -- just follow i_life anytime
          o_life <= i_life;
        end if;
    end process;

end rtl;

----------------------------------------------------------------------

-- library ieee; -- you have to repeat this for every entity??
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- 
-- -- see if we can hook some golcell2's up to each other
-- entity gol is
--   port (
--     i_clk   : in    std_logic;
