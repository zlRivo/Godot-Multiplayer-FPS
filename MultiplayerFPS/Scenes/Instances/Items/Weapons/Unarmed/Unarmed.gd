extends Weapon

var ads_fov = 50
var ads_speed = 10
var is_adsing = false

func aim_down_sights(value, delta):
	is_adsing = value
	
	if is_adsing == false and player.camera.fov == player.default_fov:
		return
	
	if is_adsing:
		player.camera.fov = lerp(player.camera.fov, ads_fov, ads_speed * delta)
	else:
		player.camera.fov = lerp(player.camera.fov, player.default_fov, ads_speed * delta)

func fire():
	pass
	
func fire_stop():
	pass
	
func reload():
	pass
