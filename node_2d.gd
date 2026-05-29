extends Node2D

@onready var camera = $Camera2D
@onready var background = $TextureRect

var dragging = false
var last_mouse_pos = Vector2.ZERO

func _ready():
	var bg_rect = background.get_global_rect()
	camera.position = bg_rect.position + bg_rect.size / 2.0
	_clamp_camera()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				last_mouse_pos = event.position
			else:
				dragging = false

	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		camera.position -= delta
		_clamp_camera()
		last_mouse_pos = event.position

func _clamp_camera():
	var viewport_size = get_viewport_rect().size
	var half_view = viewport_size / 2.0
	var bg_rect = background.get_global_rect()
	var min_pos = bg_rect.position + half_view
	var max_pos = bg_rect.end - half_view
	camera.position.x = clampf(camera.position.x, min_pos.x, max_pos.x)
	camera.position.y = clampf(camera.position.y, min_pos.y, max_pos.y)
