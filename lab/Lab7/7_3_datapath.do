lib work
vlog lab7_3.v
vsim datapath

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 25 -repeat 50

# reset
force {resetn} 0
run 10 ns
force {resetn} 1

force {x_coordinate[0]} 1
force {x_coordinate[1]} 0
force {x_coordinate[2]} 0
force {x_coordinate[3]} 0
force {x_coordinate[4]} 0
force {x_coordinate[5]} 0
force {x_coordinate[6]} 1
force {x_coordinate[7]} 1

force {y_coordinate[0]} 0
force {y_coordinate[1]} 0
force {y_coordinate[2]} 0
force {y_coordinate[3]} 0
force {y_coordinate[4]} 0
force {y_coordinate[5]} 0
force {y_coordinate[6]} 0

force{color[0]} 0
force{color[1]} 0
force{color[2]} 1

force {ld_x} 1
force {ld_y} 1

run 10 ns

force {x_coordinate[0]} 0
force {ld_x} 0
force {ld_y} 0
run 10 ns

force {ld_x} 1
force {ld_y} 1
run 10 ns
