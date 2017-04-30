#!/usr/bin/env bash

ghdl -c *.vhdl -r golcell_tb --vcd=golcell_tb.vcd --stop-time=1ms --disp-time

ghdl -c *.vhdl -r golcell2_tb --vcd=golcell2_tb.vcd --stop-time=1ms --disp-time
