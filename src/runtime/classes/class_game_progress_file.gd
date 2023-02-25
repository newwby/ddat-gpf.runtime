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

export var total_playtime := 0 setget _set_total_playtime

#//TODO, store the timezone when creating file and reference it whenever
# changing the modified date so created date/modified date can be adjusted
#export var file_timezone: Dictionary

# track of date and time file was created on
export var timestamp_created: Dictionary setget _set_timestamp_created
# when file was last opened or saved
export var timestamp_modified: Dictionary setget _set_timestamp_modified

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
func _set_total_playtime(arg_value: int):
	total_playtime = arg_value
	save_file_element_info["Total Playtime"] =\
			_convert_seconds_to_time_string(total_playtime)


func _set_timestamp_created(arg_value: Dictionary):
	timestamp_created = arg_value
	save_file_element_info["File Created On"] =\
			_convert_datetime_dict_to_save_info(timestamp_created)


func _set_timestamp_modified(arg_value: Dictionary):
	timestamp_modified = arg_value
	save_file_element_info["Last Played"] =\
			_convert_datetime_dict_to_save_info(timestamp_modified)


# when reading the total playtime value it returns a formatted string instead
func _convert_seconds_to_time_string(arg_seconds: int):
	var playtime_seconds: int = arg_seconds
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


func _convert_datetime_dict_to_save_info(datetime_dict: Dictionary) -> String:
	var file_datetime_info = ""
	var file_datetime_day = ""
	var file_datetime_month = ""
	var file_datetime_year = ""
	
	if "day" in datetime_dict.keys():
		file_datetime_day = str(datetime_dict["day"])
		# get last digit to determine the suffix
		var day_suffix = ""
		var last_digit = str(file_datetime_day)[-1]
		if last_digit == "3":
			day_suffix = "rd"
		elif last_digit == "2":
			day_suffix = "nd"
		elif last_digit == "1":
			day_suffix = "st"
		else:
			day_suffix = "th"
		file_datetime_day += day_suffix
	
	if "month" in datetime_dict.keys():
		file_datetime_month = datetime_dict["month"]
		if typeof(file_datetime_month) == TYPE_INT:
			if file_datetime_month in range(1, 12):
				match file_datetime_month:
					1:
						file_datetime_month = "January"
					2:
						file_datetime_month = "February"
					3:
						file_datetime_month = "March"
					4:
						file_datetime_month = "April"
					5:
						file_datetime_month = "May"
					6:
						file_datetime_month = "June"
					7:
						file_datetime_month = "July"
					8:
						file_datetime_month = "August"
					9:
						file_datetime_month = "September"
					10:
						file_datetime_month = "October"
					11:
						file_datetime_month = "November"
					12:
						file_datetime_month = "December"
	
	if "year" in datetime_dict.keys():
		file_datetime_year = str(datetime_dict["year"])
	
	# type convert to catch exceptions
	file_datetime_info =\
			str(file_datetime_day)+" "+\
			str(file_datetime_month)+" "+\
			str(file_datetime_year)
	
	return file_datetime_info


##############################################################################

# virt


func _init():
#	file_timezone = Time.get_time_zone_from_system()
#	Time.get_offset_string_from_offset_minutes()
	self.timestamp_created = Time.get_datetime_dict_from_system()
	self.timestamp_modified = timestamp_created


##############################################################################

# public

#//REMOVED
## because the getter interferes with setting it externally
#func increment_playtime(arg_increment: int):
#	total_playtime += arg_increment
#	print(total_playtime)
#	print(save_file_element_info["Total Playtime"])


# method to recieve data
#func load_game():
#	pass


# method to commit data
#func save_game():
#	pass


##############################################################################

##

