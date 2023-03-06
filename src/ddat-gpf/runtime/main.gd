extends GameStateHandler

#class_name RuntimeMain

############################################a##################################
#
# RuntimeMain is the root handler for the game process.
# It controls all the game handler nodes (Preloading, Title, GameMenu, GameLive, GamePause)
#
#// TODO
# replace match statement in call_new_game_state
#
##############################################################################

# this signal is passed to all game handlers when a new game state happens
# this is usually triggered by a game handler indicating it is done and the
# runtime main parent can choose the next active game handler
signal exit_state()

# for passing to error logging
const SCRIPT_NAME := "RuntimeMain"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true

#08. exported variables

# the current state of the game process (see enum GAME_STATE)
var current_game_state = GAME_STATE.INITIAL setget _set_current_game_state
# the last accepted state of the game process
# defaults to game state initial
var previous_game_state = GAME_STATE.INITIAL

# whilst a valid game state isn't loaded, the runtime main parent captures
# all input and prevents the player from interfacing with the game process
#var is_input_captured := true

# preloader game state can only run once, don't let the game state shift into
# the preloader state a second time or more
var has_preload_finished := false

#10. private variables

# node references to the game handlers
#
onready var game_preloader_main: GameStateHandler = $PreloadingHandler
onready var game_title_main: GameStateHandler = $TitleHandler
onready var game_meta_main: GameStateHandler = $GameMetaHandler
onready var game_exit: GameStateHandler = $ExitHandler

##############################################################################
#
#12. optional built-in virtual _init method
#13. built-in virtual _ready method
#14. remaining built-in virtual methods
#15. public methods
#16. private methods

##############################################################################


# behaviour of preload splash is controlled by setters
func _set_current_game_state(new_game_state):
	# only set the game state if it is a valid value within the GAME_STATE enum
	# w/this (Godot) enum, keys = const string & # values = const int
	if new_game_state in GAME_STATE.values():
		# log changes in game state
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_current_game_state", "attempting gameStateChange to "+\
				"{nstate}".format({\
				"nstate": GAME_STATE.keys()[new_game_state]}))
		
		# block preloader state from happening multiple times
		if new_game_state == GAME_STATE.PRELOAD\
		and has_preload_finished:
			GlobalDebug.log_error(SCRIPT_NAME, "_set_current_game_state",\
					"[gameStatePreload.hasAlreadyCalled]")
			return
		
		# set the new game state, records the last one
		previous_game_state = current_game_state
		current_game_state = new_game_state
		# force any active game handler to exit
		emit_signal("exit_state")
		GlobalDebug.log_success(VERBOSE_LOGGING, SCRIPT_NAME,
				"_set_current_game_state", "calling exitState on gameHandlers")
		
		# cannot call the initial state
		if current_game_state != GAME_STATE.INITIAL:
			# if it isn't the initial state and previous checks passed
			# re-enable input for all, change to new game state
			GlobalInput.is_input_captured.clear_condition(SCRIPT_NAME)
			_call_new_game_state(current_game_state)
		else:
			# if it actually is the initial state, recapture input
			GlobalInput.is_input_captured.set_condition(SCRIPT_NAME, true)
			# but why are we setting initial state after load? shouldn't happen
			GlobalDebug.log_error(SCRIPT_NAME, "_set_current_game_state",\
					"gameState.setInitialState?")
	
	# if not a valid game state, log failure
	else:
		GlobalDebug.log_error(SCRIPT_NAME,
				"_set_current_game_state", "failed gameStateChange")

##############################################################################


# Called when the node enters the scene tree for the first time.
func _ready():
	# on initial load defer to the preloadHandler
	change_game_state(GAME_STATE.PRELOAD)


#func _input(_event):
#	# whilst the preload handler is active, all input will be captured
#	if is_input_captured:
#		get_tree().set_input_as_handled()


##############################################################################


# sets the game state variable, calls the call_game_state method via setter
func change_game_state(new_game_state):
	# setter contains validation for game state no need to do it here
	self.current_game_state = new_game_state
#	GlobalDebug.log_success()


##############################################################################


# this method calls the correct game handler to begin their process
func _call_new_game_state(new_game_state):
	# cannot transition into initial game state
	if new_game_state == GAME_STATE.INITIAL:
		return
	
	#// TODO replace this match statement with get_group(GameStateHandlers)
	# and pass new_game_state arg to validate the gsh's game_handler_id against
	
	match new_game_state:
		GAME_STATE.PRELOAD:
			# sets the activity state and input reception properties of the preloader
			game_preloader_main.call_state()
		GAME_STATE.TITLE:
			game_title_main.call_state()
		GAME_STATE.GAME_META:
			game_meta_main.call_state()
		GAME_STATE.GAME_LIVE:
			pass
		GAME_STATE.GAME_PAUSE:
			pass
		GAME_STATE.EXIT:
			game_exit.call_state()


##############################################################################


# signal recieved from the preloading handler when it is finished with
# its functionality; this should 
func _on_GamePreloadingHandler_preload_is_finished():
	# preload should never run again
	has_preload_finished = true
	# preload always transitions into title
	change_game_state(GAME_STATE.TITLE)

