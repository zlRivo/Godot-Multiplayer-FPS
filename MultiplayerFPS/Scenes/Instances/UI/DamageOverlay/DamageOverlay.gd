extends TextureRect

onready var animation_player = $AnimationPlayer

func show():
	visible = true
	
func hide():
	visible = false

func play():
	if animation_player.is_playing():
		animation_player.seek(0)
	animation_player.play("show")
