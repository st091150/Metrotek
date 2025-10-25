vlib work

vlog ../rtl/lab_0.v
vlog -sv mux_tb.sv

vsim -novopt mux_tb

add wave -r *

run -all