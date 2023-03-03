extends GameGlobal

#const VERBOSE_LOGGING = true

var config_settings_dict = {}

var resolution_by_index = {
	0 : Vector2(1024, 576),
	1 : Vector2(1280, 720),
	2 : Vector2(1366, 768),
	3 : Vector2(1600, 900),
	4 : Vector2(1920, 1080),
	5 : Vector2(2560, 1440),
}

var index_by_resolution = {
	Vector2(1024, 576) : 0,
	Vector2(1280, 720) : 1,
	Vector2(1366, 768) : 2,
	Vector2(1600, 900) : 3,
	Vector2(1920, 1080) : 4,
	Vector2(2560, 1440) : 5,
}


func _ready():
	update_game_config()


func update_game_config():
	#// TODO replace with globalDebug call (see other points in doc)
	if verbose_logging:
		print("global_config calling update_game_config()")
	#// TODO - config setting loading is broken
#	if GlobalData.validate_file_path(GlobalRef.CONFIGURATION_SETTINGS_USER):
#		if verbose_logging:
#			print("getting globalRef.configSettings USER on update_game_config")
#		config_settings_dict = GlobalData.open_and_return_file_json_str_as_dict(GlobalRef.CONFIGURATION_SETTINGS_USER)
#	else:
#		if verbose_logging:
#			print("getting globalRef.configSettings DEFAULT on update_game_config")
#		config_settings_dict = GlobalData.open_and_return_file_json_str_as_dict(GlobalRef.CONFIGURATION_SETTINGS_DEFAULT)


func update_game_window():
	if verbose_logging:
		print("global_config calling update_game_window()")
		if config_settings_dict is Dictionary:
#			config_settings_dict.has()
			if config_settings_dict.has("resolution_index"):
				set_current_resolution_by_index(config_settings_dict["resolution_index"])
			else:
				set_current_resolution_by_index(get_current_resolution_index())


func set_current_resolution_by_index(given_index):
	if verbose_logging:
		print("global_config calling set_current_resolution_by_index()"+\
		" with given_index ", given_index)
	var get_res = resolution_by_index[int(given_index)]
	ProjectSettings.set_setting("display/window/size/width", get_res.x)
	ProjectSettings.set_setting("display/window/size/height", get_res.y)
	OS.window_size = get_res


func get_current_resolution_index():
	if verbose_logging:
		print("global_config calling get_current_resolution_index()")
	var current_resolution = OS.window_size
	
	if current_resolution.x >= 2560\
	or current_resolution.y >= 1440:
		return index_by_resolution[Vector2(2560, 1440)]
	
	elif current_resolution.x >= 1920\
	or current_resolution.y >= 1080:
		return index_by_resolution[Vector2(1920, 1080)]
	
	elif current_resolution.x >= 1600\
	or current_resolution.y >= 900:
		return index_by_resolution[Vector2(1600, 900)]
	
	elif current_resolution.x >= 1366\
	or current_resolution.y >= 768:
		return index_by_resolution[Vector2(1366, 768)]
	
	elif current_resolution.x >= 1280\
	or current_resolution.y >= 820:
		return index_by_resolution[Vector2(1280, 720)]
	
	else:
		return index_by_resolution[Vector2(1024, 576)]


