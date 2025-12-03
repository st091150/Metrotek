# Основные сигналы тб
add wave sim:/priority_encoder_tb/clk_i
add wave sim:/priority_encoder_tb/srst_i

# Входы DUT
add wave sim:/priority_encoder_tb/DUT/data_i
add wave sim:/priority_encoder_tb/DUT/data_val_i

# Выходы DUT
add wave sim:/priority_encoder_tb/DUT/data_left_o
add wave sim:/priority_encoder_tb/DUT/data_right_o
add wave sim:/priority_encoder_tb/DUT/data_val_o
