extends Control

func get_pause_state():
	return Globals.in_pause_menu

func set_pause_state(state):
	if state == true:
		visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globals.in_pause_menu = true
	else:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Globals.in_pause_menu = false


func _on_ResumeButton_pressed():
	set_pause_state(false)

func _on_QuitButton_pressed():
	get_tree().quit()
