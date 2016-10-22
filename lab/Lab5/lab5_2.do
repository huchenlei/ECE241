vlib work
vlog lab5_2.v
vsim lab5_2

log{/*}
add wave{/*}

# CLOCK_50 clk
# SW[1:0] frequency control

# test case 0
force {SW[0]} 0
force {SW[1]} 0

force {CLOCK_50} 0
run 10 ns

force {CLOCK_50} 1
run 10 ns

force {CLOCK_50} 0
run 10 ns

force {CLOCK_50} 1
run 10 ns

force {CLOCK_50} 0
run 10 ns

force {CLOCK_50} 1
run 10 ns

# test case 1
set step 20
proc runSim{}{
  set runtime 0
  global step

  for{set i 0}{$i < 50000001}{
    force -freeze CLOCK_50 [expr ($i & 0x01)] $runtime
    set runtime [expr $runtime + $step]
  }
  run $runtime
  view wave
}
