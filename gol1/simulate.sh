#!/usr/bin/env bash

# game of live cell
#ghdl -c *.vhdl -r golcell_tb --vcd=golcell_tb.vcd --stop-time=1ms --disp-time

# shifter
ghdl -c *.vhdl -r shifter_tb --vcd=shifter_tb.vcd --stop-time=1ms --disp-time
