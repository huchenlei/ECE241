vlib work
vlog box_render.v
vsim box_render

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 2500 -repeat 5000

force {box_x} 000
force {box_y} 000
force {box_on} 0
force {start_render} 0
force {reset} 0

run 10 ns

force {start_render} 1
run 30 ns

force {box_on} 1
run 10 ns
force {start_render} 0

run 200 ns
