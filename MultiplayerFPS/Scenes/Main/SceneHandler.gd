extends Node

onready var game_world = preload("res://Scenes/Main/World.tscn")
onready var login_screen = preload("res://Scenes/Instances/UI/LoginScreen.tscn")

func _ready():
	var login = login_screen.instance()
	add_child(login)

func CreateWorld():
	var world = game_world.instance()
	add_child(world)
