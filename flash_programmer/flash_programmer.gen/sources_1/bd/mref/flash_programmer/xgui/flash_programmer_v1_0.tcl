# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BLOCKS_TO_TEST" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DELAY_MAX_COUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_COUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_FAULTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_OF_DEVICES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGES_IN_BLOCK" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGE_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.BLOCKS_TO_TEST { PARAM_VALUE.BLOCKS_TO_TEST } {
	# Procedure called to update BLOCKS_TO_TEST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BLOCKS_TO_TEST { PARAM_VALUE.BLOCKS_TO_TEST } {
	# Procedure called to validate BLOCKS_TO_TEST
	return true
}

proc update_PARAM_VALUE.DELAY_MAX_COUNT { PARAM_VALUE.DELAY_MAX_COUNT } {
	# Procedure called to update DELAY_MAX_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_MAX_COUNT { PARAM_VALUE.DELAY_MAX_COUNT } {
	# Procedure called to validate DELAY_MAX_COUNT
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

proc update_PARAM_VALUE.NUM_OF_DEVICES { PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to update NUM_OF_DEVICES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_DEVICES { PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to validate NUM_OF_DEVICES
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


proc update_MODELPARAM_VALUE.MAX_COUNT { MODELPARAM_VALUE.MAX_COUNT PARAM_VALUE.MAX_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_COUNT}] ${MODELPARAM_VALUE.MAX_COUNT}
}

proc update_MODELPARAM_VALUE.DELAY_MAX_COUNT { MODELPARAM_VALUE.DELAY_MAX_COUNT PARAM_VALUE.DELAY_MAX_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_MAX_COUNT}] ${MODELPARAM_VALUE.DELAY_MAX_COUNT}
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

proc update_MODELPARAM_VALUE.NUM_OF_DEVICES { MODELPARAM_VALUE.NUM_OF_DEVICES PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_DEVICES}] ${MODELPARAM_VALUE.NUM_OF_DEVICES}
}

proc update_MODELPARAM_VALUE.MAX_FAULTS { MODELPARAM_VALUE.MAX_FAULTS PARAM_VALUE.MAX_FAULTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_FAULTS}] ${MODELPARAM_VALUE.MAX_FAULTS}
}

