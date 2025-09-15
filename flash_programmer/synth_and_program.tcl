

report_ip_status -name ip_status 
update_module_reference [get_ips  design_1_flash_programmer_0_0]


export_ip_user_files -of_objects [get_files /home/michal/FpgaFlashTester/flash_programmer/flash_programmer.srcs/sources_1/bd/design_1/design_1.bd] -no_script -sync -force -quiet
export_simulation -lib_map_path [list {modelsim=/home/michal/FpgaFlashTester/flash_programmer/flash_programmer.cache/compile_simlib/modelsim} {questa=/home/michal/FpgaFlashTester/flash_programmer/flash_programmer.cache/compile_simlib/questa} {xcelium=/home/michal/FpgaFlashTester/flash_programmer/flash_programmer.cache/compile_simlib/xcelium} {vcs=/home/michal/FpgaFlashTester/flash_programmer/flash_programmer.cache/compile_simlib/vcs} {riviera=/home/michal/FpgaFlashTester/flash_programmer/flash_programmer.cache/compile_simlib/riviera}] -of_objects [get_files /home/michal/FpgaFlashTester/flash_programmer/flash_programmer.srcs/sources_1/bd/design_1/design_1.bd] -directory /home/michal/FpgaFlashTester/flash_programmer/flash_programmer.ip_user_files/sim_scripts -ip_user_files_dir /home/michal/FpgaFlashTester/flash_programmer/flash_programmer.ip_user_files -ipstatic_source_dir /home/michal/FpgaFlashTester/flash_programmer/flash_programmer.ip_user_files/ipstatic -use_ip_compiled_libs -force -quiet
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 20
