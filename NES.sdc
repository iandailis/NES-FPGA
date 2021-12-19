## Generated SDC file "NES.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"

## DATE    "Wed Nov 24 16:18:55 2021"

##
## DEVICE  "10M50DAF484C7G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {MAX10_CLK1_50} -period 20.000 -waveform { 0.000 10.000 } 


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_oci_break:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci_break|break_readreg*}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug|*resetlatch}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr[33]}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug|monitor_ready}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr[0]}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug|monitor_error}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr[34]}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_ocimem:the_NIOSIIe_nios2_gen2_0_cpu_nios2_ocimem|*MonDReg*}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_tck|*sr*}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_sysclk:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_wrapper|NIOSIIe_nios2_gen2_0_cpu_debug_slave_sysclk:the_NIOSIIe_nios2_gen2_0_cpu_debug_slave_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*NIOSIIe_nios2_gen2_0_cpu:*|NIOSIIe_nios2_gen2_0_cpu_nios2_oci:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci|NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug:the_NIOSIIe_nios2_gen2_0_cpu_nios2_oci_debug|monitor_go}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] 100.000
set_max_delay -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] 100.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}] -100.000
set_min_delay -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}] -100.000


#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Net Delay
#**************************************************************

set_net_delay -max 2.000 -from [get_registers {*altera_avalon_st_clock_crosser:*|in_data_buffer*}] -to [get_registers {*altera_avalon_st_clock_crosser:*|out_data_buffer*}]
set_net_delay -max 2.000 -from [get_registers *] -to [get_registers {*altera_avalon_st_clock_crosser:*|altera_std_synchronizer_nocut:*|din_s1}]
