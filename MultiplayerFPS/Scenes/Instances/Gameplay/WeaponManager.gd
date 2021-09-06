extends Spatial

# All the weapons in the game
var all_weapons = {
	"UNARMED" : preload("res://Scenes/Instances/Items/Weapons/Unarmed/Unarmed.tscn"),
	"Glock" : preload("res://Scenes/Instances/Items/Weapons/Armed/Glock/Glock.tscn"),
	"Double Barrel" : preload("res://Scenes/Instances/Items/Weapons/Armed/DoubleBarrel/DoubleBarrel.tscn"),
	"Bullpup Sniper" : preload("res://Scenes/Instances/Items/Weapons/Armed/BullpupSniper/BullpupSniper.tscn"),
	"AK-47" : preload("res://Scenes/Instances/Items/Weapons/Armed/AK47/AK47.tscn")
}

# Carrying weapons
var weapons = {}

# HUD reference
var hud

# Raycast reference
onready var raycast = get_parent().get_node("Camera/ShootRay")

# Pickup raycast reference
onready var pickup_ray = get_parent().get_node("Camera/PickupRay")

var current_weapon # Reference to the active weapon
var current_weapon_slot # Slot name

var changing_weapon = false
var unequipped_weapon = false

func _ready():
	# HUD reference
	hud = owner.get_node("HUD")
	
	# Add raycast exception for the player itself
	raycast.add_exception(owner)
	
	# Current weapons
	weapons = {
		"empty" : $Unarmed,
		"primary" : null,
		"secondary" : null
	}

	# Initialize references for each weapon
	for w in weapons:
		if weapons[w] != null:
			weapon_setup(weapons[w])
			
	# Set current weapon to unarmed
	current_weapon = weapons["empty"]
	change_weapon("empty")

func weapon_setup(w):
	w.weapon_manager = self
	w.player = owner
	w.ray = raycast
	w.visible = false

func _process(delta):
	if unequipped_weapon == false:
		if current_weapon.is_unequip_finished() == false:
			return
			
		unequipped_weapon = true
		
		current_weapon = weapons[current_weapon_slot]
		current_weapon.equip()
		
	if current_weapon.is_equip_finished() == false:
		return
		
	changing_weapon = false
	set_process(false)

func change_weapon(new_weapon_slot):
	
	if weapons[new_weapon_slot] == null:
		return
	
	if new_weapon_slot == current_weapon_slot:
		current_weapon.update_ammo() # Refresh ammo
		return

	current_weapon_slot = new_weapon_slot
	changing_weapon = true
	
	weapons[current_weapon_slot].update_ammo() # Update HUD
	
	# Change weapons
	if current_weapon != null:
		unequipped_weapon = false
		current_weapon.unequip()
		
	set_process(true)

# Fire and reload functions
func fire():
	if not changing_weapon:
		current_weapon.fire()

func fire_stop():
	current_weapon.fire_stop()
	
func reload():
	if not changing_weapon:
		current_weapon.reload()
		
func add_ammo_amount(amount):
	if current_weapon == null or current_weapon.is_in_group("UNARMED"):
		return false
		
	current_weapon.update_ammo("add", amount)
	return true

# Ammo pickup
func add_ammo():
	if current_weapon == null or current_weapon.is_in_group("UNARMED"):
		return false
		
	current_weapon.update_ammo("add", current_weapon.mag_size * 2) # Give 2 mags of current weapon
	return true

# Add weapon to an existing empty slot
func add_weapon(weapon_data):
	# Check if the weapon name exists
	if not weapon_data["name"] in all_weapons:
		return
	
	if weapons["primary"] == null:
		# Instanciate weapon
		var weapon = Globals.instanciate_node(all_weapons[weapon_data["name"]], Vector3.ZERO, self)
		
		# Initialize the new weapon references
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["ammo"]
		weapon.extra_ammo = weapon_data["extra_ammo"]
		weapon.mag_size = weapon_data["mag_size"]
		weapon.transform.origin = weapon.equip_pos
		
		# Update the dictionary and change weapon
		weapons["primary"] = weapon
		change_weapon("primary")
		
		return
		
	if weapons["secondary"] == null:
		# Instanciate weapon
		var weapon = Globals.instanciate_node(all_weapons[weapon_data["name"]], Vector3.ZERO, self)
		
		# Initialize the new weapon references
		weapon_setup(weapon)
		weapon.ammo_in_mag = weapon_data["ammo"]
		weapon.extra_ammo = weapon_data["extra_ammo"]
		weapon.mag_size = weapon_data["mag_size"]
		weapon.transform.origin = weapon.equip_pos
		
		# Update the dictionary and change weapon
		weapons["secondary"] = weapon
		change_weapon("secondary")
		
		return

func drop_weapon():
	if current_weapon_slot != "empty":
		current_weapon.drop_weapon()
		
		current_weapon_slot = "empty"
		current_weapon = weapons["empty"]
		
		# Update HUD
		current_weapon.update_ammo()
		
func drop_all_weapons():
	# Get keys of the weapons held
	var weapon_keys = weapons.keys()
	
	for i in weapon_keys:
		if weapons[i] != null and i != "empty":
			current_weapon_slot = i
			current_weapon = weapons[i]
			change_weapon(i)
			drop_weapon()

func switch_weapon(weapon_data):
	# Loop through the weapons and check for an empty slot
	for i in weapons:
		if weapons[i] == null:
			add_weapon(weapon_data)
			return
			
	if current_weapon.name == "UNARMED":
		weapons["primary"].drop_weapon()
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)
		
	elif current_weapon.name == weapon_data["name"]:
		add_ammo_amount(weapon_data["ammo"] + weapon_data["extra_ammo"])
	
	# If not unarmed and it's a new weapon
	else:
		drop_weapon()
		yield(get_tree(), "idle_frame")
		add_weapon(weapon_data)

func show_interaction_prompt(weapon_name):
	var desc = "Add ammo" if weapon_name == current_weapon.weapon_name else "Equip (" + weapon_name + ")"
	hud.show_interaction_prompt(desc)
	
func hide_interaction_prompt():
	hud.hide_interaction_prompt()

func process_weapon_pickups():
	if pickup_ray.is_colliding():
		var body = pickup_ray.get_collider()
		
		if body.has_method("get_weapon_pickup_data"):
			var weapon_data = body.get_weapon_pickup_data()
			
			# Enable prompt with the name of the weapon
			show_interaction_prompt(weapon_data["name"])
			
			if Input.is_action_just_pressed("interact"):
				switch_weapon(weapon_data)
				# Delete weapon from world
				body.queue_free()
		else:
			hide_interaction_prompt()
			
	else:
		hide_interaction_prompt()

func update_hud(weapon_data):
	var weapon_slot = "1"
	
	match current_weapon_slot:
		"empty":
			weapon_slot = "1"
		"primary":
			weapon_slot = "2"
		"secondary":
			weapon_slot = "3"
			
	hud.update_weapon_ui(weapon_data, weapon_slot)
