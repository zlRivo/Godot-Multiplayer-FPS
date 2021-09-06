extends KinematicBody

var default_mouse_sensitivity = 0.1
var mouse_sensitivity = default_mouse_sensitivity

# Movement speed
var default_speed = 2000
# Movement acceleration
var h_acceleration = 100

var sprinting = false

# Gravity
var gravity = 6000

# Jump
var jump = 2400

var full_contact = false

# Direction
var direction = Vector3.ZERO
# Acceleration vector
var h_velocity = Vector3.ZERO

var gravity_vec = Vector3.ZERO

var movement = Vector3.ZERO

onready var head = $Head
onready var ground_check = $GroundCheck
onready var pickup_reach = $Head/Camera/PickupRay
onready var hand = $Head/Hand
onready var weapon_manager = $Head/Hand
onready var camera = $Head/Camera
onready var weapon_camera = $ViewportContainer/Viewport/WeaponCamera
onready var hud = $HUD
onready var pause_menu = $PauseMenu
onready var respawn_timer = $RespawnTimer

onready var collision_shape = $CollisionShape
onready var foot = $Foot

const MIN_CAMERA_ANGLE = -89
const MAX_CAMERA_ANGLE = 89

# Variable tracking the time elapsed with the recoil
var recoil_time = 0

# FOV while sprinting
var sprinting_fov = 90
var sprinting_fov_transition = 10

# Current recoil vector
var current_recoil_vector = Vector2.ZERO
# Current recoil duration
var current_recoil_duration = 1

# Save default fov for adsing
onready var default_fov = camera.fov

var max_health = 100
onready var health = max_health

var can_take_damage = true

signal respawn

# Stop everything the player is doing
var disabled = false

var death_camera_scene = preload("res://Scenes/Instances/Gameplay/Player/DeathCamera.tscn")

