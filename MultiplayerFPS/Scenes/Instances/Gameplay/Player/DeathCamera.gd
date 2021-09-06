extends Spatial

var mouse_sensitivity = 0
var MIN_CAMERA_ANGLE = 0
var MAX_CAMERA_ANGLE = 0
var camera_speed = 5

onready var camera = $Camera
var killer_body = null

var cam_position = Vector3.ZERO
var cam_rotation = Vector3.ZERO

func initialize_death_camera(killer, pos, rot, mouse_sens, min_cam_angle, max_cam_angle):
	cam_position = pos
	cam_rotation = rot
	mouse_sensitivity = mouse_sens
	MIN_CAMERA_ANGLE = min_cam_angle
	MAX_CAMERA_ANGLE = max_cam_angle
	killer_body = killer
	
func _enter_tree():
	global_transform.origin = cam_position
	rotation.x = cam_rotation.x
	rotation.y = cam_rotation.y

func _process(delta):
	if killer_body != null:
		var t = global_transform.looking_at(killer_body.global_transform.origin, Vector3(0,1,0))
		global_transform.basis.y = lerp(global_transform.basis.y, t.basis.y, delta * camera_speed)
		global_transform.basis.x = lerp(global_transform.basis.x, t.basis.x, delta * camera_speed)
		global_transform.basis.z = lerp(global_transform.basis.z, t.basis.z, delta * camera_speed)

func destroy():
	queue_free()
