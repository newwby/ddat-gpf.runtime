extends GameGlobal

#class_name GlobalInput

##############################################################################
#
# GlobalInput
#
# DEPENDENCIES
# GlobalData
# GlobalDebug

# GlobalInputManager
# This is designed as an autoload singleton
# Functionality includes:
#	*) automatic export of project input map to disk
#	*) configuration of project input map (at runtime) from .tres on disk
#	*) creation of compound action extensions from inputMap actions
#	*) functionality of compound action extensions (input variance)
#	*) handling of alternate inputs per action and alternate platforms

#// TODO
# modify _export_project_input_map_to_disk into save/load universal?
# modify _export_project_input_map_to_disk vars to cast/infer or just static type

# extendedInputMap should have action -> compoundActionExtension references
# compoundActionExtensions should be stored in action folders
# can you recursively save resources?
# can't use groups on non-nodes so how to organise compoundActionExtensions?
#
##############################################################################


#05. signals
#06. enums

#07. constants

# for test environment
const TEMP_DATA_PATH = "res://pkg_input_manager/def/input_actions/"
# manual load instead of using project autoloader
# temporary remove on framework export
#const GLOBAL_DATA_PATH = "res://pkg_input_manager/src/singleton/global_data.gd"

#08. exported variables

#09. public variables

# for global input blocking
#//REVIEW - this is being called on every input event (below) - too much?
var is_input_captured: Conditional = Conditional.new(false)

#10. private variables

#11. onready variables

#onready var GlobalData = preload(GLOBAL_DATA_PATH).new()


##############################################################################

# virtual ready method


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


##############################################################################

# virtual methods


# Called on any input event
func _input(_event):
	# if any condition key has been set true, globalInput will block all input
	if is_input_captured.get_outcome() == true:
		get_tree().set_input_as_handled()


###############################################################################

# private methods


#// rework prints to globalDebug statements

# takes the project InputMap and saves each inputEventAction as a .tres
# resource file within the designation definition folder
func _export_project_input_map_to_disk():
	# temporary whilst autloader isn't present
#	var GlobalData = preload(GLOBAL_DATA_PATH).new()
	# base file path building variables
	var base_directory_path = TEMP_DATA_PATH
	var directory_path
	var file_path
	var save_path_extension = ".tres"
	# refs for properties of input actions, converted to string for file path
	var action_identifier
	var input_event_action_list
	var event_index
	var event_class
	
#	var extended_input_map := {}
	
	# gets the inputActions
	for input_map_action in InputMap.get_actions():
		# store action info into extended input map, set up array for next step
#		extended_input_map[input_map_action] = {}
		# store some info for file path later
		action_identifier = str(input_map_action)
		input_event_action_list = InputMap.get_action_list(input_map_action)
		
		# gets the inputEventActions
		for input_event in input_event_action_list:
			# store some info for file path later
			event_class = str(input_event.get_class())
			event_index = str(input_event_action_list.find(input_event))
			# input event resources are stored in a folder named after the
			# corresponding action, located in the base directory
			# file name equals class name and index in the action list array
			directory_path = action_identifier+"/"
			file_path =\
					event_index+"_"+event_class+save_path_extension
#					action_identifier+"_"+event_index+save_path_extension

#			# store event info into extended input map
#			# the value of the dict at the action's key SHOULD be an array
#			if typeof(extended_input_map[input_map_action]) == TYPE_DICTIONARY:
#				extended_input_map[input_map_action]["file_path"] =\
#						directory_path
			
			if GlobalData.validate_directory(\
					base_directory_path+directory_path, true):
				# if directory found or created, save resource
				# file name is 'IndexPosition_inputActionClass.tres'
				if ResourceSaver.save(\
						base_directory_path+directory_path+file_path,\
						input_event) != OK:
					
					# if not saved then error print to debug
					if OS.is_debug_build():
						print_debug(get_stack())
					else:
						# can't get stack if release build
						print("_export_project_input_map_to_disk error")
			else:
				print_debug(get_stack())
			print(base_directory_path+directory_path+file_path)

