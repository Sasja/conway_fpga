library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity golcell_tb is
end golcell_tb;

architecture behave of golcell_tb is
  signal r_clk   : std_logic;
  signal r_set   : std_logic;
  signal r_life  : std_logic;
  signal r_left  : std_logic;
  signal r_right : std_logic;
  signal r_ntop  : natural range 0 to 3;
  signal r_nbot  : natural range 0 to 3;
  signal w_hsum  : natural range 0 to 3;
  signal w_life  : std_logic;

  -- component declaration for UUT
  component golcell is
    port (
      i_clk   : in    std_logic;
      i_set   : in    std_logic;            -- '1' to o_life <= i_life on rising clock
      i_life  : in    std_logic;            -- state input (use with i_set)
      i_left  : in    std_logic;            -- state of cell to the left
      i_right : in    std_logic;            -- state of cell to the right
      i_ntop  : in    natural range 0 to 3; -- n living cells on row above
      i_nbot  : in    natural range 0 to 3; -- n living cells on row below
      o_hsum  : out   natural range 0 to 3; -- n living cells on own row
      o_life  : inout std_logic );
  end component golcell;

begin
  UUT : golcell
    port map (
      i_clk   => r_clk,
      i_set   => r_set,
      i_life  => r_life,
      i_left  => r_left,
      i_right => r_right,
      i_ntop  => r_ntop,
      i_nbot  => r_nbot,
      o_hsum  => w_hsum,
      o_life  => w_life );

  process
    type t_pattern is record
      i_clk   : std_logic;
      i_set   : std_logic;
      i_life  : std_logic;
      i_left  : std_logic;
      i_right : std_logic;
      i_ntop  : natural range 0 to 3;
      i_nbot  : natural range 0 to 3;
      o_hsum  : natural range 0 to 3;
      o_life  : std_logic;
    end record;

    type t_pattern_array is array (natural range <>) of t_pattern;
    constant patterns : t_pattern_array :=
    --clk  set i_life   L   R    out: T B  rsum   o_life
    (('0', '0' ,'0',   '0','0',       0,0,  0,     'U'),  -- initial status

     ('0', '1' ,'0',   '0','0',       0,0,  0,     'U'),  -- prepare
     ('1', '0' ,'0',   '0','0',       0,0,  0,     '0'),  -- set life '0'

     ('0', '0' ,'0',   '0','0',       0,0,  0,     '0'),  -- test counter when '0'
     ('0', '0' ,'0',   '1','0',       0,0,  1,     '0'),
     ('0', '0' ,'0',   '0','1',       0,0,  1,     '0'),
     ('0', '0' ,'0',   '1','1',       0,0,  2,     '0'),

     ('0', '1' ,'1',   '0','0',       0,0,  0,     '0'),    -- prepare
     ('1', '0' ,'0',   '0','0',       0,0,  1,     '1'),  -- set life '1'

     ('0', '0' ,'0',   '0','0',       0,0,  1,     '1'),  -- count when alive
     ('0', '0' ,'0',   '1','0',       0,0,  2,     '1'),
     ('0', '0' ,'0',   '0','1',       0,0,  2,     '1'),
     ('0', '0' ,'0',   '1','1',       0,0,  3,     '1'),

     ('0', '0' ,'0',   '1','1',       1,0,  3,     '1'),  -- prepare 3
     ('1', '0' ,'0',   '0','0',       0,0,  1,     '1'),  -- survive on 3
     ('0', '0' ,'0',   '0','0',       1,1,  1,     '1'),  -- prepare 2
     ('1', '0' ,'0',   '0','0',       0,0,  1,     '1'),  -- survive on 2
     ('0', '0' ,'0',   '1','1',       1,1,  3,     '1'),  -- prepare 4
     ('1', '0' ,'0',   '0','0',       0,0,  0,     '0'),  -- dehydrate! (die on 4)

     ('0', '0' ,'0',   '0','0',       0,0,  0,     '0'),  -- prepare 0
     ('1', '0' ,'0',   '1','1',       1,0,  2,     '0'),  -- dont act on current count (n=3)
     ('0', '0' ,'0',   '1','1',       1,0,  2,     '0'),  -- prepare 3
     ('1', '0' ,'0',   '0','0',       0,0,  1,     '1')); -- act on pre-clock count

    begin

    for i in patterns'range loop
      r_clk   <= patterns(i).i_clk;
      r_set   <= patterns(i).i_set;
      r_life  <= patterns(i).i_life;
      r_left  <= patterns(i).i_left;
      r_right <= patterns(i).i_right;
      r_ntop  <= patterns(i).i_ntop;
      r_nbot  <= patterns(i).i_nbot;

      wait for 1 ns;

      assert w_hsum = patterns(i).o_hsum
        report "bad row sum output" severity error;
      assert w_life = patterns(i).o_life
        report "bad life status output" severity error;

    end loop;

    assert false report "end of test" severity note;
    wait;

  end process;
