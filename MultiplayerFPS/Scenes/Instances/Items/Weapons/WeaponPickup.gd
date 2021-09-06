extends RigidBody

# Weapon parameters
export var weapon_name = "Weapon"
export var ammo_in_mag = 5
onready var mag_size = ammo_in_mag
onready var extra_ammo = mag_size * 5

func _ready():
	connect("sleeping_state_changed", self, "_on_sleeping_state_changed")
	
func get_weapon_pickup_data():
	return {
		"name": weapon_name,
		"ammo": ammo_in_mag,
		"extra_ammo": extra_ammo,
		"mag_size": mag_size
	}	

# When the rigidbody stays idle for a certain period, it becomes static
func _on_sleeping_state_changed():
	mode = MODE_STATIC
