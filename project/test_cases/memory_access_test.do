vlib work
vlog memory_access.v
vsim -L altera_mf_ver memory_access

log {/*}
add wave {/*}

set time 0
force clk 0 0, 1 2500 -repeat 5000

# write (01) (0x000000)
# datapath input
# address(0x000000)
force {address_datapath[0]} 0
force {address_datapath[1]} 0
force {address_datapath[2]} 0
force {address_datapath[3]} 0
force {address_datapath[4]} 0
force {address_datapath[5]} 0
# data (01)
force {data_in_datapath[0]} 1
force {data_in_datapath[1]} 0
force {data_in_datapath[2]} 0
force {data_in_datapath[3]} 0

force {wirteEn} 1
# set signal to datapath
force {control_signal[0]} 0
force {control_signal[1]} 1
run 10 ns

# write (03) (0x000001)
# datapath input
# address(0x000001)
force {address_datapath[0]} 1
force {address_datapath[1]} 0
force {address_datapath[2]} 0
force {address_datapath[3]} 0
force {address_datapath[4]} 0
force {address_datapath[5]} 0
# data (01)
force {data_in_datapath[0]} 1
force {data_in_datapath[1]} 1
force {data_in_datapath[2]} 0
force {data_in_datapath[3]} 0

force {wirteEn} 1
# set signal to datapath
force {control_signal[0]} 0
force {control_signal[1]} 1
run 10 ns

# read (0x000000) to control module
# control input
# address(0x000000)
force {address_control[0]} 0
force {address_control[1]} 0
force {address_control[2]} 0
force {address_control[3]} 0
force {address_control[4]} 0
force {address_control[5]} 0
force {writeEn} 0
force {control_signal[0]} 0
force {control_signal[1]} 0
run 10 ns

# read (0x000001) to validator module
# validator input
# address(0x000001)
force {address_validator[0]} 1
force {address_validator[1]} 0
force {address_validator[2]} 0
force {address_validator[3]} 0
force {address_validator[4]} 0
force {address_validator[5]} 0
force {control_signal[0]} 1
force {control_signal[1]} 0
run 10 ns

# switch to control
force {control_signal[0]} 0
force {control_signal[1]} 0
run 10 ns
