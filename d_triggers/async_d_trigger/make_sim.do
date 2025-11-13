vlib work

vlog -sv async_d_trigger.sv
vlog -sv async_d_trigger_tb.sv

vsim -novopt async_d_trigger_tb

add wave -r *

run -all