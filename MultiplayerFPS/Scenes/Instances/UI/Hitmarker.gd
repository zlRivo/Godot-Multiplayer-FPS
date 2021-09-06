extends TextureRect

onready var animation_player = $AnimationPlayer

func play():
	if animation_player.is_playing():
		animation_player.seek(0.0)
	animation_player.play("fadeout", -1, 1.0)
