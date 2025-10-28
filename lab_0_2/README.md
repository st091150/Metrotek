# Принцип работы схемы
## При data_val_i = 0, на выходе:
- data_right_o = 4'b0000
- data_left_o = 4'b0000
- data_val_o = 1'b0

## При data_val_i = 1, выход считается следующим образом:
### Для data_right_o:
- data_right_o[3] = data_i[3]
- data_right_o[2] = data_i[2] & (~data_right_o[3])
- data_right_o[1] = data_i[1] & (~data_right_o[2] & ~data_right_o[3])
- data_right_o[0] = data_i[0] & (~data_right_o[1] & ~data_right_o[2] & ~data_right_o[3])

### Для data_left_o:
- data_left_o[0] = data_i[0]
- data_left_o[1] = data_i[1] & (~data_left_o[0])
- data_left_o[2] = data_i[2] & (~data_left_o[1] & ~data_left_o[0])
- data_left_o[3] = data_i[3] & (~data_left_o[2] & ~data_left_o[1] & ~data_left_o[0])

data_val_o = 1'b1

# Запуск
Для запуска симуляции в Modelsim нужно выполнить команду vsim -do make_sim.do
