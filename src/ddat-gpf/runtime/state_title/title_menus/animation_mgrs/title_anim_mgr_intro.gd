extends Control

# manages animations for the titleStateHandler
# modify this node if you wish to add animations

# return to regular behaviour
signal animation_finished()

onready var animation_player = $AnimationPlayer

##############################################################################


# Called when the node enters the scene tree for the first time.
func call_animation():
	animation_player.play("placeholder")
	yield(animation_player, "animation_finished")
	# this is a placeholder so just emit return signal immediately
	emit_signal("animation_finished")
