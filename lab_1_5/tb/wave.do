# Основные сигналы тб
add wave sim:/debouncer_tb/clk_i

# Входы DUT
add wave sim:/debouncer_tb/DUT/key_i

# Счетчик DUT
add wave sim:/debouncer_tb/DUT/glitch_counter

# Выходы DUT
add wave sim:/debouncer_tb/DUT/key_pressed_stb_o
