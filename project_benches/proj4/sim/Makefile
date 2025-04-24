GEN_TRANS_TYPE ?= i2cmb_transaction
TEST_SEED ?= random

export ECE745_PROJECT_HOME ?= $(PWD)/../../..

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript qrun.out covhtmlreport *.ucdb

comp_I2C_MB:
	vcom +cover=bcefsx ../rtl/iicmb_int_pkg.vhd
	vcom +cover=bcefsx ../rtl/iicmb_pkg.vhd
	vcom +cover=bcefsx ../rtl/mbyte.vhd
	vcom +cover=bcefsx ../rtl/mbit.vhd
	vcom +cover=bcefsx ../rtl/bus_state.vhd
	vcom +cover=bcefsx ../rtl/filter.vhd
	vcom +cover=bcefsx ../rtl/conditioner.vhd
	vcom +cover=bcefsx ../rtl/conditioner_mux.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m.vhd
	vcom +cover=bcefsx ../rtl/regblock.vhd
	vcom +cover=bcefsx ../rtl/wishbone.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m_wb.vhd

inc_test:	# This command creates .ucdb files for the 'tests' needed to link in the testplan
	$(MAKE) run_cli GEN_TRANS_TYPE=i2cmb_register_test
	$(MAKE) run_cli GEN_TRANS_TYPE=i2cmb_generator_compulsory_test
	$(MAKE) run_cli GEN_TRANS_TYPE=i2cmb_dut_functionality_test

comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog ../testbench/top.sv

optimize:
	vopt +cover=bcefsx +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

run_cli:
	vsim  -c -coverage -sv_seed $(TEST_SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

run_gui:
	vsim -coverage -sv_seed $(TEST_SEED) -do " set NoQuitOnFinish 1; do wave.do;run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(TEST_SEED).ucdb" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile optimize run_cli

debug: clean compile optimize run_gui

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	add testbrowser ./*.ucdb

merge_coverage:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals regression.ucdb ./*.ucdb
	vsim -viewcov =regression.ucdb

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

total:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	add testbrowser ./*.ucdb
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 
	coverage open ./sim_and_testplan_merged.ucdb
