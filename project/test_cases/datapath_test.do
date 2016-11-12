vlib work
vlog datapath.v
vsim datapath

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 5000 -repeat 10000

# set up
force {reset} 0
force {initialize_board} 1
force {move_piece} 0
force {piece_x} 000
force {piece_y} 000
force {move_x} 001
force {move_y} 010
force {piece_to_move} 0010
run 10 ns
# avoid looping
force {initialize_board} 0

run 200 ns

# move piece
force {move_piece} 1
run 10 ns
# avoid looping
force {move_piece} 0

run 100 ns
