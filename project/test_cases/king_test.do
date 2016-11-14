# test passed!
vlib work
vlog validator_king.v
vsim validator_king

log {/*}
add wave {/*}

# 2 valid move
# set original position (0, 0)
force {piece_x[0]} 0
force {piece_x[1]} 0
force {piece_x[2]} 0
force {piece_y[0]} 0
force {piece_y[1]} 0
force {piece_y[2]} 0
# set destination (1, 1)
force {move_x[0]} 1
force {move_x[1]} 0
force {move_x[2]} 0
force {move_y[0]} 1
force {move_y[1]} 0
force {move_y[1]} 1
force {move_y[2]} 1

run 10 ns

# set original position (1, 7)
force {piece_x[0]} 1
force {piece_x[1]} 0
force {piece_x[2]} 0
force {piece_y[0]} 1
force {piece_y[1]} 1
force {piece_y[2]} 1
# set destination (7, 1)
force {move_x[0]} 1
force {move_x[1]} 1
force {move_x[2]} 1
force {move_y[0]} 1
force {move_y[1]} 0
force {move_y[2]} 0

run 10 ns


# set original position (1, 7)force {piece_x[0]} 1force {piece_x[1]} 0force {piece_x[2]} 0force {piece_y[0]} 1force {piece_y[1]} 1force {piece_y[2]} 1# set destination (1, 7)force {move_x[0]} 1force {move_x[1]} 0force {move_x[2]} 0force {move_y[0]} 1force {move_y[1]} 1force {move_y[2]} 1run 10 ns
force {move_y[2]} 0

run 10 ns

# set original position (4, 4)
force {piece_x[0]} 0
force {piece_x[1]} 0
force {piece_x[2]} 1
force {piece_y[0]} 0
force {piece_y[1]} 0
force {piece_y[2]} 1
# set destination (4, 5)
force {move_x[0]} 0
force {move_x[1]} 0
force {move_x[2]} 1
force {move_y[0]} 1
force {move_y[1]} 0
force {move_y[2]} 1

run 10 ns

# 2 invalid move
# set original position (0, 0)
force {piece_x[0]} 0
force {piece_x[1]} 0
force {piece_x[2]} 0
force {piece_y[0]} 0
force {piece_y[1]} 0
force {piece_y[2]} 0
# set destination (1, 7)
force {move_x[0]} 1
force {move_x[1]} 0
force {move_x[2]} 0
force {move_y[0]} 1
force {move_y[1]} 1
force {move_y[2]} 1

run 10 ns

# set original position (1, 7)
force {piece_x[0]} 1
force {piece_x[1]} 0
force {piece_x[2]} 0
force {piece_y[0]} 1
force {piece_y[1]} 1
force {piece_y[2]} 1
# set destination (7, 1)
force {move_x[0]} 1
force {move_x[1]} 1
force {move_x[2]} 1
force {move_y[0]} 1
force {move_y[1]} 0
force {move_y[2]} 0

run 10 ns


# set original position (1, 7)
force {piece_x[0]} 1
force {piece_x[1]} 0
force {piece_x[2]} 0
force {piece_y[0]} 1
force {piece_y[1]} 1
force {piece_y[2]} 1
# set destination (1, 7)
force {move_x[0]} 1
force {move_x[1]} 0
force {move_x[2]} 0
force {move_y[0]} 1
force {move_y[1]} 1
force {move_y[2]} 1
run 10 ns