var glock_scene = preload("res://Scenes/Instances/Items/Weapons/Armed/Glock/Glock.tscn")
var double_barrel_scene = preload("res://Scenes/Instances/Items/Weapons/Armed/DoubleBarrel/DoubleBarrel.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		# If not in pause menu
		if pause_menu.get_pause_state() == false and not disabled:
			rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
			head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			
			head.rotation.x = clamp(head.rotation.x, deg2rad(MIN_CAMERA_ANGLE), deg2rad(MAX_CAMERA_ANGLE))
		
func _physics_process(delta):
	
	process_ui_inputs()
	if not disabled:
		direction = Vector3.ZERO
		
		process_gravity(delta)
		if pause_menu.get_pause_state() == false:
			process_weapon_inputs(delta)
		apply_recoil(delta)
		
		process_weapon_movement(delta)
		if pause_menu.get_pause_state() == false:
			process_movement_inputs(delta)
		process_movement(delta)

func jump():
	gravity_vec.y = jump

func die(killer):
	# Stop adsing
	if weapon_manager.current_weapon != null and weapon_manager.current_weapon.name != "UNARMED":
		weapon_manager.current_weapon.aim_down_sights(false, 0)
	
	# Create a death camera
	var death_cam = death_camera_scene.instance()
	# Initialize it
	death_cam.initialize_death_camera(
		killer,
		head.global_transform.origin,
		Vector3(head.rotation.x, rotation.y, 0),
		mouse_sensitivity,
		MIN_CAMERA_ANGLE,
		MAX_CAMERA_ANGLE
	)
	# Connect respawn signal on destroy function on the death cam
	connect("respawn", death_cam, "destroy")
	# Spawn the camera
	get_parent().add_child(death_cam)
	# Make it active
	death_cam.camera.current = true
	
	# Disable player
	disable()
	
	weapon_manager.drop_all_weapons()
	respawn_timer.start()

func disable():
	disabled = true
	
	# Hide player
	visible = false
	
	# Hide HUD
	hud.visible = false
	
	# Disable collisions
	collision_shape.disabled = true
	foot.disabled = true
	
func enable():
	disabled = false
	
	# Show player
	visible = true
	
	# Show HUD
	hud.visible = true
	
	# Enable collisions
	collision_shape.disabled = false
	foot.disabled = false

func _on_RespawnTimer_timeout():
	respawn()

func respawn():
	# Enable back player
	enable()
	
	camera.current = true
	set_health(max_health)
	global_transform.origin = Vector3(0, 2, 0)
	
	# Fire respawn signal
	emit_signal("respawn")

func set_health(value):
	health = clamp(value, 0, max_health)
	hud.update_health(health)
	
func take_damage(sender, amount):
	if not disabled:
		set_health(health - amount)
		hud.damage_overlay.play()
		if health <= 0:
			die(sender)

func process_ui_inputs():
	if Input.is_action_just_pressed("pause"):
		if pause_menu.get_pause_state() == false:
			pause_menu.set_pause_state(true)
		else:
			pause_menu.set_pause_state(false)

func process_movement_inputs(delta):
	# Jump
	if Input.is_action_pressed("jump") and (is_on_floor() or full_contact):
		jump()
	
	# Movement
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	
	# Side
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		
	if Input.is_action_pressed("sprint"):
		sprinting = true
		weapon_camera.fov = lerp(weapon_camera.fov, sprinting_fov, sprinting_fov_transition * delta)
	else:
		sprinting = false
		weapon_camera.fov = lerp(weapon_camera.fov, default_fov, sprinting_fov_transition * delta)
	
func process_movement(delta):
	# Prevent player from going faster diagonally
	direction = direction.normalized()
	
	var new_speed = default_speed
	
	# Faster speed if sprinting
	if sprinting:
		new_speed = default_speed * 1.5
	
	# Faster speed if the player is unarmed
	if weapon_manager.current_weapon_slot == "empty":
		new_speed *= 1.2
	
	h_velocity = h_velocity.linear_interpolate(direction * new_speed, h_acceleration * delta)
	
	movement.x = h_velocity.x + gravity_vec.x
	movement.z = h_velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	move_and_slide(movement * delta, Vector3.UP)

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

func process_weapon_inputs(delta):
	# Weapon management
	if Input.is_action_just_pressed("empty"):
		weapon_manager.change_weapon("empty")
	if Input.is_action_just_pressed("primary"):
		weapon_manager.change_weapon("primary")
	if Input.is_action_just_pressed("secondary"):
		weapon_manager.change_weapon("secondary")
		
	# Shooting
	if Input.is_action_pressed("fire"):
		weapon_manager.fire()
	if Input.is_action_just_released("fire"):
		weapon_manager.fire_stop()
				
	# Reloading
	if Input.is_action_just_pressed("reload"):
		weapon_manager.reload()

	# Drop weapon
	if Input.is_action_just_pressed("drop"):
		weapon_manager.drop_weapon()

func process_weapon_movement(delta):
	# ADS'ing
	if not sprinting:
		if Input.is_action_pressed("alt_fire"):
			weapon_manager.current_weapon.aim_down_sights(true, delta)
		else:
			weapon_manager.current_weapon.aim_down_sights(false, delta)
	else:
		# Stop adsing if sprinting
		weapon_manager.current_weapon.aim_down_sights(false, delta)
		
	weapon_manager.process_weapon_pickups()
	
	# Weapon Sway
	if weapon_manager.current_weapon is Armed:
		weapon_manager.current_weapon.sway(delta)

func apply_knockback(force = 10000):
	if not is_on_floor() or not full_contact:
		var knockback_vec = head.global_transform.basis.z.normalized()
		gravity_vec.x += knockback_vec.x * force
		gravity_vec.z += knockback_vec.z * force
		gravity_vec.y += knockback_vec.y * force # ...

func apply_recoil(delta):
	if recoil_time > 0:
		head.rotate_x(deg2rad(current_recoil_vector.x * delta) / current_recoil_duration)
		rotate_y(deg2rad(current_recoil_vector.y * delta) / current_recoil_duration)
		recoil_time -= delta

func start_applying_recoil(recoil_vector, recoil_duration):
	current_recoil_duration = recoil_duration
	current_recoil_vector = recoil_vector
	recoil_time = recoil_duration
