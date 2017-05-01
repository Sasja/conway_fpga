#!/usr/bin/env bash

# 1st (naive?) implementation of game of life cell
#ghdl -c *.vhdl -r golcell_tb --vcd=golcell_tb.vcd --stop-time=1ms --disp-time

# 2nd implementation
ghdl -c *.vhdl -r golcell2_tb --vcd=golcell2_tb.vcd --stop-time=1ms --disp-time

# stiching cells together (wip)
#ghdl -c *.vhdl -r gol_tb --vcd=gol_tb.vcd --stop-time=1ms --disp-time
