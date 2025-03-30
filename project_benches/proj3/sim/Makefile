export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

VLOG_OPT = -cover bcesf #+define+FSDB
VSIM_OPT = -coverage -classdebug -msgmode both -l transcript #-pli /mnt/apps/public/COE/synopsys_apps/verdi/S-2021.09-SP1/share/PLI/MODELSIM/LINUX/novas_fli.so

clean: 
	rm -rf work *.wlf transcript qrun.out *.ucdb 

comp_I2C_MB:
	vcom -cover bces ../rtl/iicmb_int_pkg.vhd
	vcom -cover bces ../rtl/iicmb_pkg.vhd
	vcom -cover bces ../rtl/mbyte.vhd
	vcom -cover bces ../rtl/mbit.vhd
	vcom -cover bces ../rtl/bus_state.vhd
	vcom -cover bces ../rtl/filter.vhd
	vcom -cover bces ../rtl/conditioner.vhd
	vcom -cover bces ../rtl/conditioner_mux.vhd
	vcom -cover bces ../rtl/iicmb_m.vhd
	vcom -cover bces ../rtl/regblock.vhd
	vcom -cover bces ../rtl/wishbone.vhd
	vcom -cover bces ../rtl/iicmb_m_wb.vhd

comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog $(VLOG_OPT)  ../testbench/top.sv

optimize:
	vopt +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

compile_2: comp_bench optimize

simulate:
	vsim  -i -coverage -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug_3step: clean compile simulate

debug:
	qrun -64 -gui -visualizer -onfinish stop -classdebug -uvmcontrol=all -msgmode both -permit_unmatched_virtual_intf -l run.log -f lab1_filelist.f -sv_seed 123456 -msglimit error -msglimitcount 20 -do "set IterationLimit 140000; set NoQuitOnFinish 1; coverage attribute -name TESTNAME -value test_top; coverage save -onexit test_top.ucdb; do wave.do" -debug,livesim -qwavedb=+signal+memory=1024+report+parameter+class+assertion+uvm_schematic+msg+classmemory=1024+statictaskfunc -top top -covermultiuserenv -designfile design.bin 

run: compile_2
	vsim  -batch -classdebug -msgmode both -l transcript -do "set NoQuitOnFinish 1; add wave -r *; log -r *; run -all; exit" optimized_debug_top_tb #-pli /mnt/apps/public/COE/synopsys_apps/verdi/S-2021.09-SP1/share/PLI/MODELSIM/LINUX/novas_fli.so

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	add testbrowser ./*.ucdb

view_coverage:
	vsim -viewcov ./i2cmb_test_plan.ucdb

merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 
	coverage open ./sim_and_testplan_merged.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb
