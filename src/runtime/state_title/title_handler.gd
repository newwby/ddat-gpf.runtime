extends GameStateHandler

#class_name GameStateTitleHandler

##############################################################################
#
# GameStateTitleHandler
#
##############################################################################

#05. signals

#signal start_animation_window_change()

#06. enums

# identifiers for the menu children of the titleMenuHolder
enum TITLE_WINDOW_STATE {NONE, MAIN, CONFIG, CONTROLS, ABOUT}

#07. constants

# for passing to error logging
const SCRIPT_NAME := "GameStateTitleHandler"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

#08. exported variables
#9. public variables

# active title window can only be set to a value in enum TITLE_WINDOW
# tracks the open window/who is in control
# defaults to NONE (the stateHandler or animation node is in control)
var active_title_window_state = TITLE_WINDOW_STATE.NONE\
		setget _set_active_title_window_state

# setting controls whether the title menu is active
var _is_title_menu_active := false setget _set_is_title_menu_active

#10. private variables

# when side wipe animation gets to midpoint it checks this and sets the
# active window state with that value using a change_window_state() method
var _upcoming_window_state = null setget _set_upcoming_window_state

#11. onready variables

# node references for the main control children of the GameStateTitleHandler
#
#// deprecate?
# warning-ignore:unused_class_variable
onready var root_node: Control =\
		$TitleMenuCanvas/Root

# node references for animation managers and players
#
onready var canvas_fade_anim_node: AnimationPlayer =\
		$TitleMenuCanvas/Root/CanvasFadeAnim
# these are independent scenes, modify these to add your own animations
# start them with the call_animation method (already in code)
# they return on the 'animation_finished' signal
onready var anim_mgr_intro = $IntroAnimMgr
onready var anim_mgr_menu_transition = $MenuTransitionAnimMgr
onready var anim_mgr_exit = $ExitAnimMgr

# parent to (and thus can hide) all title menus
# deprecated direct node visibility ref, use _toggle_canvas_visibility instead
#onready var menu_holder_node = $TitleMenuCanvas/Root/MenuHolder

# node references for the individual title menu nodes
#
onready var title_menu_node_main =\
		$TitleMenuCanvas/Root/MenuHolder/MenuTitleMain
# warning-ignore:unused_class_variable
onready var title_menu_node_config =\
		$TitleMenuCanvas/Root/MenuHolder/MenuConfigurationOptions
# warning-ignore:unused_class_variable
onready var title_menu_node_controls =\
		$TitleMenuCanvas/Root/MenuHolder/MenuControlOptions
# warning-ignore:unused_class_variable
onready var title_menu_node_about =\
		$TitleMenuCanvas/Root/MenuHolder/MenuAboutInfo

##############################################################################

# setters/getters


# title menu is hidden or shown based on activity state
func _set_is_title_menu_active(new_title_active_state: bool):
	# log title window state changes
	_is_title_menu_active = new_title_active_state
	GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
			"_set_is_title_menu_active",
			"title menu handler active state set to {st}".format({
			"st": new_title_active_state}))


# active title window can only be set to a value in enum TITLE_WINDOW
# else will remain unchanged
func _set_active_title_window_state(value):
	if active_title_window_state in TITLE_WINDOW_STATE.values():
		active_title_window_state = value
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_active_title_window_state",
				"new active_title_window_state is {var}".format({
					"var" : active_title_window_state
				}))


# whenever upcoming window state is set via transition_to_menu method()
# start the animation for window change
func _set_upcoming_window_state(new_state):
	if new_state in TITLE_WINDOW_STATE.values():
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_upcoming_window_state",
				"state from state {prev} to state {new}".format({
					"prev": _upcoming_window_state,
					"new" : new_state
				}))
		_upcoming_window_state = new_state
	_animation_window_change_start()


##############################################################################

# public methods


# main method for changing active menu call this to start changing window
# transition_to_menu -> self._upcoming_window_state -> _animation_window_change
# _animation_window_change_start -> _animation_window_change_midpoint
# midpoint -> _change_window_state -> TitleMenuWindow.open_title_menu_window
func transition_to_menu(new_title_menu_window, skip_animation: bool = false):
	#// update with animation
	#// window state change 
	if new_title_menu_window in TITLE_WINDOW_STATE.values():
		if not skip_animation:
			self._upcoming_window_state = new_title_menu_window
		else:
			change_window_state(new_title_menu_window)
	else:
		GlobalDebug.log_error(SCRIPT_NAME, "transition_to_menu",
				"new_title_menu_window not in TITLE_WINDOW_STATE")


