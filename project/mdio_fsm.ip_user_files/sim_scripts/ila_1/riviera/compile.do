vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../mdio_fsm.srcs/sources_1/ip/ila_1/hdl/verilog" \
"../../../../mdio_fsm.srcs/sources_1/ip/ila_1/sim/ila_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

