extends GameGlobal

#class_name GlobalProgression

##############################################################################
#
# GlobalProgression is a singleton to track the game state.
# Part of the runtime framework, it is largely called by the GameMeta,
# GameLive, and GamePause, states.
#
##############################################################################

#05. signals
#06. enums
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "GlobalProgression"
# for developer use, enable if making changes
# verbose_logging exists in a parent class
#const VERBOSE_LOGGING := true
#
#08. exported variables
#09. public variables

# used to create save file elements inside gameMeta.gameFileDialog
var all_game_files := []

# the active save file loaded
# should be unloaded when game meta transitions out
# warning-ignore:unused_class_variable
var loaded_save_file: GameProgressFile

#10. private variables
#11. onready variables

##############################################################################


# shadowing a parent class method
# this preload method loads from disk every save file it can find in the
# user://saves/ folder, looking for files named save1.tres, save2.tres, etc.
# successfully loaded files are added to the _all_game_files array to later
# be used by the gameFileDialog scene (part of the gameMeta state)
func _preload():
#	._preload()
	# path to save location
	var get_save_path: String =\
			GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.GAME_SAVE]

	var game_saves = []
	# file names must begin with 'save' and not include 'backup'
	game_saves = GlobalData.load_resources_in_directory(
		get_save_path,
		"save",
		"",
		["backup"]
	)
	all_game_files.append_array(game_saves)


##############################################################################

