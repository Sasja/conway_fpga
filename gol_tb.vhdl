library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity golcell_tb is
end golcell_tb;

architecture behave of golcell_tb is
  signal r_clk  : std_logic := '0';
  signal r_UL   : std_logic := '0';
  signal r_U    : std_logic := '0';
  signal r_UR   : std_logic := '0';
  signal r_L    : std_logic := '0';
  signal r_R    : std_logic := '0';
  signal r_DL   : std_logic := '0';
  signal r_D    : std_logic := '0';
  signal r_DR   : std_logic := '0';
  signal w_LIFE : std_logic       ;

  -- component declaration for UUT
  component golcell is
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
      o_life : inout std_logic );
  end component golcell;

begin
  
  UUT : golcell
    port map (
      i_clk  => r_CLK,
      i_ul   => r_UL,
      i_u    => r_U,
      i_ur   => r_UR,
      i_l    => r_L,
      i_r    => r_R,
      i_dl   => r_DL,
      i_d    => r_D,
      i_dr   => r_DR,
      o_life => w_LIFE );

  process
    type t_pattern is record
      i_clk  : std_logic;
      i_ul   : std_logic;
      i_u    : std_logic;
      i_ur   : std_logic;
      i_l    : std_logic;
      i_r    : std_logic;
      i_dl   : std_logic;
      i_d    : std_logic;
      i_dr   : std_logic;
      o_life : std_logic;
    end record;

    type t_pattern_array is array (natural range <>) of t_pattern;
    constant patterns : t_pattern_array :=
    (('0','1','1','1','0','0','0','0','0','0'),
     ('1','1','1','1','0','0','0','0','0','1'),
     ('0','1','1','1','1','0','0','0','0','1'),
     ('1','1','1','1','1','0','0','0','0','0'),
     ('0','1','1','1','1','1','0','0','0','0'),
     ('1','0','1','1','0','0','0','0','0','0'),
     ('0','0','1','1','1','0','0','0','0','0'),
     ('1','0','1','1','1','0','0','0','0','1'),
     ('0','0','1','1','1','1','0','0','0','1'),
     ('1','0','1','1','1','0','0','0','0','0'),
     ('0','0','1','1','1','1','0','0','0','0'),
     ('1','1','1','1','1','0','0','0','0','0'),
     ('0','1','1','1','1','1','0','0','0','0'),
     ('1','0','1','1','1','0','0','0','0','0'),
     ('0','0','1','1','1','1','0','0','0','0'),
     ('1','0','1','1','1','1','0','0','0','0'));

  begin
    for i in patterns'range loop
      r_CLK <= patterns(i).i_clk;
      r_UL  <= patterns(i).i_ul;
      r_U   <= patterns(i).i_u;
      r_UR  <= patterns(i).i_ur;
      r_L   <= patterns(i).i_l;
      r_R   <= patterns(i).i_r;
      r_DL  <= patterns(i).i_dl;
      r_D   <= patterns(i).i_d;
      r_DR  <= patterns(i).i_dr;

      wait for 1 ns;

      assert w_LIFE = patterns(i).o_life
        report "bad cell output" severity error;
      
    end loop;

    assert false report "end of test" severity note;
    wait;
    
  end process;

end behave;

--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity golcell2_tb is
end golcell2_tb;

architecture behave of golcell2_tb is
  signal r_clk   : std_logic := '1';
  signal r_left  : std_logic := '0';
  signal r_right : std_logic := '0';
  signal r_ntop  : natural range 0 to 3 := 0;
  signal r_nbot  : natural range 0 to 3 := 0;
  signal w_hsum  : natural range 0 to 3 := 0;
  signal w_life  : std_logic := '0';

  -- component declaration for UUT
  component golcell2 is
    port (
      i_clk   : in    std_logic;
      i_left  : in    std_logic;            -- state of cell to the left
      i_right : in    std_logic;            -- state of cell to the right
      i_ntop  : in    natural range 0 to 3; -- n living cells on row above
      i_nbot  : in    natural range 0 to 3; -- n living cells on row below
      o_hsum  : out   natural range 0 to 3; -- n living cells on own row
      o_life  : inout std_logic );
  end component golcell2;

begin
  UUT : golcell2
    port map (
      i_clk   => r_clk,
      i_left  => r_left,
      i_right => r_right,
      i_ntop  => r_ntop,
      i_nbot  => r_nbot,
      o_hsum  => w_hsum,
      o_life  => w_life );

  process
    type t_pattern is record
      i_clk   : std_logic;
      i_left  : std_logic;
      i_right : std_logic;
      i_ntop  : natural range 0 to 3;
      i_nbot  : natural range 0 to 3;
      o_hsum  : natural range 0 to 3;
      o_life  : std_logic;
    end record;

    type t_pattern_array is array (natural range <>) of t_pattern;
    constant patterns : t_pattern_array :=
    --clk     L   R    out: T B  rsum    life
    (('0',   '0','0',       0,0,  0,     '0'),  -- count when dead
     ('0',   '1','0',       0,0,  1,     '0'),
     ('0',   '0','1',       0,0,  1,     '0'),
     ('0',   '1','1',       0,0,  2,     '0'),

     ('0',   '1','1',       1,0,  2,     '0'),  -- rehydrate! (resurect on 3)
     ('1',   '1','1',       1,0,  3,     '1'),

     ('0',   '0','0',       0,0,  1,     '1'),  -- count when alive
     ('0',   '1','0',       0,0,  2,     '1'),
     ('0',   '0','1',       0,0,  2,     '1'),
     ('0',   '1','1',       0,0,  3,     '1'),

     ('0',   '1','1',       1,0,  3,     '1'),
     ('1',   '1','1',       1,0,  3,     '1'),  -- survive on 3
     ('0',   '0','0',       1,1,  1,     '1'),
     ('1',   '0','0',       1,1,  1,     '1'),  -- survive on 2

     ('0',   '1','1',       1,1,  3,     '1'),
     ('1',   '1','1',       1,1,  2,     '0'),  -- dehydrate! (die on 4)

     ('0',   '0','0',       0,0,  0,     '0'),
     ('1',   '1','1',       1,0,  2,     '0'),  -- dont act on current count
     ('0',   '1','1',       1,0,  2,     '0'),
     ('1',   '0','0',       0,0,  1,     '1'),  -- act on pre-clock count

     ('0',   '0','0',       0,0,  1,     '1'),  -- blah
     ('1',   '0','0',       0,0,  0,     '0'));
    begin

    for i in patterns'range loop
      r_clk   <= patterns(i).i_clk;
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
