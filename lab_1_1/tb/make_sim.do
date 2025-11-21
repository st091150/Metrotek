vlib work

vlog -sv ../rtl/serializer.sv

vlog -sv serializer_tb.sv

vsim -novopt serializer_tb

add wave -r *

run -all