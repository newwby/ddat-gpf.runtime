extends TitleMenuWindow

#class_name TitleMenuWindowMain

#
##############################################################################
#
# TitleMenuMain controls animation on opening the menu, and passes button
# pressed information to the gameTitleMenuStateHandler
#
##############################################################################
#
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#
#05. signals

signal title_main_menu_ready()

#06. enums
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "TitleMain"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

#
#08. exported variables
#09. public variables

#10. private variables

var _menu_has_opened_before := false
var _is_input_captured := false

var last_focused_button = "StartGame"

#11. onready variables
# node references
#
onready var animplr_opening_node: AnimationPlayer = $AnimationPlayer_Opening
onready var button_container_node: VBoxContainer =\
		$Main/Left/ButtonMargin/ButtonContainer

##############################################################################


#func _ready():
#	open_title_menu_window()


# input is captured if animation is playing
#// REVIEW - some kind of singleton conditional class for input capturing,
# as am using a lot of different is_input_captured vars atm
func _input(_event):
	if _is_input_captured:
		get_tree().set_input_as_handled()


# shadows method
func open_title_menu_window():
	# if first time opening (i.e. after preloader) play animation to load
	if not _menu_has_opened_before:
		_is_input_captured = true
		_menu_has_opened_before = true
		animplr_opening_node.play("first_open")
	# skip animation if not first time (i.e. returning from submenu)
	else:
		emit_signal("title_main_menu_ready")
	
	# focus into the last clicked or focused button
	var get_last_focused_button =\
			button_container_node.get_node_or_null(last_focused_button)
	if get_last_focused_button != null:
		if get_last_focused_button is Button:
			get_last_focused_button.grab_focus()
	else:
		GlobalDebug.log_error(SCRIPT_NAME, "open_title_menu_window",
				"no last focused button found")
	
	# afterwards call parent method
	.open_title_menu_window()


# on animation conclusion
func open_animation_finished(_anim_name: String):
	_is_input_captured = false
	emit_signal("title_main_menu_ready")


func update_last_focused_button(node_name: String):
#	print("updating last focused button with ", node_name)
	last_focused_button = node_name

