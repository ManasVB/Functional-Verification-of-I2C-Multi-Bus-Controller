package i2cmb_env_pkg;

  import ncsu_pkg::*;
  import i2c_pkg::*;
  import wb_pkg::*;

  `include "ncsu_macros.svh"

  `include "src/i2cmb_env_configuration.svh"
  `include "src/i2cmb_predictor.svh"
  `include "src/i2cmb_coverage.svh"
  `include "src/i2cmb_i2c_coverage.svh"
  `include "src/i2cmb_wb_coverage.svh"
  `include "src/i2cmb_scoreboard.svh"
  `include "src/i2cmb_environment.svh"
  `include "src/i2cmb_generator.svh"
  

  `include "src/i2cmb_generator_compulsory_test.svh"
  `include "src/i2cmb_register_test.svh"
  `include "src/i2cmb_dut_functionality_test.svh"

  `include "src/i2cmb_test.svh"

endpackage
