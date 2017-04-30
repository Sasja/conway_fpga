#!/usr/bin/env bash
ghdl -c *.vhdl -r golcell_tb --vcd=golcell_tb.vcd --stop-time=1ms --disp-time
