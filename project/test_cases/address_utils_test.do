vlib work
vlog address_utils.v
vsim address_encoder

log {/*}
add wave {/*}

# input 4, 5
force {pos_x[0]} 0
force {pos_x[1]} 0
force {pos_x[2]} 1
force {pos_y[0]} 1
force {pos_y[1]} 0
force {pos_y[2]} 1

run 10 ns
# should output 37

# input 7, 0
force {pos_x[0]} 1
force {pos_x[1]} 1
force {pos_x[2]} 1
force {pos_y[0]} 0
force {pos_y[1]} 0
force {pos_y[2]} 0

run 10 ns
