extends Armed

func _ready():
	weapon_type = WEAPON_TYPES.SNIPER_RIFLE
	animation_player = $AnimationPlayer
	animation_player.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished(anim_name):
	._on_animation_finished(anim_name)
