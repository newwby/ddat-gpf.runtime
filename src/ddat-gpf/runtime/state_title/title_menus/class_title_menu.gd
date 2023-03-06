extends GameMenuWindow

class_name TitleMenuWindow

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
# TitleMenuWindow
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

const CLASS_VERBOSE_LOGGING := true
const CLASS_SCRIPT_NAME := "TitleMenuWindow"

const TITLE_MENU_WINDOW_GROUP_STRING := "is_title_menu_window"

#
#08. exported variables

export(bool) var is_active_title_menu := false setget _set_is_active_title_menu

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

# setget

# control visibility state (and therefore button response) by activity state
func _set_is_active_title_menu(arg_value):
	is_active_title_menu = arg_value
	self.visible = is_active_title_menu
	if arg_value == true:
		_window_opened()


##############################################################################

#13. built-in virtual _ready method


# Called when the node enters the scene tree for the first time.
func _ready():
	# all windows have setters on init to disable themselves
	# force setter
	# don't 
#	self.is_active_title_menu = false
	self.is_active_title_menu = is_active_title_menu
	# add to group for menu open/close behaviour
	self.add_to_group(TITLE_MENU_WINDOW_GROUP_STRING)


##############################################################################

#15. public methods


func open_title_menu_window():
	# close any leftover active title menus
	get_tree().call_group(
			TITLE_MENU_WINDOW_GROUP_STRING,
			"close_title_menu_window", self)
	# self is the only active title menu
	self.is_active_title_menu = true
	GlobalDebug.log_success(CLASS_VERBOSE_LOGGING, CLASS_SCRIPT_NAME,
			"open_title_menu_window",
			" {id} opening".format({
				"id": str(self)+": "+name
			}))


func close_title_menu_window(new_active_window: Control):
	if is_active_title_menu and new_active_window != self:
		self.is_active_title_menu = false


##############################################################################

#16. private methods


# called whenever this window is opened, shadow method in extended classes
func _window_opened():
	pass

