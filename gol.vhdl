-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

-- first attempt at a game of life cell implementation
-- left here only to discuss

-- entity golcell is
--   port (
--     i_clk  : in    std_logic;
--     i_ul   : in    std_logic;
--     i_u    : in    std_logic;
--     i_ur   : in    std_logic;
--     i_l    : in    std_logic;
--     i_r    : in    std_logic;
--     i_dl   : in    std_logic;
--     i_d    : in    std_logic;
--     i_dr   : in    std_logic;
--     o_life : inout std_logic := '0' );
-- end golcell;
--
-- architecture rtl of golcell is
--
--   signal nneighb : natural range 0 to 9;
--
--   begin
--
--     process (i_clk) is
--       begin
--         if rising_edge(i_clk) then
--           if o_life = '1' and not (nneighb = 2 or nneighb = 3) then
--             o_life <= '0';
--           elsif o_life = '0' and nneighb = 3 then
--             o_life <= '1';
--           end if;
--
--         end if;
--     end process;
--
--     process (i_ul, i_u, i_ur, i_l, i_r, i_dl, i_d, i_dr) is
--       variable count : natural range 0 to 9;
--       begin
--         count := 0;
--         if i_ul = '1' then count := count + 1; end if;
--         if i_u  = '1' then count := count + 1; end if;
--         if i_ur = '1' then count := count + 1; end if;
--         if i_l  = '1' then count := count + 1; end if;
--         if i_r  = '1' then count := count + 1; end if;
--         if i_dl = '1' then count := count + 1; end if;
--         if i_d  = '1' then count := count + 1; end if;
--         if i_dr = '1' then count := count + 1; end if;
--
--         nneighb <= count;
--     end process;
--
-- end rtl;

----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- second approach to a game of life cell
--   Attempt to reuse some counting logic between cells.
--   Now each cell only needs to communicate with 4 neighbours
--   instead of all 8.
--   Also add a way to externally set life value.
entity golcell is
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
end golcell;

architecture rtl of golcell is

  signal w_nneighb : natural range 0 to 8;

  signal w_i_set     : std_logic; -- question see below
  signal w_i_life    : std_logic;

  begin

    -- question?? this seems required to look at value before clk change
    -- instead of after. What is the deal? What does it do exactly
    w_i_set  <= i_set;  
    w_i_life <= i_life;

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
        w_nneighb <= cnt;
    end process;

    -- to be or not to be (on the rising edge)
    process (i_clk) is
      begin
        if rising_edge(i_clk) then
          if w_i_set = '0' then   -- follow gol rules if '0'
            if (w_nneighb = 3) or (w_nneighb = 2 and o_life = '1') then
              o_life <= '1';
            else
              o_life <= '0';
            end if;
          else                  -- or just store i_life if '1'
            o_life <= w_i_life;
          end if;
        end if;
    end process;

end rtl;

----------------------------------------------------------------------

-- a shift register required to clock in/out the state of the gol board

library ieee;   -- do you have to repeat this always?
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
  generic (
    g_width : natural );
  port (
    i_clk : in    std_logic;
    i_set : in    std_logic; -- if set '1' take input from i_val
    i_in  : in    std_logic;
    i_val : in    std_logic_vector(g_width-1 downto 0);
    o_val : inout std_logic_vector(g_width-1 downto 0) );
end shifter;

architecture rtl of shifter is
  begin

    process (i_clk) is
      begin
        if i_set = '0' then
          if rising_edge(i_clk) then
            o_val(0) <= i_in;
          end if;
        else
          o_val(0) <= i_val(0);
        end if;
    end process;

    SHIFTERBODY : for i in 1 to g_width-1 generate
      process (i_clk) is
        begin
          if i_set = '0' then
            if rising_edge(i_clk) then
              o_val(i) <= o_val(i-1);
            end if;
          else
            o_val(i) <= i_val(i);
          end if;
      end process;
    end generate SHIFTERBODY;
end rtl;

----------------------------------------------------------------------

-- a shift matrix(?) built from shift registers to get the gol pattern
-- in and out of the playingfield

-- library ieee;   -- do you have to repeat this always?
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- 
-- entity shiftmatrix is
--   generic (
--     g_columns : natural,
--     g_height  : natural );
--   port (
--     i_clk : in    std_logic;
--     i_
-- 
-- end shiftmatrix;
-- 
-- architecture rtl of shiftmatrix is
-- end rtl;
