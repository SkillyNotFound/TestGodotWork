extends Control

@onready var button = $EnterButton
@onready var bg = $Background
@onready var transition = $TransitionOverlay

func _ready():
	button.pressed.connect(_on_enter_pressed)
	transition.cover_complete.connect(_on_cover_complete)
	transition.transition_finished.connect(_on_transition_finished)

func _on_enter_pressed():
	button.visible = false
	transition.start_transition()

func _on_cover_complete():
	bg.visible = false

func _on_transition_finished():
	get_parent().queue_free()
