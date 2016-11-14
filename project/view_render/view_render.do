vlib work
vlog view_render.v
vsim view_render

log {/*}
add wave {/*}
set time 0
force clk 0 0, 1 25 -repeat 50
force {resetn} 0
run 10 ns
force {resetn} 1
#this should be controled by control.v
force {if_moved} 1

#selected 2,7
force {box_x[0]} 0
force {box_x[1]} 1
force {box_x[2]} 0
force {box_y[0]} 0
force {box_y[1]} 1
force {box_y[2]} 1
#bishop test case
force{pieceFromMem[0]} 1
force{pieceFromMem[1]} 0
force{pieceFromMem[2]} 0
force{pieceFromMem[3]} 0
