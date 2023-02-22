extends GameStateHandler

#class_name GameExitStateHandler
#
##############################################################################
#
# GameExitStateHandler
#
##############################################################################
#
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#
#05. signals
#06. enums
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "GameExitStateHandler"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true
#
#08. exported variables
#09. public variables
#10. private variables
#11. onready variables

##############################################################################


# shadowing
func call_state():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