# used as part of the side wipe animation when the transition_to_menu
# method is called, or can forcibly change open window without animation if
# using the force_state_change arg
func change_window_state(force_state_change = null):
	# get the new window node via matching state to TITLE_WINDOW_STATE.values
	# new_window depends on if overriding state arg
	var get_new_menu_window_node
	# overriding behaviour
	if force_state_change != null\
	and force_state_change in TITLE_WINDOW_STATE.values():
		get_new_menu_window_node =\
				_get_menu_window_node(force_state_change)
		active_title_window_state =  force_state_change
	# normal behaviour
	else:
		if _upcoming_window_state == null and force_state_change ==  null:
			GlobalDebug.log_error(SCRIPT_NAME,
					"_change_window_state",
					"_upcoming_window_state == null")
			return
		get_new_menu_window_node =\
				_get_menu_window_node(_upcoming_window_state)
		active_title_window_state = _upcoming_window_state
		_upcoming_window_state = null
	
	# once we have a menu window node we call the open method on it
	if get_new_menu_window_node != null:
		if get_new_menu_window_node is TitleMenuWindow:
			get_new_menu_window_node.open_title_menu_window()


# if passed arg is_start_game as true will call game meta state (start playing)
# if passed arg is_start_game as false will call exit state (exit game process)
func exit_title_state_handler(is_start_game: bool):
	# if true we call gameStateGameMeta
	if is_start_game:
		# block input for a moment
		GlobalInput.is_input_captured.set_condition(\
				SCRIPT_NAME+"_on_anim_exit", true)
		
		# ADD EXIT ANIMATION BEHAVIOUR HERE
		anim_mgr_exit.call_animation()
	
	# if false we call gameStateExit
	elif not is_start_game:
		emit_signal("change_state", GAME_STATE.EXIT)


##############################################################################

# private methods


# shadows the parent class method
func _call_state_initial():
	print("test hi")
	_animation_introduction_start()


# shadows the parent class method
func _call_state_routine():
	self._is_title_menu_active = true
	# force change without animation
	transition_to_menu(TITLE_WINDOW_STATE.MAIN, true)


# get node reference by key to TITLE_WINDOW_STATE enum
func _get_menu_window_node(window_state):
	var menu_window_node
	match window_state:
		# do nothing on null
		TITLE_WINDOW_STATE.NONE:
			menu_window_node = null
		# else get the noderef
		TITLE_WINDOW_STATE.MAIN:
			# open default window
			menu_window_node = title_menu_node_main
		TITLE_WINDOW_STATE.CONFIG:
			# open options window
			menu_window_node = title_menu_node_config
		TITLE_WINDOW_STATE.CONTROLS:
			# open options window
			menu_window_node = title_menu_node_controls
		TITLE_WINDOW_STATE.ABOUT:
			# open credits window
			menu_window_node = title_menu_node_about
	return menu_window_node


func _toggle_canvas_visibility(new_visibility_state: bool):
	# 'root' node modulation controls modulation of all child nodes
	#// replace with canvas_modulate node?
#	root_node.visible = new_visibility_state
	# play fading animation
	if new_visibility_state:
		canvas_fade_anim_node.play("fade_in")
	else:
		canvas_fade_anim_node.play_backwards("fade_in")


##############################################################################

# private animation methods


func _animation_introduction_start():
	GlobalInput.is_input_captured.set_condition(SCRIPT_NAME+"_on_anim_1", true)
	anim_mgr_intro.call_animation()


# this is called by setting self._upcoming_window_state via
# transition_to_menu() method
func _animation_window_change_start():
	GlobalInput.is_input_captured.set_condition(SCRIPT_NAME+"_on_anim_2", true)
#	emit_signal("start_animation_window_change", reverse_anim)
	anim_mgr_menu_transition.call_animation()


##############################################################################

# signal receipt methods



func _on_intro_anim_mgr_animation_finished():
	GlobalInput.is_input_captured.clear_condition(SCRIPT_NAME+"_on_anim_1")
#	change_window_state(TITLE_WINDOW_STATE.MAIN)
	_toggle_canvas_visibility(true)
	call_state()


func _on_menu_transition_anim_mgr_animation_finished():
	change_window_state()
	GlobalInput.is_input_captured.clear_condition(SCRIPT_NAME+"_on_anim_2")


func _on_exit_anim_mgr_animation_finished():
			# hide title buttons
			_toggle_canvas_visibility(false)
			# restore input control
			GlobalInput.is_input_captured.clear_condition(\
					SCRIPT_NAME+"_on_anim_exit")
			emit_signal("change_state", GAME_STATE.GAME_META)

