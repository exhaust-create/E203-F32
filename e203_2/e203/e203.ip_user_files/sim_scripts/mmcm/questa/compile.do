vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../e203.gen/sources_1/ip/mmcm" \
"E:/Vivado/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"E:/Vivado/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../e203.gen/sources_1/ip/mmcm" \
"../../../../e203.gen/sources_1/ip/mmcm/mmcm_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

