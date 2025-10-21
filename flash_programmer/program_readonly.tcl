open_hw_manager
connect_hw_server -allow_non_jtag

open_hw_target
set_property PROGRAM.FILE {./bitstreams/control_sector_read_only_100MHz.bit} [get_hw_devices xck26_0]
current_hw_device [get_hw_devices xck26_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xck26_0] 0]
current_hw_device [get_hw_devices arm_dap_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices arm_dap_1] 0]
current_hw_device [get_hw_devices xck26_0]
set_property PROBES.FILE {} [get_hw_devices xck26_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xck26_0]
set_property PROGRAM.FILE {./bitstreams/control_sector_read_only_100MHz.bit} [get_hw_devices xck26_0]
program_hw_devices [get_hw_devices xck26_0]
refresh_hw_device [lindex [get_hw_devices xck26_0] 0]