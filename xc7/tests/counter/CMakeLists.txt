add_fpga_target(
  NAME counter_zybo
  BOARD zybo-full
  SOURCES counter_bufg.v
  INPUT_IO_FILE zybo.pcf
  )

add_vivado_target(
    NAME counter_zybo_vivado
    PARENT_NAME counter_zybo
    CLOCK_PINS clk
    CLOCK_PERIODS 10.0
    # TODO: https://github.com/SymbiFlow/symbiflow-arch-defs/issues/1183
    DISABLE_DIFF_TEST
    )

add_file_target(FILE counter_basys3.v SCANNER_TYPE verilog)

add_fpga_target(
  NAME counter_basys3
  BOARD basys3-full
  SOURCES counter_basys3.v
  INPUT_IO_FILE ../common/basys3.pcf
  EXPLICIT_ADD_FILE_TARGET
  )

add_vivado_target(
    NAME counter_basys3_vivado
    PARENT_NAME counter_basys3
    CLOCK_PINS clk
    CLOCK_PERIODS 10.0
    # TODO: https://github.com/SymbiFlow/symbiflow-arch-defs/issues/1018
    #DISABLE_DIFF_TEST
    )

add_fpga_target(
  NAME counter_arty
  BOARD arty-uart
  SOURCES counter_arty.v
  INPUT_IO_FILE arty.pcf
)
