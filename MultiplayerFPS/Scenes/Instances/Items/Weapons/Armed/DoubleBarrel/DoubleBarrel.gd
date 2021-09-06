extends Armed

export var knockback_force = 10000

func _ready():
	animation_player = $AnimationPlayer
	animation_player.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)

func fire_bullet():
	# Call parent function
	.fire_bullet()
	
	# Apply knockback to the player
	player.apply_knockback(knockback_force)
