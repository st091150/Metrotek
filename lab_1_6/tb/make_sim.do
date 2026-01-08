vlib work

vlog -sv ../rtl/traffic_lights.sv

vlog -sv traffic_lights_tb.sv

vsim -novopt traffic_lights_tb

do wave.do

run -all