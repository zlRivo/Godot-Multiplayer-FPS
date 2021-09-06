extends Area

func _ready():
	$AnimationPlayer.play("pickup")

func _on_AmmoPickup_body_entered(body):
	if body.is_in_group("Player"):
		var result = body.weapon_manager.add_ammo()
		
		if result:
			queue_free()
