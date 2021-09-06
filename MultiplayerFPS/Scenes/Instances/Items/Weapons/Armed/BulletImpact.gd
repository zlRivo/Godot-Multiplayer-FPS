extends Node

# Lifetime of the particle
export var duration = 1.0
var current_time = 0

func _process(delta):
	current_time += delta
	if current_time >= duration:
		queue_free()

