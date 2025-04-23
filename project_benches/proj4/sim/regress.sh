# !/bin/bash

make clean compile optimize

make run_cli GEN_TRANS_TYPE=i2cmb_register_test
mv transcript transcript_register_test

# make run_cli GEN_TYPE=i2cmb_generator_random_test PLUS_ARGS=+DISABLE_PREDICTOR
# mv transcript transcript_random_test

make run_cli GEN_TRANS_TYPE=i2cmb_dut_functionality_test
mv transcript transcript_i2c_operation

make run_cli GEN_TRANS_TYPE=i2cmb_generator_compulsory_test
mv transcript transcript_generator_compulosry_test

# make run_cli GEN_TYPE=i2cmb_generator_32_reads
# mv transcript transcript_32_reads

# make run_cli GEN_TYPE=i2cmb_generator_64_alt_wr
# mv transcript transcript_64_alt_wr

make merge_coverage

make report_coverage
