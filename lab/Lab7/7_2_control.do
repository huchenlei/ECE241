vlib work
vlog lab7_2.v
vsim control

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 25 -repeat 50

force {resetn} 1
force {go} 0
run 10 ns

force {go} 1
run 10 ns

force {go} 0
run 10 ns

force {go} 1
run 10 ns

force {plot} 1
run 10 ns

force {resetn} 0
run 10 ns
