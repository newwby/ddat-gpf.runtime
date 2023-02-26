extends GameGlobal

#class_name GlobalProgression

##############################################################################
#
# GlobalProgression is a singleton to track the game state.
# Part of the runtime framework, it is largely called by the GameMeta,
# GameLive, and GamePause, states.
#

#//TODO
# move fileLoader behaviour for loading save file to a method here
# add save method with optional arg to unload the save file if doing so
# move quit game behaviour to here, so files can be safely saved on exit
# add autosave timer and method to adjust interval (integrate w/globalConfig)

##############################################################################

#05. signals
# signal emitted whenever the all_game_files array is updated after a new
# globalProgressFile is recorded
signal new_game_file_recorded()

#06. enums
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "GlobalProgression"
# for developer use, enable if making changes
# verbose_logging exists in a parent class
#const VERBOSE_LOGGING := true

# if set, and the GameProgressFile has the property 'total_playtime', the
# globalProgression singleton will auto-instantiate a timer node and use it
# to update the second count value of the total playtime property.
const TRACK_TOTAL_PLAY_TIME := true

var total_play_time_tracker: Timer

#
#08. exported variables
#09. public variables

# used to create save file elements inside gameMeta.gameFileDialog
var all_game_files := []

# the active save file loaded
# should be unloaded when game meta transitions out
# warning-ignore:unused_class_variable
var loaded_save_file: GameProgressFile setget _set_loaded_save_file

#10. private variables
#11. onready variables

##############################################################################

# setget

# start the playtime tracker if it has been instantiated
func _set_loaded_save_file(arg_value):
	loaded_save_file = arg_value
	if total_play_time_tracker != null:
		total_play_time_tracker.stop()
		if loaded_save_file != null:
			total_play_time_tracker.start()


##############################################################################

# virt

func _ready():
	_initiate_playtime_tracker()


##############################################################################

# public


#//UNFIN, REMOVE
#//TODO move this to a global function (core?)
#func check_property_in_class(arg_class, arg_property: String):
#	if arg_class.has_met


##############################################################################

# private


# method that instantiates save files
# returns the created file on success or null on failure
func _create_game_file():
	# new save files record their time of creation
	var new_save_file = GameProgressFile.new()
	
	var save_id := 1
	var does_save_id_exist := true
	var base_save_path =\
			GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.GAME_SAVE]
	var save_file_name = "save"+str(save_id)+".tres"
	# save files are recorded as 'save' with an integer id, i.e. 'save1'
	# until an unused save id is found, iterate through potential save ids
	while does_save_id_exist == true:
		does_save_id_exist = GlobalData.validate_file(\
				base_save_path+save_file_name)
		# if already exists, increment the id and attempted path
		if does_save_id_exist == true:
			save_id += 1
			save_file_name = "save"+str(save_id)+".tres"
		#//TODO add maximum iteration exit condition
	
	# the path should not exist to exit the above loop
	if does_save_id_exist == false:
		if GlobalData.save_resource(\
				base_save_path,	save_file_name,	new_save_file) == OK:
			# if save operation successful
			all_game_files.append(new_save_file)
			emit_signal("new_game_file_recorded")
#			print("save recorded at {p}".format({"p": save_file_name}))
			return new_save_file
	# catchall exit condition, assumes failure
	return null


func _increment_playtime_tracker():
	if loaded_save_file != null:
#		print("test1")
		loaded_save_file.total_playtime += 1
#		loaded_save_file.total_pl(1)
#		print(loaded_save_file.total_playtime)
#		print(loaded_save_file.save_file_element_info)


func _initiate_playtime_tracker():
	var class_to_check = GameProgressFile.new()
	var property_to_check = "total_playtime"
	if property_to_check in class_to_check\
	and TRACK_TOTAL_PLAY_TIME:
		total_play_time_tracker = Timer.new()
		self.call_deferred("add_child", total_play_time_tracker)
		total_play_time_tracker.autostart = false
		total_play_time_tracker.one_shot = false
		if total_play_time_tracker.connect(\
				"timeout", self, "_increment_playtime_tracker") != OK:
			GlobalDebug.log_error(SCRIPT_NAME, "_initiate_playtime_tracker",
					"total playtime tracker not setup correctly")

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

