vlib work
vlog sequence_detector.v
vsim sequence_detector

log {/*}
add wave {/*}

#SW[0] reset when 0
#SW[1] input signal

#KEY[0] clock signal

#LEDR[3:0] displays current state
#LEDR[9] displays output

# clock
force KEY[0] 0 10, 1 20 -repeat 20

# reset
force SW[0] 1
force SW[0] 0 10
force SW[0] 1

# load pattern
force SW[1] 1 60
force SW[1] 0 20
force SW[1] 1 20
force SW[1] 0 20
