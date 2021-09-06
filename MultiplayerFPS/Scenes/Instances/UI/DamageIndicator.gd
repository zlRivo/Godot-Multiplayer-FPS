extends Control

export var lifetime = 1.0
var time_elapsed = 0.0

# Refereces
var player_camera = null
onready var tween = $Tween
onready var label = $Label

var label_text setget set_text, get_text

func set_text(text):
	$Label.text = text
	
func get_text():
	return $Label.text

# Vector saving the location of where it was hit
var hit_position = Vector3.ZERO

# Offset on screen
var x_offset = 0
var y_offset = -181

# Velocity of the label animation
var velocity = Vector2.ZERO

var gravity = Vector2(0, 2)
var mass = 200

onready var last_rect_size = label.rect_size

func _ready():
	velocity = Vector2(rand_range(-100, 100), -100)
	
	# Fade out
	tween.interpolate_property(
		label,
		"modulate",
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 0.0),
		0.3,
		Tween.TRANS_QUART,
		Tween.EASE_OUT,
		0.7
	)
	
	tween.interpolate_property(
		self,
		"rect_scale",
		Vector2(1.0, 1.0),
		Vector2(0.4, 0.4),
		1.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT,
		0.6
	)
	
	tween.interpolate_callback(self, 1.0, "destroy")
	tween.start()

func initialize_components(hit_pos, text, camera, x_offset = 0, y_offset = -181):
	hit_position = hit_pos
	set_text(text)
	player_camera = camera
	update_label_on_screen()

func _process(delta):
	velocity += gravity * mass * delta
	label.rect_global_position += velocity * delta
	
	update_label_on_screen()

func update_label_on_screen():
	if player_camera != null and hit_position != null:
		var pos_on_screen = player_camera.unproject_position(hit_position)
		rect_global_position = pos_on_screen + Vector2(x_offset, y_offset)
		
func destroy():
	queue_free()