end behave;

--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter_tb is
end shifter_tb;


architecture behave of shifter_tb is

  constant c_width : natural := 8;

  signal r_clk : std_logic;
  signal r_set : std_logic;
  signal r_in  : std_logic;
  signal r_val : std_logic_vector(c_width-1 downto 0);
  signal w_val : std_logic_vector(c_width-1 downto 0);

  component shifter is
    generic (
      g_width : natural );
    port (
      i_clk : in    std_logic;
      i_set : in    std_logic; -- if set '1' take input from i_val
      i_in  : in    std_logic;
      i_val : in    std_logic_vector(g_width-1 downto 0);
      o_val : inout std_logic_vector(g_width-1 downto 0) );
  end component shifter;

  begin
    UUT : shifter
      generic map (
        g_width => c_width )
      port map (
        i_clk => r_clk,
        i_set => r_set,
        i_in  => r_in,
        i_val => r_val,
        o_val => w_val );

  -- start tests
  process is
    type t_pattern is record
      i_clk : std_logic;
      i_set : std_logic;
      i_in  : std_logic;
      i_val : std_logic_vector(c_width-1 downto 0);
      o_val : std_logic_vector(c_width-1 downto 0);
    end record;

    type t_pattern_array is array (natural range <>) of t_pattern;
    constant patterns : t_pattern_array :=
    -- clk  set  in    i_val       o_val
    (( '0', '0', '0',"00000000", "UUUUUUUU" ),  -- shifting 0's
     ( '1', '0', '0',"00000000", "UUUUUUU0" ),
     ( '0', '0', '0',"00000000", "UUUUUUU0" ),
     ( '1', '0', '0',"00000000", "UUUUUU00" ),
     ( '0', '0', '0',"00000000", "UUUUUU00" ),
     ( '1', '0', '0',"00000000", "UUUUU000" ),
     ( '0', '0', '0',"00000000", "UUUUU000" ),
     ( '1', '0', '0',"00000000", "UUUU0000" ),
     ( '0', '0', '0',"00000000", "UUUU0000" ),
     ( '1', '0', '0',"00000000", "UUU00000" ),
     ( '0', '0', '0',"00000000", "UUU00000" ),
     ( '1', '0', '0',"00000000", "UU000000" ),
     ( '0', '0', '1',"00000000", "UU000000" ),  -- add some 1's
     ( '1', '0', '1',"00000000", "U0000001" ),
     ( '0', '0', '1',"00000000", "U0000001" ),
     ( '1', '0', '1',"00000000", "00000011" ),
     ( '0', '0', '1',"00000000", "00000011" ),
     ( '1', '0', '1',"00000000", "00000111" ),
     ( '0', '0', '1',"00000000", "00000111" ),
     ( '1', '0', '0',"00000000", "00001111" ), -- 'in' after clock ignored

     ( '0', '1', '0',"10111000", "00001111" ), -- prepare 'set' bits
     ( '1', '0', '0',"00000000", "10111000" ), -- set

     ( '0', '0', '0',"00000000", "10111000" ),
     ( '1', '0', '0',"00000000", "01110000" ),  -- shift away
     ( '0', '0', '0',"00000000", "01110000" ),
     ( '1', '0', '0',"00000000", "11100000" ),
     ( '0', '0', '0',"00000000", "11100000" ),
     ( '1', '0', '0',"00000000", "11000000" ));
  begin
    for i in patterns'range loop
      r_clk <= patterns(i).i_clk;
      r_set <= patterns(i).i_set;
      r_in  <= patterns(i).i_in;
      r_val <= patterns(i).i_val;
      wait for 1 ns;
      assert w_val = patterns(i).o_val
        report "wrong shifter value" severity error;
    end loop;

    assert false report "end of test" severity note;
    wait;

  end process;

end architecture;
