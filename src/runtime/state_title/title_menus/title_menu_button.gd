extends Button

# This is a slightly modified version of the 3.0 (rev 5f5a9378)  style guide
# Changes are documented below with <- indicators
# https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
#
#01. tool
#02. extends <- switched with class_name (originally 02.)
#03. class_name <- switched with extends (originally 03.)
#
##############################################################################
#
#04a. dependencies <- new addition
#
#04b. # docstring
#
##############################################################################
#
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#
#05. signals

# when the main window passes control to a different window, the clicked
# button passes its name as a string arg to use for a nodepath when the window
# returns, so it can refocus the button
signal main_window_last_focused_button(my_name)

# see _on_titleMenuButton_pressed for why deprecated
#signal button_pressed_start()
#signal button_pressed_options()
#signal button_pressed_about()
#signal button_pressed_exit()

#06. enums

#// TODO deprecate, is redundant with new signal approach (assigned in-editor
# via inspector) for getting buttons to do stuff
enum TITLE_BUTTONS {START, CONFIG, CONTROLS, ABOUT, EXIT, RETURN}

#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "script_name"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true
#
#08. exported variables

export(TITLE_BUTTONS) var my_title_button_id

#09. public variables
#10. private variables
#11. onready variables
#
##############################################################################
#
#12. optional built-in virtual _init method
#13. built-in virtual _ready method
#14. remaining built-in virtual methods
#15. public methods
#16. private methods

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_TitleMenuButton_mouse_entered():
	pass # Replace with function body.


func _on_TitleMenuButton_focus_entered():
	pass # Replace with function body.


func _on_TitleMenuButton_pressed():
	GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
			"_on_TitleMenuButton_pressed",
			"node = {node}, name = {name}, id = {id}".format({
				"node": str(self),
				"name": self.name,
				"id": TITLE_BUTTONS.keys()[my_title_button_id],
			}))
	# pass button name as arg for last focused button
	emit_signal("main_window_last_focused_button", self.name)
#	
	# with local children can do this via signal directly instead of
	# propagating signals through the main menu
#	if title_button_arg in TITLE_BUTTONS:
#		match title_button_arg:
#			TITLE_BUTTONS.START:
#				pass
#			TITLE_BUTTONS.OPTIONS:
#				pass
#			TITLE_BUTTONS.ABOUT:
#				pass
#			TITLE_BUTTONS.EXIT:
#				pass
