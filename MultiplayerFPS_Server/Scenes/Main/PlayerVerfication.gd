extends Node

onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

func start(player_id):
	CreatePlayerContainer(player_id)
	
func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	
	# Get the player container we just created
	var player_container = get_node("../" + str(player_id))
	# Fill info
	FillPlayerContainer(player_container)

func FillPlayerContainer(player_container):
	player_container.player_stats = ServerData.data.player_stats
