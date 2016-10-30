vlib work
vlog devision.v
vsim devision_top

log {/*}
add wave {/*}

# input
# SW[3:0] divisor value
# SW[7:4] divident value
# CLOCK_50 clock signal
# KEY[0] active_high reset
# KEY[1] go signal to start computation
# output
# HEX0 devisor
# HEX2 devident
# HEX4 quotient
# HEX5 remainder
# LEDR[3:0] quotient

# test case 0
# reset
force {KEY[0]} 1
force {CLOCK_50} 0
run 10 ns

force {CLOCK_50} 1
run 10 ns
force {KEY[0]} 0

# test case 1
# compute 7/3

force {KEY[1]} 0
force {CLOCK_50} 0
run 10 ns

# load devisor 3
force {SW[0]} 1
force {SW[1]} 1
force {SW[2]} 0
force {SW[3]} 0

# load devident 7
force {SW[4]} 1
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 0

force {KEY[1]} 1
force {CLOCK_50} 1
run 10 ns

force {KEY[1]} 0
force {CLOCK_50} 0
run 10 ns

force {CLOCK_50} 1
run 10 ns
