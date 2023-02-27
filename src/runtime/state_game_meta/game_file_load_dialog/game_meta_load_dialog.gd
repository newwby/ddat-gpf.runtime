extends CenterContainer

# class_name GameFileLoadDialog

##############################################################################
#
# GameFileLoadDialog
# ui scene that works with globalProgression singleton to load a game file
# so devs can store data across play sessions
#
##############################################################################

signal begin_game_load()

# for logging
const SCRIPT_NAME := "GameMetaFileLoadDialog"
const VERBOSE_LOGGING := true

const GROUPSTRING_SAVE_FILE_ELEMENTS := "group_save_file_elements"

var listed_save_file_elements := 0

# when a file is flagged for deletion the save file element is stored briefly
var file_delete_request: SaveFileElement

# node references
#
onready var popup_animator: AnimationPlayer = $Panel/PopupAnimator
#
# save file info node refs
onready var save_file_container_node: VBoxContainer =\
		$Panel/Margin/ScrollContainer/SaveFileContainer
onready var save_file_element_scene_default: MarginContainer =\
		$Panel/Margin/ScrollContainer/SaveFileContainer/SaveFileElement
onready var new_save_file_button_node =\
		$Panel/Margin/ScrollContainer/SaveFileContainer/NewSaveFile
# file deletion confirm popup node refs
onready var file_delete_confirmation_popup_node = $FileDeleteConfirmationPopup
onready var file_delete_popup_cancel_button_node =\
		$FileDeleteConfirmationPopup/Margin/VBox/ButtonContainer/Cancel


##############################################################################

# virt


#func _ready():
#	var new_save = GameProgressFile.new()
#	_create_new_save_resource(new_save)


##############################################################################

# private methods)


#//DERPECATED as functionality is replicated in globalProgression
#//(see GlobalProgression.create_game_file)
#func _create_new_save_resource(arg_new_save: GameProgressFile):
#	#//TODO add get date created (and add date modified to resaving)
#	#TODO remove this test line
#	arg_new_save.total_playtime = 50
#
#	var save_id := 1
#	var does_save_id_exist := true
#	var save_path =\
#			GlobalData.DATA_PATHS[GlobalData.DATA_PATH_PREFIXES.GAME_SAVE]
#	while does_save_id_exist == true:
#		does_save_id_exist =\
#				GlobalData.validate_file(
#					save_path+"save"+str(save_id)+".tres"
#				)
#		if does_save_id_exist == true:
#			save_id += 1
#
#	if does_save_id_exist == false:
#		if GlobalData.save_resource(
#			save_path,
#			"save"+str(save_id)+".tres",
#			arg_new_save
#		) == OK:
#			print("new save recorded at {path}".format({
#				"path": save_path+"save"+str(save_id)+".tres"
#			}))
#		assert(typeof(GlobalProgression.all_game_files) == TYPE_ARRAY)
#		GlobalProgression.all_game_files.append(arg_new_save)


# arg_save_file is the GameProgressFile used to load the player's save state
# (GameProgressFiles track general game progression stats)
# arg_save_id is the id given to the game_meta_load_dialog's save file label
func _create_new_save_file_element(arg_save_file: GameProgressFile):
	listed_save_file_elements += 1
	var new_save_file_element = save_file_element_scene_default.duplicate()
	save_file_container_node.call_deferred("add_child", new_save_file_element)
	# connect confirm button
	new_save_file_element.connect("save_file_chosen", self, "_on_save_file_chosen")
	# ready for delete popup functionality
	new_save_file_element.add_to_group(GROUPSTRING_SAVE_FILE_ELEMENTS)
	if new_save_file_element is SaveFileElement:
		if new_save_file_element.connect("delete_button_pressed",\
				self, "_on_save_file_delete_request") != OK:
					GlobalDebug.log_error(SCRIPT_NAME,
							"_create_new_save_file_element",
							"save file element delete did not find load dialog")
	# sort info from save progress file
	new_save_file_element.init_save_file_element(
			arg_save_file,
			listed_save_file_elements)


##############################################################################

# signal receipt methods


func _on_game_meta_open_game_file_dialog():
	popup_animator.play_backwards("panel_fly_out")
	# should return arg "panel_fly_out"
	yield(popup_animator, "animation_finished")
	# if there aren't any game files, do nowt
	if GlobalProgression.all_game_files.empty():
		return
	
	# otherwise get the files and add new save file elements
	for save_file in GlobalProgression.all_game_files:
		if save_file is GameProgressFile:
			_create_new_save_file_element(save_file)
	
	new_save_file_button_node.grab_focus()
#	new_save_file_button_node.grab_click_focus()


# method to create new save files
# should check the iterant (see globalProgression._preload) and find the next
# unused number, then create the save file there
func _on_game_file_dialog_start_new_save_file():
	var new_save = GlobalProgression.create_game_file()
	if new_save != null:
		_create_new_save_file_element(new_save)
	else:
		GlobalDebug.log_error(SCRIPT_NAME,
				"_on_game_file_dialog_start_new_save_file",
				"new save file was not created correctly")


# play animation to close the fileLoadDialog then call the gameMeta parent
# and tell it to start the game proper
func _on_save_file_chosen():
	popup_animator.play("panel_fly_out")
	# should return arg "panel_fly_out"
	yield(popup_animator, "animation_finished")
	emit_signal("begin_game_load")


func _on_save_file_delete_request(arg_save_file_element_ref: SaveFileElement):
	pass
#	arg_save_file_element_ref.my_progress_file.file_path
	file_delete_request = arg_save_file_element_ref
	_disable_load_dialog_buttons(true)
	file_delete_confirmation_popup_node.popup()
	file_delete_popup_cancel_button_node.grab_focus()

func _delete_save_file():
	# block all user input whilst the file deletion process starts
	GlobalInput.is_input_captured.set_condition(SCRIPT_NAME, true)
	
#	arg_save_file_element_ref.my
	#//TODO migrate this block to ddat-gpf.core.globalData
#	var get_file_path = my_progress_file.file_path
	
	GlobalInput.is_input_captured.clear_condition(SCRIPT_NAME)


func _disable_load_dialog_buttons(is_disabled: bool = true):
	var save_file_elements =\
			get_tree().get_nodes_in_group(GROUPSTRING_SAVE_FILE_ELEMENTS)
	for file_element_node in save_file_elements:
		if file_element_node is SaveFileElement:
			file_element_node.disable_buttons(is_disabled)
	if new_save_file_button_node != null:
		new_save_file_button_node.disabled = is_disabled


func _close_delete_file_popup():
	file_delete_confirmation_popup_node.visible = false
	# clear request
	file_delete_request = null
	_disable_load_dialog_buttons(false)


func _on_delete_file_popup_confirm_pressed():
	_delete_save_file()
	_close_delete_file_popup()


func _on_delete_file_popup_cancel_pressed():
	_close_delete_file_popup()

