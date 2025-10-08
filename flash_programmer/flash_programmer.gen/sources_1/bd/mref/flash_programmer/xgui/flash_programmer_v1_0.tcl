# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BLOCKS_TO_TEST" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BLOCK_OFFSET" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_COUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_FAULTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGES_IN_BLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "UART_MAX_BYTES" -parent ${Page_0}


}

proc update_PARAM_VALUE.BLOCKS_TO_TEST { PARAM_VALUE.BLOCKS_TO_TEST } {
	# Procedure called to update BLOCKS_TO_TEST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLOCKS_TO_TEST { PARAM_VALUE.BLOCKS_TO_TEST } {
	# Procedure called to validate BLOCKS_TO_TEST
	return true
}

proc update_PARAM_VALUE.BLOCK_OFFSET { PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to update BLOCK_OFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLOCK_OFFSET { PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to validate BLOCK_OFFSET
	return true
}

proc update_PARAM_VALUE.MAX_COUNT { PARAM_VALUE.MAX_COUNT } {
	# Procedure called to update MAX_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_COUNT { PARAM_VALUE.MAX_COUNT } {
	# Procedure called to validate MAX_COUNT
	return true
}

proc update_PARAM_VALUE.MAX_FAULTS { PARAM_VALUE.MAX_FAULTS } {
	# Procedure called to update MAX_FAULTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_FAULTS { PARAM_VALUE.MAX_FAULTS } {
	# Procedure called to validate MAX_FAULTS
	return true
}

proc update_PARAM_VALUE.PAGES_IN_BLOCK { PARAM_VALUE.PAGES_IN_BLOCK } {
	# Procedure called to update PAGES_IN_BLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAGES_IN_BLOCK { PARAM_VALUE.PAGES_IN_BLOCK } {
	# Procedure called to validate PAGES_IN_BLOCK
	return true
}

proc update_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to update PAGE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to validate PAGE_SIZE
	return true
}

proc update_PARAM_VALUE.UART_MAX_BYTES { PARAM_VALUE.UART_MAX_BYTES } {
	# Procedure called to update UART_MAX_BYTES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UART_MAX_BYTES { PARAM_VALUE.UART_MAX_BYTES } {
	# Procedure called to validate UART_MAX_BYTES
	return true
}


proc update_MODELPARAM_VALUE.MAX_COUNT { MODELPARAM_VALUE.MAX_COUNT PARAM_VALUE.MAX_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_COUNT}] ${MODELPARAM_VALUE.MAX_COUNT}
}

proc update_MODELPARAM_VALUE.PAGE_SIZE { MODELPARAM_VALUE.PAGE_SIZE PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAGE_SIZE}] ${MODELPARAM_VALUE.PAGE_SIZE}
}

proc update_MODELPARAM_VALUE.PAGES_IN_BLOCK { MODELPARAM_VALUE.PAGES_IN_BLOCK PARAM_VALUE.PAGES_IN_BLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAGES_IN_BLOCK}] ${MODELPARAM_VALUE.PAGES_IN_BLOCK}
}

proc update_MODELPARAM_VALUE.BLOCKS_TO_TEST { MODELPARAM_VALUE.BLOCKS_TO_TEST PARAM_VALUE.BLOCKS_TO_TEST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLOCKS_TO_TEST}] ${MODELPARAM_VALUE.BLOCKS_TO_TEST}
}

proc update_MODELPARAM_VALUE.MAX_FAULTS { MODELPARAM_VALUE.MAX_FAULTS PARAM_VALUE.MAX_FAULTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_FAULTS}] ${MODELPARAM_VALUE.MAX_FAULTS}
}

proc update_MODELPARAM_VALUE.UART_MAX_BYTES { MODELPARAM_VALUE.UART_MAX_BYTES PARAM_VALUE.UART_MAX_BYTES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UART_MAX_BYTES}] ${MODELPARAM_VALUE.UART_MAX_BYTES}
}

proc update_MODELPARAM_VALUE.BLOCK_OFFSET { MODELPARAM_VALUE.BLOCK_OFFSET PARAM_VALUE.BLOCK_OFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BLOCK_OFFSET}] ${MODELPARAM_VALUE.BLOCK_OFFSET}
}

