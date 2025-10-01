# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "MAX_RETRIES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_OF_DEVICES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PAGE_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.MAX_RETRIES { PARAM_VALUE.MAX_RETRIES } {
	# Procedure called to update MAX_RETRIES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_RETRIES { PARAM_VALUE.MAX_RETRIES } {
	# Procedure called to validate MAX_RETRIES
	return true
}

proc update_PARAM_VALUE.NUM_OF_DEVICES { PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to update NUM_OF_DEVICES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OF_DEVICES { PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to validate NUM_OF_DEVICES
	return true
}

proc update_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to update PAGE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PAGE_SIZE { PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to validate PAGE_SIZE
	return true
}


proc update_MODELPARAM_VALUE.PAGE_SIZE { MODELPARAM_VALUE.PAGE_SIZE PARAM_VALUE.PAGE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PAGE_SIZE}] ${MODELPARAM_VALUE.PAGE_SIZE}
}

proc update_MODELPARAM_VALUE.NUM_OF_DEVICES { MODELPARAM_VALUE.NUM_OF_DEVICES PARAM_VALUE.NUM_OF_DEVICES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OF_DEVICES}] ${MODELPARAM_VALUE.NUM_OF_DEVICES}
}

proc update_MODELPARAM_VALUE.MAX_RETRIES { MODELPARAM_VALUE.MAX_RETRIES PARAM_VALUE.MAX_RETRIES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_RETRIES}] ${MODELPARAM_VALUE.MAX_RETRIES}
}

