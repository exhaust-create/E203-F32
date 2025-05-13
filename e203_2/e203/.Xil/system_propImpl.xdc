set_property SRC_FILE_INFO {cfile:e:/Vivado_Workspace/e203_primary/e203_primary/e203_primary.gen/sources_1/ip/mmcm/mmcm.xdc rfile:../../../e203_primary/e203_primary/e203_primary.gen/sources_1/ip/mmcm/mmcm.xdc id:1 order:EARLY scoped_inst:ip_mmcm/inst} [current_design]
current_instance ip_mmcm/inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.100
