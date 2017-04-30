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
