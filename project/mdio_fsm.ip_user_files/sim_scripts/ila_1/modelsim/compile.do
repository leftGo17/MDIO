vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr "+incdir+../../../../mdio_fsm.srcs/sources_1/ip/ila_1/hdl/verilog" \
"../../../../mdio_fsm.srcs/sources_1/ip/ila_1/sim/ila_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

