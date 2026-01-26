vlib work

vlog -sv ../../rtl/mem/mem.sv

vlog -sv mem_tb.sv

vsim -novopt mem_tb

add wave -r *

run -all