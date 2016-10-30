vlib work
vlog poly_function.v
vsim fpga_top

log {/*}
add wave {/*}

#Sw[7:0] data_in

#KEY[0] synchronous reset when pressed
#KEY[1] go signal

#LEDR displays result
#HEX0 & HEX1 also displays result

set time 0
force CLOCK_50 0 0, 1 25 -repeat 50

# reset
force KEY[0] 0
force KEY[0] 1 10
force KEY[0] 0

# load a as 7
force SW[0] 1
force SW[1] 1
force SW[2] 1
force SW[3] 0
force SW[4] 0
force SW[5] 0
force SW[6] 0
force SW[7] 0

force KEY[1] 0
force KEY[1] 1 10
force KEY[1] 0

# load b as 4
force SW[0] 0
force SW[1] 0
force SW[2] 1

force KEY[1] 0
force KEY[1] 1 10
force KEY[1] 0

# load c as 3
force SW[0] 1
force SW[1] 1
force SW[2] 0

force KEY[1] 0
force KEY[1] 1 10
force KEY[1] 0

# load x as 2
force SW[0] 0
force SW[1] 1
force SW[2] 0

force KEY[1] 0
force KEY[1] 1 10
force KEY[1] 0
