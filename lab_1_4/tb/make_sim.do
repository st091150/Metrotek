vlib work

vlog -sv ../rtl/bit_population_counter.sv

vlog -sv bit_population_counter_tb.sv

vsim -novopt bit_population_counter_tb

do wave.do

run -all