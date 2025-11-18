vlib work

vlog ../rtl/constants.v
vlog ../rtl/CRC_16_ANSI.v


vlog -sv CRC_16_ANSI_tb.sv

vsim -novopt CRC_16_ANSI_tb

add wave -r *

run -all