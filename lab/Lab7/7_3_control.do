vlib work
vlog lab7_3.v
vsim control

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 25 -repeat 50

#reset
force {resetn} 0
run 10 ns
force {resetn} 1

run 100 ns
