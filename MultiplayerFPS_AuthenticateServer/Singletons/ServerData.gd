extends Node

var data

func _ready() -> void:
	var file = File.new()
	file.open("res://data/PlayerData.json", File.READ)
	var json_player_data = JSON.parse(file.get_as_text())
	file.close()
	data = json_player_data.result
