extends Button

@onready var transition = $"../TransitionCanvas/TransitionOverlay"

func _ready():
	# 监听转场信号：方块覆满屏幕时加载地图，转场结束后清理自身
	transition.cover_complete.connect(_on_cover_complete)
	transition.transition_finished.connect(_on_transition_finished)

# 点击按钮 → 启动转场动画
func _on_pressed():
	visible = false
	transition.start_transition()

# 方块完全覆盖屏幕，趁机在底层实例化地图场景
func _on_cover_complete():
	var map = load("res://node_2d.tscn").instantiate()
	get_tree().root.add_child(map)

# 转场全部结束，销毁主菜单，露出底层地图
func _on_transition_finished():
	get_parent().queue_free()
