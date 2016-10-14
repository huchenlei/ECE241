vlib work
vlog alu_v2.v
vsim alu_v2

log{/*}
add wave{/*}

# test case 0
# load data
force {SW[0]} 0
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0

force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 1
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 2
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 3
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 4
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 1
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 5
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 1
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 6
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 1
run 10 ns

force {KEY[0]} 1
run 10 ns

# test case 7
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 1
force {KEY[3]} 1
run 10 ns

force {KEY[0]} 1
run 10 ns
