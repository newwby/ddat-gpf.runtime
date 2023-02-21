extends Resource

class_name GameProgressFile

##############################################################################
#
# Template game file for saving game progress.
# Developers should extend this class to include information about their
# game that needs to be recorded so that in the next game instance it can
# be loaded again.
#
# DEPENDENCIES:
# DDAT_Prototyping_Framework.DDAT_Core
# DDAT_Prototyping_Framework.DDAT_Runtime
#
# DEV WARNING: Do not change the file path address of this class file after
# saving resources to disk under this class, else you will incur a
# referenced nonexistent resource error (unless you wish to manually edit the
# [ext_resource=] path on each .tres file.
#
##############################################################################

# warning-ignore:unused_class_variable
#var game_file_creation_date

export var total_playtime := 0 setget _set_total_playtime, _get_total_playtime

# the key/value pairs of this dict are shown on the save file element when
# loading/saving the game. Both the key and value are displayed on the file
# info, so use readable strings when adding new key/value pairs.
# You can use setters on other properties to automatically update this db.
# warning-ignore:unused_class_variable
export var save_file_element_info = {
	"Total Playtime" : "0 hours, 0 minutes, 0 seconds",
	"File Created On" : "14th January 2023",
	"Last Played" : "14th January 2023",
}

##############################################################################

# setters and getters


# when updating total playtime value, set the corresponding dict value
func _set_total_playtime(value: int):
	total_playtime = value
	save_file_element_info["Total Playtime"] = self.total_playtime


# when reading the total playtime value it returns a formatted string instead
func _get_total_playtime():
	var playtime_seconds: int = total_playtime
	var playtime_minutes: int = 0
	var playtime_hours: int = 0
	
	while playtime_seconds >= 60:
		playtime_seconds -= 60
		playtime_minutes += 1
	
	while playtime_minutes >= 60:
		playtime_minutes -= 60
		playtime_hours += 1
	
	var time_string: String = "{h} hours, {m} minutes, {s} seconds".format({
		"h": playtime_hours,
		"m": playtime_minutes,
		"s": playtime_seconds
	})
	return time_string


##############################################################################


# method to recieve data
#func load_game():
#	pass


# method to commit data
#func save_game():
#	pass

##

