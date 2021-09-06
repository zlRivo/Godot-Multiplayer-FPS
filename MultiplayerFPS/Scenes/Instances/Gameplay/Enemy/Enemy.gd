extends KinematicBody

# References
export(NodePath) var detection_area_path
export(NodePath) var detection_shape_path
export(NodePath) var ground_check_path

onready var detection_area = get_node(detection_area_path)
onready var detection_shape = get_node(detection_shape_path)
onready var ground_check = get_node(ground_check_path)

var bullet_scene = preload("res://Scenes/Instances/Gameplay/Enemy/EnemyBullet.tscn")

var gravity_vec = Vector3.ZERO
var gravity = 6000

var bodies_in_detection_area = null

var target = null

export var health = 1000

var turn_speed = 1000

onready var hand = $Head/Hand
onready var eyes = $Eyes

var current_shoot_time = 0.0
var shoot_timer = 1.0

# Stores all the bodies within the detection area
var bodies = []

func _ready():
	pass

func set_detection_range(distance):
	if detection_shape != null:
		detection_shape.radius = distance
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()

func _physics_process(delta):
	process_gravity(delta)
	process_movement(delta)
	
func process_gravity(delta):
	var full_contact = ground_check.is_colliding()
	
	# Gravity
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
	else:
		gravity_vec = -get_floor_normal()
		
	# Reset Y velocity if the player hits the ceiling
	if is_on_ceiling():
		gravity_vec.y = 0

func process_movement(delta):
	move_and_slide(gravity_vec, Vector3.UP)

func _process(delta):
	if target != null:
		var theta = atan2(global_transform.origin.x - target.global_transform.origin.x, global_transform.origin.z - target.global_transform.origin.z)
		rotation = Vector3(0, theta, 0)
		hand.look_at(target.global_transform.origin, Vector3.UP)
		
		# Increment shoot timer
		current_shoot_time += delta
		
		if current_shoot_time >= shoot_timer:
			shoot_bullet()
			current_shoot_time = 0.0
	else:
		pass

func shoot_bullet():
	# Create a bullet
	var bullet = bullet_scene.instance()
	bullet.global_transform = hand.global_transform
	bullet.move_vec = -hand.global_transform.basis.z.normalized()
	bullet.sender_of_bullet = self
	get_parent().add_child(bullet)

func _on_DetectionArea_body_entered(body):
	bodies.append(body)
	update_target()

func _on_DetectionArea_body_exited(body):
	bodies.erase(body)
	update_target()

func update_target():
	# Check if there is a player within the bodies
	for b in bodies:
		if b.is_in_group("Player"):
			# Assign target
			target = b
			return
	
	# No target found
	target = null
	
	# Reset shot time
	current_shoot_time = 0.0
