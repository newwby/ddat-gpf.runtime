extends GameStateHandler

#class_name GameStatePreloadHandler

##############################################################################
#
# PreloadHandler is (currently) now mostly a splash screen that plays whilst
# things are loading, but it has space in the logic flow to handle things
# such as loading data after tree load (when the tree is idle)
#
##############################################################################

# for passing to error logging
const SCRIPT_NAME := "GameStatePreloadHandler"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

# setting controls whether the preload handler is active
# caution: setting this active sets input to be captured
var is_preload_active := false setget _set_is_preload_active

# whether input is ignored or processed by the preload handler
# this value is set true when the 'press any key' animation is active
var is_input_accepted := false setget _set_is_input_accepted

# references to control nodes in the scene tree
#
# loading control container needs to be hidden/shown as part of loadbar anim
onready var loading_controls_container_node: VBoxContainer =\
		$PreloadCanvas/Root/Margin/VBoxContainer/BottomUpperMid/LoadingControlsContainer
# loading label node needs to be modified as part of loadbar anim
onready var loading_label_node: Label =\
		$PreloadCanvas/Root/Margin/VBoxContainer/BottomUpperMid/LoadingControlsContainer/LoadingText
# loading bar node needs to be modified as part of loadbar anim
onready var loading_bar_node: ProgressBar =\
		$PreloadCanvas/Root/Margin/VBoxContainer/BottomUpperMid/LoadingControlsContainer/LoadingBar
# show any key label node needs to be modified as part of press any key anim
onready var show_any_key_label_node: Label =\
		$PreloadCanvas/Root/Margin/VBoxContainer/BottomUpperMid/BottomLowerMid/InputHint

# references to animation player nodes in the scene tree
#
# animation for the preload splash fading in and out
onready var animplr_splash_control_node: AnimationPlayer =\
		$AnimationPlayer_Visibility
# animation for the press any key label fade-modulation
onready var animplr_press_any_node: AnimationPlayer =\
		$AnimationPlayer_InputHint
# animation for the loading bar progressing
onready var animplr_loading_node: AnimationPlayer =\
		$AnimationPlayer_LoadProgress


##############################################################################


# behaviour of preload splash is controlled by setters
func _set_is_preload_active(value: bool):
	is_preload_active = value
	# call related animation methods to show or hide the preload splash
	# show
	if is_preload_active:
		# block input whilst preload is active
		GlobalInput.is_input_captured.set_condition(SCRIPT_NAME, true)
		# run startup animation
		_call_animation_preload_splash(true)
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_is_preload_active", "preloadSplashAnimation.open")
	# hide
	elif not is_preload_active:
		# allow input again whilst preload is inactive
		GlobalInput.is_input_captured.clear_condition(SCRIPT_NAME)
		# run exit animation
		_call_animation_preload_splash(false)
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_is_preload_active", "preloadSplashAnimation.close")


# behaviour of preload splash is controlled by setters
func _set_is_input_accepted(value: bool):
	is_input_accepted = value
	
	# auto call related animation methods
	# if input is accepted then the 'press any key' label is visibly flashing
	# if not, then it is hidden
	if is_input_accepted:
		_call_animation_press_any_key(true)
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_is_input_accepted", "pressAnyKeyAnimation.Activated")
	elif not is_input_accepted:
		_call_animation_press_any_key(false)
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_is_input_accepted", "pressAnyKeyAnimation.Deactivated")


##############################################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	# logging readying of this node as it is one of the earliest nodes (after
	# singletons/autoloads) to be added to the scene tree, so its presence
	# lets the developer know that initial engine loading went as planned.
	GlobalDebug.log_success(VERBOSE_LOGGING, "main_preload", "_ready", "start")

	#// DEPRECATED, GlobalConfig.update_game_window() method does the same
#	# set the resolution
#	GlobalConfig.set_current_resolution_by_index(\
#			GlobalConfig.get_current_resolution_index())

	#// TODO move this to GlobalConfig
	# force game window resolution by the registered resolution index
	GlobalConfig.update_game_window()
	
	# as initial log statement at method start
	GlobalDebug.log_success(VERBOSE_LOGGING, "main_preload", "_ready", "end")


##############################################################################


# until input is accepted, the preload splash will override everything
# input is accepted once the preload behaviour has finished and the 'press
# any key' animation is playing
func _input(event):
	# wait for prompt to press input
	if is_preload_active and is_input_accepted:
		# event must be a button press (keyboard, mouse, or joypad)
		# mouse motion and joypad thumbstick movement are not accepted
		if event is InputEventKey\
		or event is InputEventMouseButton\
		or event is InputEventJoypadButton:
			_exit_preload_handler()


##############################################################################

# public methods


