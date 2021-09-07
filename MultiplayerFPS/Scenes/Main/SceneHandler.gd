extends Node

onready var game_world_scene = preload("res://Scenes/Main/World.tscn")
onready var login_screen_scene = preload("res://Scenes/Instances/UI/LoginScreen.tscn")

var login_screen = null

func _ready():
	var login = login_screen_scene.instance()
	login_screen = login
	add_child(login)

func CreateWorld():
	var world = game_world_scene.instance()
	DeleteLoginScreen()
		
	add_child(world)

func DeleteLoginScreen():
	if login_screen != null:
		login_screen.queue_free()
		login_screen = null
