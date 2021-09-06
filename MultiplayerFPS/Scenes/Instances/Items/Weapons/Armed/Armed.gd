extends Weapon
class_name Armed

# Pickup rigidbody version
export(PackedScene) var weapon_pickup

# References
var animation_player

# Weapon states
var is_firing = false
var is_reloading = false

# Weapon parameters
export var ammo_in_mag = 15
onready var mag_size = ammo_in_mag
onready var extra_ammo = mag_size * 5

export var damage = 10
export var fire_rate = 1.0

# Offset of the weapon from the camera
export var equip_pos = Vector3.ZERO
export var equip_rot = Vector3.ZERO

# Effects
export(PackedScene) var impact_effect
export(NodePath) var muzzle_flash_path
onready var muzzle_flash = get_node(muzzle_flash_path)

# Animation speed variables
export var equip_speed = 1.0
export var unequip_speed = 1.0
export var reload_speed = 1.0

var sway_pivot = null # Sway pivot
var sway_amount = 50

# ADS
export var ads_pos = Vector3.ZERO
export var ads_fov = 50
var ads_speed = 10
var is_adsing = false

# Recoil
export var min_recoil_vector = Vector2(5, -1)
export var max_recoil_vector = Vector2(5, 1)
export var recoil_duration = 0.1

enum WEAPON_TYPES {
	UNSET,
	
	PISTOL,
	RIFLE,
	SHOTGUN,
	MELEE,
	SNIPER_RIFLE
}

var weapon_type = 0

var damage_indicator_scene = preload("res://Scenes/Instances/UI/DamageIndicator.tscn")

func _ready():
	set_as_toplevel(true) # Makes rotation unaffected by the parents
	call_deferred("create_sway_pivot")

func fire():
	if not is_reloading:
		if ammo_in_mag > 0:
			if not is_firing:
				is_firing = true
				animation_player.get_animation("shoot").loop = true
				animation_player.play("shoot", -1.0, fire_rate)
		elif is_firing:
			fire_stop()
			
func fire_stop():
	is_firing = false
	animation_player.get_animation("shoot").loop = false

# Will be called from the animation track
func fire_bullet():
	muzzle_flash.emitting = true
	update_ammo("consume")
	
	# Apply recoil
	player.start_applying_recoil(get_random_recoil_vector(), recoil_duration)
	
	# Instance bullet impact if not null
	if impact_effect != null:
		ray.force_raycast_update()
		
		if ray.is_colliding():
			# Know what we hit
			var collider = ray.get_collider()
			
			if collider.has_method("take_damage"):
				collider.take_damage(damage)
				
				# Play hitmarker animation
				player.hud.hitmarker.play()
				
				# Show damage indicator
				var damage_indicator = damage_indicator_scene.instance()
				# initialize_components(hit_pos, text, camera, x_offset = 0, y_offset = -181):
				damage_indicator.initialize_components(
					collider.global_transform.origin,
					str(damage),
					player.camera
				)
				
				player.hud.add_child(damage_indicator)
			else:
				# Bullet impact effect
				var impact = Globals.instanciate_node(impact_effect, ray.get_collision_point())
				impact.emitting = true
		
func get_random_recoil_vector():
	return Vector2(
		rand_range(min_recoil_vector.x, max_recoil_vector.x),
		rand_range(min_recoil_vector.y, max_recoil_vector.y)
	)

func reload():
	if ammo_in_mag < mag_size and extra_ammo > 0:
		is_firing = false
		
		animation_player.play("reload", -1.0, reload_speed)
		is_reloading = true

# Equip/Unequip cycle
func equip():
	animation_player.play("equip", -1.0, equip_speed)
	is_reloading = false
	
func unequip():
	if animation_player.is_playing():
		animation_player.stop(true)
		animation_player.seek(0, true)
	animation_player.play("unequip", -1.0, unequip_speed)

func is_equip_finished():
	return is_equipped
	
func is_unequip_finished():
	return not is_equipped

# Show/Hide Weapon
func show_weapon():
	visible = true
	
func hide_weapon():
	visible = false

func _on_animation_finished(anim_name):
	match anim_name:
		"unequip":
			is_equipped = false
		"equip":
			is_equipped = true
		"reload":
			is_reloading = false
			update_ammo("reload")
			
func update_ammo(action = "refresh", additional_ammo = 0):
	
	match action:
		"consume":
			ammo_in_mag -= 1
		"reload":
			var ammo_needed = mag_size - ammo_in_mag
			if extra_ammo > ammo_needed:
				ammo_in_mag = mag_size
				extra_ammo -= ammo_needed
			else:
				ammo_in_mag += extra_ammo
				extra_ammo = 0
		"add":
			extra_ammo += additional_ammo
	
	var weapon_data = {
		"name" : weapon_name,
		"image" : weapon_image,
		"ammo" : str(ammo_in_mag),
		"extra_ammo" : str(extra_ammo)
	}
	
	weapon_manager.update_hud(weapon_data)

func drop_weapon():
	var pickup = Globals.instanciate_node(weapon_pickup, global_transform.origin - player.global_transform.basis.z.normalized())
	pickup.ammo_in_mag = ammo_in_mag
	pickup.extra_ammo = extra_ammo
	pickup.mag_size = mag_size
	
	# Delete weapon from hand
	queue_free()

# Create pivot for the weapon sway
func create_sway_pivot():
	sway_pivot = Spatial.new()
	get_parent().add_child(sway_pivot) # Add as sibling
	sway_pivot.transform.origin = equip_pos # Set position of pivot
	sway_pivot.rotation_degrees = equip_rot
	sway_pivot.name = weapon_name + "Sway" # Change name

# Perform weapon sway
func sway(delta):
	global_transform.origin = sway_pivot.global_transform.origin # Update position each frame
	
	# Get weapon rotation and sway rotation in quaternion
	var self_quat = global_transform.basis.get_rotation_quat()
	var pivot_quat = sway_pivot.global_transform.basis.get_rotation_quat()
	
	var new_quat = Quat()
	if not is_adsing:
		# Interpolate new rotation between weapon and pivot
		new_quat = self_quat.slerp(pivot_quat, sway_amount * delta)
	else:
		new_quat = pivot_quat
	
	# Apply new rotation
	global_transform.basis = Basis(new_quat)

func _exit_tree():
	if sway_pivot != null:
		sway_pivot.queue_free()
		
func aim_down_sights(value, delta):
	is_adsing = value
	
	if is_adsing == false and player.camera.fov == player.default_fov:
		return
	
	if is_adsing:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(ads_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, ads_fov, ads_speed * delta)
		player.weapon_manager.hud.crosshair.visible = false
		
		# Show sniper crosshair
		if weapon_type == WEAPON_TYPES.SNIPER_RIFLE:
			player.weapon_manager.hud.sniper_crosshair.visible = true
			visible = false
			
			# Lower sensitivity
			player.mouse_sensitivity = player.default_mouse_sensitivity / 4
	else:
		sway_pivot.transform.origin = sway_pivot.transform.origin.linear_interpolate(equip_pos, ads_speed * delta)
		player.camera.fov = lerp(player.camera.fov, player.default_fov, ads_speed * delta)
		player.weapon_manager.hud.crosshair.visible = true
		
		# Show sniper crosshair
		if weapon_type == WEAPON_TYPES.SNIPER_RIFLE:
			player.weapon_manager.hud.sniper_crosshair.visible = false
			visible = true
			
			# Lower sensitivity
			player.mouse_sensitivity = player.default_mouse_sensitivity
