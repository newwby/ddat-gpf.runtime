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
onready var animplr_opening_node: AnimationPlayer = $AnimationPlayer_Opening
# contains all button nodes, use get_children and validate
onready var button_container_node: VBoxContainer =\
		$Main/Left/ButtonMargin/ButtonContainer
# title main button node references
onready var start_game_button_node =\
		$Main/Left/ButtonMargin/ButtonContainer/StartGame
#onready var to_config_menu_button_node =\
#		$Main/Left/ButtonMargin/ButtonContainer/ToConfigMenu
#onready var to_controls_menu_button_node =\
#		$Main/Left/ButtonMargin/ButtonContainer/ToControlsMenu
#onready var to_about_menu_button_node =\
#		$Main/Left/ButtonMargin/ButtonContainer/ToAboutMenu
#onready var exit_game_button_node =\
#		$Main/Left/ButtonMargin/ButtonContainer/ExitGame

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
		# different handling for button focus
		set_all_button_enabled_states(false)
		_is_input_captured = true
		_menu_has_opened_before = true
		animplr_opening_node.play("first_open")
		# afterwards call parent method
		.open_title_menu_window()
		yield(animplr_opening_node, "animation_finished")
		set_all_button_enabled_states(true)
		start_game_button_node.grab_focus()
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


func set_all_button_enabled_states(is_enabled: bool):
	var get_all_button_nodes = button_container_node.get_children()
	for child_node in get_all_button_nodes:
		if child_node is Button:
			child_node.disabled = !is_enabled

