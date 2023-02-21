extends Node2D

# class_name LogoAnimatedSideWipe

##############################################################################
#
# LogoAnimatedSideWipe
#
##############################################################################

# triggered at the midpoint of the 'right to left' animation, when the splash
# logo texture is occupying the entire screen and the menu controls beneath can
# be changed without the player seeing the change
# warning-ignore:unused_signal
signal AnimationMidpoint()
# at end
signal AnimationComplete()

#// TODO add sound effect for side wipe, maximum duration 1.2s

#06. enums
#
#07. constants
# for passing to error logging
const SCRIPT_NAME := "LogoAnimatedSideWipe"
# for developer use, enable if making changes
#const VERBOSE_LOGGING := true

# for validation
const ANIM_STRING := "right_to_left"

#
#08. exported variables
#09. public variables

#10. private variables

var _anim_is_playing := false

#11. onready variables

onready var anim_plr_side_wipe = $AnimationSideWipe

##############################################################################


func _on_title_state_handler_animation_start(anim_reversed: bool = false):
	if not _anim_is_playing:
		_anim_is_playing = true
		if not anim_reversed:
			anim_plr_side_wipe.play("right_to_left")
		elif anim_reversed:
			anim_plr_side_wipe.play_backwards("right_to_left")


func _on_anim_wipe_animation_finished(anim_name):
	_anim_is_playing = false
	if anim_name == ANIM_STRING:
		emit_signal("AnimationComplete")
	else:
		GlobalDebug.log_error(SCRIPT_NAME,
				"_on_anim_wipe_animation_finished",
				"incorrect anim name")

