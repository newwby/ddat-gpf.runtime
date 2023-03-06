extends Node

class_name GameStateHandler

##############################################################################
#
# GameStateHandlers are the major directors of the game. There are multiple,
# each responsible for controlling how the player can and cannot interface
# with the game. They are directed by a unique gameStateHandler called
# 'runtimeMain', their parent in the scene tree.
#
##############################################################################
#
# signals

# warning-ignore:unused_signal
signal change_state(new_state)

# enums

# The game's state controls which nodes are allowed to act, and which
# gameStateHandler node is directing the game.
#
# GAME_STATE.INITIAL
# This is the default state, before any stateHandlers are loaded or active.
# This is when autoloads and resources are being loaded, and the initial
# scene tree is being loaded; as soon as runtimeMain loads we transition
# out of this state permanently and into the preload state.
#
# Initial -> Preload
#
# GAME_STATE.PRELOAD
# During preload the preloadingHandler controls the game. An animated splash
# screen overlay is shown and additional background loading (such as building
# audio nodes or building scenes/databases from on-disk resources) happens.
# This is the first state in which the user (briefly) has input control.
# After Preload finishes the Title state gains control.
#
# Preload -> Title
#
# GAME_STATE.TITLE
# The TitleStateHandler controls which of the title menus is currently
# active and in-focus; it is a state machine of its own smaller state tree.
# This is an honourary 'true game state', where the player has full input
# control and can affect the game. It is not the game proper, but it is
# adjacent. From this point the player may start a new game, load a previous
# game, configure game options, view game credits, or exit entirely.
# 
# Title -> Game_Meta
# Title -> Exit
#
# GAME_STATE.GAME_META
# GameMeta is the first of the three 'true game states', the states which are
# actually what most players would consider gameplay. This is the campaign or
# strategical menu where the player may interface with the story and the
# metaprogress that affects the live gameplay. From this state the player is
# inside their save file and can choose to transition to live gameplay or
# exiting back to the title screen or desktop if they wish.
#
# Game_Meta -> Game_Live
# Game_Meta -> Title
# Game_Meta -> Exit
#
# GAME_STATE.GAME_LIVE
# One of the 'true game states', and the most important. GameLive is where
# gameplay, 'a game run', actually happens. From this state the player may
# suspend the game to transition into the GamePause state but 
#
# Game_Live -> Game_Pause
#
# GAME_STATE.GAME_PAUSE
# The last of the 'true game states', GamePause is the state in which a game
# run is active but the player has chosen to suspend gameplay and is presented
# with the game pause menu. From the pause menu the player may adjust options,
# or completely exit their run/the game.
#
# Game_Pause -> Game_Meta
# Game_Pause -> Game_Live
# Game_Pause -> Exit
#
# GAME_STATE.EXIT
# This is the last game state, at which runtimeMain calls the exit process.
# The exit state cannot transition to any other state, once it begins the
# game application will close.

enum GAME_STATE {\
		INITIAL,
		PRELOAD,
		TITLE,
		GAME_META,
		GAME_LIVE,
		GAME_PAUSE,
		EXIT}

# consts

const GROUP_STRING_GAME_STATE_HANDLER := "is_game_state_handler"

# exported vars

# set this in-editor on gameHandler scenes
# warning-ignore:unused_class_variable
export(GAME_STATE) var _game_handler_id = GAME_STATE.INITIAL

# private vars

# whether to route to the initial or routine call_state method
var _state_called_once_before := false

# whether the gameStateHandler is the active state; the setter for this method
# will call all other gameStateHandlers and unset their active state property
# the call_state method will flip this bool to true
# devs: use this flag to prevent state behaviour
var _is_active_game_state := false setget _set_is_active_game_state

##############################################################################

# setters


# whenever a gameStateHandler is called via their call_state method, their
# _is_active_game_state property is set and the _is_active_game_state property
# of all other gameStateHandlers (determined by node group; i.e. only handlers
# currently in the scene tree) is unset.
func _set_is_active_game_state(new_state_value):
	_is_active_game_state = new_state_value
	# if we're setting a state to true,
	# we need to unset any active gameStateHandler
	if _is_active_game_state == true:
		var get_all_game_state_handlers =\
				get_tree().get_nodes_in_group(GROUP_STRING_GAME_STATE_HANDLER)
		for handler_node in get_all_game_state_handlers:
			# every other gameStateHandler that isn't self, unset them
			if handler_node != self\
			and "_is_active_game_state" in handler_node:
				if handler_node._is_active_game_state == true:
					handler_node._is_active_game_state = false
	# finally
	if _is_active_game_state == false:
		_end_of_state()


##############################################################################

# virtual ready method


func _ready():
	self.add_to_group(GROUP_STRING_GAME_STATE_HANDLER)


##############################################################################

# public methods


# directs the actual state call to the correct method
func call_state():
	self._is_active_game_state = true
	if _state_called_once_before:
		_call_state_routine()
	else:
		_state_called_once_before = true
		_call_state_initial()


##############################################################################

# private methods


# shadow this method in the StateHandlers properly and add behaviour.
# do not call this unless shadowed
# if state has not been called before, call_state method diverts here.
func _call_state_initial():
	GlobalDebug.log_error(
		"GameStateHandler {id}".format({"id": str(self)}),
		"_call_state_initial",
		"a gameStateHandler called the class method mistakenly. "+\
		"dev, please shadow method in the extended node")


# shadow this method in the StateHandlers properly and add behaviour.
# do not call this unless shadowed
# if state has been called before, call_state method diverts here.
func _call_state_routine():
	GlobalDebug.log_error(
		"GameStateHandler {id}".format({"id": str(self)}),
		"_call_state_routine",
		"a gameStateHandler called the class method mistakenly. "+\
		"dev, please shadow method in the extended node")


# this empty (optional) method is called whenever the _is_active_game_state
# is unset, e.g. because a new state has been called.
# this method is for behaviour that needs to happen whenever a state is unset
# or unloaded, not for behaviour that forces transition to a new state.
# shadow this method in the StateHandlers properly and add behaviour.
func _end_of_state():
	pass

