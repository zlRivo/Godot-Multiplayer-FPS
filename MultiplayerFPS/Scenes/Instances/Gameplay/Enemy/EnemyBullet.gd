extends KinematicBody

var bullet_speed = 10000
var move_vec = Vector3.ZERO
var sender_of_bullet = null
var damage = 30

func _process(delta):
	move_and_slide(move_vec.normalized() * bullet_speed * delta)

func _on_Area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(sender_of_bullet, damage)
	queue_free()
