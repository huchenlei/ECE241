vlib work
vlog lab5_1.v
vsim lab5_1

log{/*}
add wave{/*}

# SW[1] = enable;
# KEY[0] = clock;
# SW[0] = reset

# test case 0
force {SW[1]} 1
force {SW[0]} 0
force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# 1 ---- 20ns

force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# 2 ---- 40ns

force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# 3 ---- 60 ns

force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# 4 ---- 80 ns

force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# 5 ---- 100 ns

# test case 1
# reset the clock
force {SW[0]} 1
force {KEY[0]} 0
run 10 ns

force {KEY[1]} 1
run 10 ns

# test case 2
# disable clock
force {SW[0]} 0
force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

force {SW[1]} 0
force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns
