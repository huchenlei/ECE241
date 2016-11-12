vlib work
vlog control.v
vsim control

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 2500 -repeat 5000

# mocking the selected piece (empty)
force {selected_piece[0]} 0
force {selected_piece[1]} 0
force {selected_piece[2]} 0
force {selected_piece[3]} 0

# initiate everything
run 30 ns

# moving the selecting box
force {up} 1
force {down} 0
force {right} 0
force {left} 0
run 30 ns

force {left} 1
run 30 ns

# select empty
# should back to move box 1
force {select} 1
run 10 ns
force {select} 0
run 10 ns

# mocking the selected piece (black knight)#2
force {selected_piece[0]} 0
force {selected_piece[1]} 1
force {selected_piece[2]} 0
force {selected_piece[3]} 0

# select white knight
force {select} 1
run 10 ns
force {select} 0
run 10 ns

# mocking the destination square (white king)#12
# mocking the empty case for another test
force {selected_piece[0]} 0
force {selected_piece[1]} 0
force {selected_piece[2]} 1
force {selected_piece[3]} 1

# in s_move 2
force {up} 1
run 30 ns
force {right} 1
run 30 ns

# (should be a deselect case here)
# select white king
force {select} 1
run 10 ns
force {select} 0
run 50 ns

# should back to init
# game over
