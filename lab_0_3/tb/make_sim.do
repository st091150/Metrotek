vlib work

vlog ../rtl/delay_15.v
vlog ../rtl/mux161.v
vlog -sv delay_15_tb.sv

vsim -novopt delay_15_tb

add wave -r *

delete wave /delay_15_tb/DUT/b2v_inst15/*

run -all