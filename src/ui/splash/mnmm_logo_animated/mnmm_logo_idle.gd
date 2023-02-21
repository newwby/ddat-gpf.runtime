extends Node2D

#class_name MNMM_Logo_Animated_Idle

##############################################################################
#
# MNMM_Logo_Animated_Idle contains methods for controlling the animation
# players of this scene from another node
#
#// TODO - many of these animation call methods are identical, they could
# probably be combined in a single function
#
##############################################################################

signal transition_animation_completed()
signal exit_animation_completed()
signal fade_animation_completed()

# validation doesn't have autocomplete so use a stringRef for all instances
# of the animation so it's harder for dev to forget to change the validation
# if the animation name changes
# for transition/logo moving animation
const TRANSITION_ANIMATION_STRING := "move_logo_down"
# for transition/logo moving animation
const EXIT_ANIMATION_STRING := "fly_logo_up"
# for obscure/fade-out animation
const FADE_ANIMATION_STRING := "fade_out"

# different presets for playback speed of the idle ('wobble') animation
const IDLE_ANIMATION_PLAYBACK_SPEED_FOREGROUND := 0.5
const IDLE_ANIMATION_PLAYBACK_SPEED_BACKGROUND := 0.1

# export controls the speed of the wobbling idle animation
export(float, 0.0, 0.5)var logo_idle_animation_play_speed: float = 0.5\
		setget _set_logo_idle_animation_play_speed

# node references for animation players
#
onready var animplr_idle_node: AnimationPlayer = $AnimationIdle
onready var animplr_transition_node: AnimationPlayer = $AnimationTransition
onready var animplr_fade_node: AnimationPlayer = $AnimationFade

##############################################################################


func _set_logo_idle_animation_play_speed(value):
	logo_idle_animation_play_speed = value
	# adjust playback speed of the animation player
	animplr_idle_node.playback_speed = logo_idle_animation_play_speed


##############################################################################


# force setter on ready to control idle animation
func _ready():
	self.logo_idle_animation_play_speed = logo_idle_animation_play_speed


# call animation for logo to fly up from bottom to center of screen
func play_transition_animation_up():
	# don't call if already animating
	if animplr_transition_node.is_playing():
		return
	animplr_transition_node.play_backwards(TRANSITION_ANIMATION_STRING)


# call anim for logo to move from center of screen to off-screen bottom edge
func play_transition_animation_down():
	# don't call if already animating
	if animplr_transition_node.is_playing():
		return
	animplr_transition_node.play(TRANSITION_ANIMATION_STRING)


# call animation for logo to fly up from bottom to center of screen
func play_exit_animation_up():
	# don't call if already animating
	if animplr_transition_node.is_playing():
		return
	animplr_transition_node.play(EXIT_ANIMATION_STRING)


# call anim for logo to move from center of screen to off-screen bottom edge
func play_exit_animation_down():
	# don't call if already animating
	if animplr_transition_node.is_playing():
		return
	animplr_transition_node.play_backwards(EXIT_ANIMATION_STRING)


# call anim for MNMM_LogoAnimatedIdle to fade out
# flame particle trail fades out much faster, leaving just shield logo
# sets playback speed of wobble animation as it starts
func play_fade_animation_out():
	# don't call if already animating
	if animplr_fade_node.is_playing():
		return
	animplr_fade_node.play(FADE_ANIMATION_STRING)
	# set playback speed to slowed
	self.logo_idle_animation_play_speed =\
			IDLE_ANIMATION_PLAYBACK_SPEED_BACKGROUND


# reverse the fade animation to bring the animated logo back in to play
# sets playback speed of wobble animation as it starts
func play_fade_animation_in():
	# don't call if already animating
	if animplr_fade_node.is_playing():
		return
	animplr_fade_node.play_backwards(FADE_ANIMATION_STRING)
	# set playback speed to default
	self.logo_idle_animation_play_speed =\
			IDLE_ANIMATION_PLAYBACK_SPEED_FOREGROUND


##############################################################################


# let other nodes know when transition animation finishes
func _on_AnimationTransition_animation_finished(anim_name):
	# validate is correct animation
	if anim_name == TRANSITION_ANIMATION_STRING:
		emit_signal("transition_animation_completed")
	elif anim_name == EXIT_ANIMATION_STRING:
		emit_signal("exit_animation_completed")


func _on_AnimationFade_animation_finished(anim_name):
	# validate is correct animation
	if anim_name == FADE_ANIMATION_STRING:
		emit_signal("fade_animation_completed")

