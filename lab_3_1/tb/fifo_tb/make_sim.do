set path_to_library /opt/fpga/quartus/18.1/quartus/eda/sim_lib
vlib work

vlog -sv ../../rtl/fifo/fifo.sv
vlog -sv ../../rtl/mem/mem.sv

vlog $path_to_library/altera_mf.v

vlog -sv fifo_tb.sv

vsim -novopt fifo_tb

do wave.do

run -all