# override the parent call state since this state is only called once
func call_state():
	if _state_called_once_before:
		GlobalDebug.log_error(SCRIPT_NAME, "call_state",
				"preloader being called multiple times")
		return
	_state_called_once_before = true
	# progress to normal behaviour
	# set animation controlling variables to their default start values
	# additionally calls setters to force animation behaviour
	self.is_preload_active = true
	self.is_input_accepted = false


##############################################################################

# private methods


# method called when input is recieved to close the preload handler
# (after preload finished, press any key animation is active, and key pressed)
# passes control back to runtimeMain
func _exit_preload_handler():
	# don't force an end state if we're already not active, it'll cause bugs
	# runtimeMain will query this whenever any game state ends so it is
	# important to validate the handler isn't active before continuing
	if is_preload_active:
		# set animation controlling variables to their default end values
		# additionally calls setters to force animation behaviour
		self.is_preload_active = false
		self.is_input_accepted = false
		# send signal back to runtimeMain that it should pass control to title
		emit_signal("change_state", GAME_STATE.TITLE)
		# logging
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"game_preloader_end", "complete")
	
	# removed due to excessive error pushing by runtimeMain calls to exit state
	#// REVIEW is runtimeMain calling exitState on all game handlers necessary?
#	else:
#		GlobalDebug.log_error(SCRIPT_NAME,
#				"game_preloader_end", "CalledWhilstInactive")


##############################################################################

# private methods for animation handling


# method for toggling the show/hide animation for the preload splash
func _call_animation_preload_splash(show_splash: bool):
	# at active state, show the preload splash screen
	if show_splash:
		animplr_splash_control_node.play("anim_show_preload_splash")
		_call_animation_loading_bar(true)
	# on closing, hide the preload splash screen
	else:
		animplr_splash_control_node.play("anim_fade_preload_splash")


# method to show the animated label indicating the player should press a key
func _call_animation_press_any_key(toggle_animation_on: bool):
	if toggle_animation_on:
		_call_animation_loading_bar(false)
		show_any_key_label_node.visible = true
		show_any_key_label_node.self_modulate.a = 1.0
		animplr_press_any_node.play("anim_input_hint")
	else:
		show_any_key_label_node.visible = false
		show_any_key_label_node.self_modulate.a = 1.0
		animplr_press_any_node.stop()


# method to toggle whether to start or end the loading bar animation
func _call_animation_loading_bar(loading_started: bool):
	# begin loading bar animation & control loading bar/label container
	if loading_started:
		# these property changes are hardcoded as the animation is a loop
		# and we don't want them repeating at the start of every anim loop
		# could write a separate animation to start, but this works
		loading_controls_container_node.modulate.a = 1.0
		loading_bar_node.value = 0
		loading_label_node.percent_visible = 0
		loading_label_node.text = "LOADING!"
		animplr_loading_node.play("anim_loading_increment")
		loading_controls_container_node.visible = true
	# convert loading bar animation to 'finished' state
	else:
		loading_bar_node.value = 100
		loading_label_node.percent_visible = 1.0
		loading_label_node.text = "LOADED"
		animplr_loading_node.play("anim_fade_loading_controls")
		loading_controls_container_node.visible = false


# fake animation method to give the illusion something is loading
# called by animation player for loading label
func _animation_method_increment_loading_bar_fake():
	var get_bar_value = loading_bar_node.value
	# sometimes doesn't increment
	var get_bar_max = loading_bar_node.max_value
	var load_chance = rand_range(0, get_bar_max-1.0)
	
#	print("load chance = {a} | target range = {b}-{c}".format(\
#	{"a":str(load_chance), "b":"0", "c":str(get_bar_max-1.0)}))
	
	if load_chance <= get_bar_value:
		return
	else:
		loading_bar_node.value += 1


##############################################################################

# signal receipt methods

# called from the $AnimationPlayer_SplashControl (default name)
# from the animation_finished(arg) signal
func _on_open_preload_splash_finished(anim_name: String):
	if anim_name == "anim_show_preload_splash":
		# show the animation for press any key label, re-enable input
		self.is_input_accepted = true
	# handling for calling this method mistakenly or calibrating incorrectly
#	elif not anim_name in ["show_preload_splash", "close_preload_splash"]:
#		print("_on_open_preload_splash_finished finished {anim_name}".format(\
#		{"anim_name":anim_name}))
#		GlobalDebug.log_error(SCRIPT_NAME, "_on_open_preload_splash_finished")


#// DEPRECATED, handled by gameStateHandler class now
## runtimeMain shuts down all game handlers whenever a game state changes
## exit methods inside game handlers should include activity state validation
## to prevent an exit method being called on an inactive game handler
#func _on_RuntimeMain_exit_state():
#		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
#				"_on_RuntimeMain_exit_state", "signal.exitState.recieved")
#		_exit_preload_handler()

