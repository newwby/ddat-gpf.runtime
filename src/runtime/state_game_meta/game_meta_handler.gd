extends GameStateHandler

#class_name GameStateGameMetaHandler

##############################################################################
#
# GameStateGameMetaHandler
#
#//TODO
# - update initial state flag on return to title
#
##############################################################################

#05. signals

signal open_game_file_dialog()

# warning-ignore:unused_class_variable
# add this file
export(PackedScene) var game_file

#06. enums

#//REVIEW - should GameStateHandlers be called GameStateHandlers? should the
# GameLive, GameMeta, and GamePause states be named as such? It has led to
# derived classes such as GameStateGameMeta which is a mouthful.
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "GameStateGameMetaHandler"
# for developer use, enable if making changes
const VERBOSE_LOGGING := true
#
#08. exported variables
#09. public variables
#10. private variables
#11. onready variables

onready var loading_placeholder_node = $InterfaceCanvas/LoadingPlaceholder

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
#	call_state()


##############################################################################


#//TODO - make sure if returning to title and unloading the game the game
# meta states 'called once' flag is unset
# first time the game meta state is called, open the game file dialog
func _call_state_initial():
	# call progress file handling or skip over the step
	if GlobalProgression.OPTION_ENABLE_GAME_FILE_MANAGER:
		emit_signal("open_game_file_dialog")
	else:
		_load_initial_game_scene()


func _load_initial_game_scene():
	if game_file is PackedScene:
		loading_placeholder_node.visible = true
		var new_game_scene = game_file.instance()
		call_deferred("add_child", new_game_scene)
		yield(new_game_scene, "ready")
		loading_placeholder_node.visible = false
	else:
		GlobalDebug.log_error(SCRIPT_NAME, "_load_initial_game_scene",
				"game scene not ready")
