vlib work
vlib altera_mf_ver

vmap altera_mf_ver work

vlog lab7_2.v
vsim -L altera_mf_ver lab7_2

log {/*}
add wave {/*}

set time 0
force CLOCK_50 0 0, 1 25 -repeat 50

# reset
force {KEY[0]} 0
run 10 ns

force {KEY[0]} 1
run 10 ns

# load x_ 8
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 1
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0

# load color
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 1

force {KEY[3]} 0
run 10 ns

force {KEY[3]} 1
run 10 ns

#load y_ 9
force {SW[0]} 1
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 1
force {SW[4]} 0
force {SW[5]} 0
force {SW[6]} 0

force {KEY[3]} 0
run 10 ns

force {KEY[3]} 1
run 10 ns

# draw
force {KEY[1]} 0
run 10 ns

# to black
force {KEY[2]} 0
run 10 ns
