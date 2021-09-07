extends Control

onready var username_input = $BackGround/VBoxContainer/Username
onready var password_input = $BackGround/VBoxContainer/Password
onready var login_button = $BackGround/VBoxContainer/HBoxContainer/ButtonConnect

func _on_ButtonConnect_pressed():
	if is_instance_valid(self):
		var username = username_input.text.strip_edges()
		var password = password_input.text
		
		if username == "" or password == "":
			print("Please provide a valid UserID and password")
		else:
			login_button.disabled = true
			# Try to login with username and password
			Gateway.ConnectToServer(username, password)
