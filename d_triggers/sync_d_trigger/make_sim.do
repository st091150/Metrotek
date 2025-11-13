vlib work

vlog -sv sync_d_trigger.sv
vlog -sv sync_d_trigger_tb.sv

vsim -novopt sync_d_trigger_tb

add wave -r *

run -all