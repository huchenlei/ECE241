vlib work
vlog integrate_datapath_control.v
vsim main

log {/*}
add wave {/*}

set time 0
force CLOCK_50 0 0, 1 5000 -repeat 10000

# initial condition on board
force {KEY} 1111
force {SW} 0000000000

# let datapath initialize
run 200 ns

# move select box
force {KEY[1]} 0
run 10 ns

force {KEY[1]} 1
force {KEY[2]} 0
run 10 ns
force {KEY[2]} 1

# select a piece
force {SW[0]} 1
run 10 ns

force {SW[0]} 0

# move select box
force {KEY[1]} 0
run 10 ns

force {KEY[1]} 1
force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1

# select destination
force {SW[0]} 1
run 10 ns
force{SW[0]} 0

run 100 ns
