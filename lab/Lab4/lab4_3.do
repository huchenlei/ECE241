vlib work
vlog main_lab4.v
vsim main_lab4

log{/*}
add wave{/*}

# test case 1 load data
force {KEY[0]} 0
force {KEY[1]} 0 #PLn
# initialize data
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 1
force {SW[3]} 0
force {SW[4]} 1
force {SW[5]} 0
force {SW[6]} 1
force {SW[7]} 0
run 10 ns
force {KEY[0]} 1
run 10 ns

# test case 2 rotate right
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 1 #RR
force {KEY[3]} 0 #ASR
run 10 ns
force {KEY[0]} 1
run 10 ns

force {KEY[0]} 0
run 10 ns
force {KEY[0]} 1
run 10 ns

# test case 3 Arithmetic shift right
force {KEY[0]} 0
force {KEY[3]} 1 #ASR
run 10 ns
force {KEY[0]} 1
run 10 ns
force {KEY[0]} 0
run 10 ns
force {KEY[0]} 1
run 10 ns

# test case 4 rotate left
force {KEY[0]} 0
force {KEY[2]} 1 # RR
run 10 ns
force {KEY[0]} 1
run 10 ns
force {KEY[0]} 0
run 10 ns
force {KEY[0]} 1
run 10 ns

# test case 5 reset
for {SW[9]} 1
run 10 ns
