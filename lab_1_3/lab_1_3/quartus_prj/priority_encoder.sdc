set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150_i} -period 6.667 -waveform {0.000 3.333} [get_ports {clk_i}]

set_input_delay -clock clk_150_i -max 0.0 [get_ports {srst_i}]
set_input_delay -clock clk_150_i -min 0.0 [get_ports {srst_i}]

set_input_delay -clock clk_150_i -max 0.0 [get_ports {data_i[*]}]
set_input_delay -clock clk_150_i -min 0.0 [get_ports {data_i[*]}]

set_input_delay -clock clk_150_i -max 0.0 [get_ports {data_val_i}]
set_input_delay -clock clk_150_i -min 0.0 [get_ports {data_val_i}]


set_output_delay -clock clk_150_i -max 0.0 [get_ports {data_left_o[*]}]
set_output_delay -clock clk_150_i -min 0.0 [get_ports {data_left_o[*]}]

set_output_delay -clock clk_150_i -max 0.0 [get_ports {data_right_o[*]}]
set_output_delay -clock clk_150_i -min 0.0 [get_ports {data_right_o[*]}]

set_output_delay -clock clk_150_i -max 0.0 [get_ports {data_val_o}]
set_output_delay -clock clk_150_i -min 0.0 [get_ports {data_val_o}]

derive_pll_clocks
