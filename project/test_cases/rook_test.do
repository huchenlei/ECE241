vlib work
vlog validator_rook.v
vsim validator_rook

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 5000 -repeat 10000

# set up
force {reset} 0
force {start_validation} 0

# move from (0,0) to (3, 0) (should be valid)
force {piece_x} 000
force {piece_y} 000
force {move_x} 011
force {move_y} 000

force {piece_read} 0000

run 10 ns

force {start_validation} 1
run 10 ns
force {start_validation} 0
run 150 ns

# move from (0, 0) to (1, 1) (should not be valid)
force {move_y} 001

force {start_validation} 1
run 10 ns
force {start_validation} 0
run 150 ns
