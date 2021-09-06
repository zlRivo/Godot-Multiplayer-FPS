extends Spatial
class_name Weapon

# References
var weapon_manager : Spatial = null
var player = null
var ray = null

# Weapon states
var is_equipped = false

# Weapon parameters
export var weapon_name = "Weapon"
export(Texture) var weapon_image = null

# Equip/Unequip cycle
func equip():
	pass
	
func unequip():
	pass

func is_equip_finished():
	return true
	
func is_unequip_finished():
	return true
			
func update_ammo(action = "refresh"):
	
	var weapon_data = {
		"name": weapon_name,
		"image" : weapon_image
	}
	
	weapon_manager.update_hud(weapon_data)
