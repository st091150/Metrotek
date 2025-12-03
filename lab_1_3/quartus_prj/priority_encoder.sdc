set_time_format -unit ns -decimal_places 3

create_clock -name {clk_150_i} -period 6.667 -waveform {0.000 3.333} [get_ports {clk}]

derive_pll_clocks
