vlib work
vlog lab7_2.v
vsim datapath

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 25 -repeat 50

force {resetn} 0
run 10 ns
force {resetn} 1

force {pos[0]} 0
force {pos[1]} 0
force {pos[2]} 0
force {pos[3]} 0
force {pos[4]} 0
force {pos[5]} 1
force {pos[6]} 0

force {color[0]} 0
force {color[0]} 0
force {color[0]} 1

force {ld_x} 1
force {ld_y} 0
run 10 ns

force {pos[1]} 1
force {ld_x} 0
force {ld_y} 1
run 10 ns
