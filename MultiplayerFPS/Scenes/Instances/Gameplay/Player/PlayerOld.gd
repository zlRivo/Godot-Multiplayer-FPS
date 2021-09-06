extends KinematicBody

var mouse_sensitivity = 0.1

# Movement speed
var speed = 500

# Acceleration
var h_accel = 12
var air_accel = 1
var normal_accel = 12

# Gravity
var gravity = 500

# Jump
var jump = 300

var full_contact = false

# Direction
var direction = Vector3.ZERO
# Velocity
var h_velocity = Vector3.ZERO
# Movement
var movement = Vector3.ZERO

var gravity_vec = Vector3.ZERO

var weapon_to_spawn = null
var weapon_to_drop = null

onready var head = $Head
onready var ground_check = $GroundCheck
onready var pickup_reach = $Head/Camera/PickupReach
onready var hand = $Head/Hand

var glock_scene = preload("res://Scenes/Instances/Items/Weapons/Glock.tscn")
var double_barrel_scene = preload("res://Scenes/Instances/Items/Weapons/DoubleBarrel.tscn")

# List holding all the weapons
var weapons = {}
var selected_weapon = 0
const MAX_WEAPON_COUNT = 3

signal weapon_changed

func manage_weapons():
	var keys = weapons.keys()
	# Loop through all the weapons
	for weapon_key in keys:
		# Makes the selected weapon visible
		if not weapon_key == str(selected_weapon):
			weapons[weapon_key].visible = false
			weapons[weapon_key].set_process(false)
		else:
			# Play deploy animation
			weapons[weapon_key].get_node("AnimationTree").set("parameters/DeploySeek/seek_position", 0)
			weapons[weapon_key].get_node("AnimationTree").set("parameters/Deploying/active", true)
			
			weapons[weapon_key].visible = true
			weapons[weapon_key].set_process(true)

# Function handling the pickup mechanics

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Setup signals
	connect("weapon_changed", self, "_on_weapon_changed")

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func _on_weapon_changed():
	print(JSON.print(weapons))
	# If the current gun slot is already taken
	if weapons.has(str(selected_weapon)):
		# Get current weapon
		var current_weapon = weapons[str(selected_weapon)]
		
		# Know what weapon to drop
		if current_weapon.is_in_group("Glock"):
			weapon_to_drop = glock_scene.instance()
		elif current_weapon.is_in_group("DoubleBarrel"):
			weapon_to_drop = double_barrel_scene.instance()
		else:
			weapon_to_drop = null
	# Else if no weapon in hand
	else:
		weapon_to_drop = null

func drop_gun():
	# If the current gun slot is already taken
	if weapons.has(str(selected_weapon)):
		
		if weapon_to_drop != null:
			# Create a weapon in the game world
			get_parent().add_child(weapon_to_drop)
			weapon_to_drop.global_transform = hand.global_transform
			weapon_to_drop.drop()
		
		# Find and delete current weapon
		for weapon in hand.get_children():
			if weapon.name == str(selected_weapon):
				# Delete current selected weapon from the dictionnary
				weapons.erase(str(selected_weapon))
				# Delete current selected weapon in the game world
				weapon.queue_free()
				emit_signal("weapon_changed")

func _process(delta):
	if pickup_reach.is_colliding():
		var collider = pickup_reach.get_collider()
		if collider != null:
			if pickup_reach.get_collider().is_in_group("Glock"):
				weapon_to_spawn = glock_scene.instance()
			elif pickup_reach.get_collider().is_in_group("DoubleBarrel"):
				weapon_to_spawn = double_barrel_scene.instance()
			else:
				weapon_to_spawn = null
		else:
			weapon_to_spawn = null
	else:
		null
			
	if Input.is_action_just_pressed("pickup"):
		if weapon_to_spawn != null:
			drop_gun()
						
			# Delete weapon in game world
			var collider = pickup_reach.get_collider()
			if collider != null: collider.queue_free()
			
			# Set player reference if the weapon is a double barrel
			if weapon_to_spawn.is_in_group("DoubleBarrel"):
				weapon_to_spawn.player = self
			
			# Switch weapons
			weapon_to_spawn.name = str(selected_weapon)
			weapons[str(selected_weapon)] = weapon_to_spawn # Update dictionnary
			
			# Spawn weapon in hand
			hand.add_child(weapon_to_spawn)
			
			# Set the raycast of the gun to the one of the player camera
			weapon_to_spawn.shoot_raycast = $Head/Camera/ShootReach
			
			# Update rotation
			# weapon_to_spawn.rotation = hand.rotation
			
			# Fire weapon changed signal
			emit_signal("weapon_changed")
			
	# Drop weapons
	if Input.is_action_just_pressed("drop"):
		drop_gun()
			
func _physics_process(delta):
	direction = Vector3.ZERO
	
	var full_contact = ground_check.is_colliding()
	
	# Gravity
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		h_accel = air_accel
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		h_accel = normal_accel
	else:
		gravity_vec = -get_floor_normal()
		
	# Jump
	if Input.is_action_pressed("jump") and (is_on_floor() or full_contact):
		gravity_vec = Vector3.UP * jump
		
	# Weapon management
	if Input.is_action_just_pressed("weapon0"):
		if selected_weapon != 0:
			selected_weapon = 0
			emit_signal("weapon_changed")
			manage_weapons()
	if Input.is_action_just_pressed("weapon1"):
		if selected_weapon != 1:
			selected_weapon = 1
			emit_signal("weapon_changed")
			manage_weapons()
	if Input.is_action_just_pressed("weapon2"):
		if selected_weapon != 2:
			selected_weapon = 2
			emit_signal("weapon_changed")
			manage_weapons()
	
	# Shooting
	
	if Input.is_action_just_pressed("fire"):
		# If the current gun slot is already taken
		if weapons.has(str(selected_weapon)):
			# Check if weapon has a shoot function
			if weapons[str(selected_weapon)].has_method("shoot"):
				# Shoot
				weapons[str(selected_weapon)].shoot()
				
	# Reloading
	
	if Input.is_action_just_pressed("reload"):
		# If the current gun slot is already taken
		if weapons.has(str(selected_weapon)):
			# Check if weapon has a reload function
			if weapons[str(selected_weapon)].has_method("reload"):
				# Reload
				weapons[str(selected_weapon)].reload()
	
	### Movement ###
	# Front
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	
	# Side
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
		
	# Prevent player from going faster diagonally
	direction = direction.normalized()
	
	# Movement animation
	
	
	if weapons.has(str(selected_weapon)):
		# If the current gun slot is already taken
		if weapons[str(selected_weapon)] != null:
			# If it's a glock
			if weapons[str(selected_weapon)].is_in_group("Glock"):
				# Calculate the weapon movement
				var walk_blend = clamp(abs(direction.x) + abs(direction.z), 0, 1)
				
				# Apply anim blend
				weapons[str(selected_weapon)].get_node("AnimationTree").set("parameters/Walking/blend_position", walk_blend)
				
				"""
				# If moving
				if direction != Vector3.ZERO:
					# Moving animation
					weapons[str(selected_weapon)].get_node("AnimationTree").set("parameters/IdleState/current", "walking")
				else:
					# Idle animation
					weapons[str(selected_weapon)].get_node("AnimationTree").set("parameters/IdleState/current", "idle")
				"""
	
	# Smooth movement
	h_velocity = h_velocity.linear_interpolate(direction * speed, h_accel * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	move_and_slide(movement * delta, Vector3.UP)
