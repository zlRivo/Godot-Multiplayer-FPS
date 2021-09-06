extends Node

var skill_data

func _ready() -> void:
	var file = File.new()
	file.open("res://data/GameData.json", File.READ)
	var json_skill_data = JSON.parse(file.get_as_text())
	file.close()
	skill_data = json_skill_data.result
