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
    i_clk   : in     std_logic;

    i_set   : in     std_logic;            -- '1' to o_life <= i_life
    i_life  : in     std_logic;            -- state input (use with i_set)

    i_left  : in     std_logic;            -- state of cell to the left
    i_right : in     std_logic;            -- state of cell to the right

    i_ntop  : in     natural range 0 to 3; -- n living cells on row above
    i_nbot  : in     natural range 0 to 3; -- n living cells on row below

    o_hsum  : out    natural range 0 to 3; -- n living cells on own row
    o_life  : buffer std_logic);
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

library ieee;   -- do you have to repeat this every time?
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
  generic (
    g_width : natural );
  port (
    i_clk : in     std_logic;
    i_set : in     std_logic; -- if set '1' take input from i_val
    i_in  : in     std_logic;
    i_val : in     std_logic_vector(g_width-1 downto 0);
    o_val : buffer std_logic_vector(g_width-1 downto 0) );
end shifter;

architecture rtl of shifter is

  signal w_i_set : std_logic;
  signal w_i_in  : std_logic;
  signal w_i_val : std_logic_vector(g_width-1 downto 0);

  begin

    w_i_set <= i_set;   -- again, im not quite sure what
    w_i_in  <= i_in;    -- this does exactly or how it
    w_i_val <= i_val;   -- works!?

    process (i_clk) is
      begin
        if rising_edge(i_clk) then
          if w_i_set = '0' then
            o_val(0) <= w_i_in;
          else
            o_val(0) <= w_i_val(0);
          end if;
        end if;
    end process;

    SHIFTERBODY : for i in 1 to g_width-1 generate
      process (i_clk) is
        begin
          if rising_edge(i_clk) then
            if w_i_set = '0' then
              o_val(i) <= o_val(i-1);
            else
              o_val(i) <= w_i_val(i);
            end if;
          end if;
      end process;
    end generate SHIFTERBODY;
end rtl;

----------------------------------------------------------------------

-- a column of connected golcells with attached flipflop for shifting
-- in/oud and loading/retrieving a pattern into the playing field
-- the cells are vertically connected so only the left and right
-- connections are open (two per cell)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity golcolumn is
  generic (
    g_height  : natural );
  port (
    i_clk    : in     std_logic;

    i_load   : in     std_logic;     -- '1': flipflops => golcells

    i_move   : in     std_logic;     -- '1' to shift down or flipflops <= golcels
    i_msel   : in     std_logic;     -- '0'/'1' to shift/retrieve if i_move

    i_left   : in     std_logic_vector(g_height-1 downto 0); -- connect to left
    i_right  : in     std_logic_vector(g_height-1 downto 0); -- connect to right

    o_life   : buffer std_logic_vector(g_height-1 downto 0) );

end golcolumn;

architecture rtl of shiftmatrix is
begin
end rtl;

----------------------------------------------------------------------
-- TODO: a stack of interconnected golcolumn's sandwiched between two
--       regular shift registers creating life!
----------------------------------------------------------------------
-- TODO: get some vga out!?
----------------------------------------------------------------------
-- note: each life cycle takes 1 clock cycle but getting the data out
--       will take W x H cycles.
--
-- idea: attach a counter to each cell to sum the amount of life when
--       doing more cycles within one displayed frame
----------------------------------------------------------------------
-- note: this will not scale well with big gol playfields.
--
-- idea: fold the field upon itself 2 times so no need to connect
--       outer edges, each hardware cell should do 4 actual cells then,
--       if you add some memory to the edges you can also reuse the
--       logic and do the computation sequentially in 4 clock cycles.
--       Should work with 16 or 256 clock cycles as well. good luck :P
----------------------------------------------------------------------
