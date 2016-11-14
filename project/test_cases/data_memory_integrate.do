vlib work
vlog integrate_datapath_memory.v
vsim -L altera_mf main

log {/*}
add wave {/*}

set time 0
force CLOCK_50 0 0, 1 5000 -repeat 10000

# set up
force {SW} 00000000000
force {KEY} 1111
force {destination_x} 000
force {destination_y} 001
force {origin_x} 000
force {origin_y} 000
# black rook
force {piece_to_move} 0100
force {initialize_board} 0
force {move_piece} 0

run 10 ns

force {initialize_board} 1
run 2000 ns
