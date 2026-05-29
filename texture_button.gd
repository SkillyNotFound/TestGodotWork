extends TextureButton

var animation_duration: float = 0.15
var hover_scale: Vector2 = Vector2(0.6, 0.6)

@onready var glow_layer = $GlowLayer
var tween: Tween

func _ready():
	self.scale = Vector2(0.5, 0.5)
	glow_layer.modulate.a = 0.0

# 鼠标悬停：按钮放大 + 光晕浮现
func _on_mouse_entered():
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "scale", hover_scale, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(glow_layer, "modulate:a", 1.0, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# 鼠标离开：按钮恢复 + 光晕隐去
func _on_mouse_exited():
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "scale", Vector2(0.5, 0.5), animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(glow_layer, "modulate:a", 0.0, animation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
