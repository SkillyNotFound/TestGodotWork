extends Control

signal cover_complete
signal transition_finished

@export var appear_duration: float = 0.4
@export var disappear_duration: float = 0.4
@export var wave_spread: float = 0.25
@export var exit_scale_max: float = 10.0

var hex_texture: Texture2D
var tex_width: float = 150.0
var tex_height: float = 170.0
var spacing_x: float
var spacing_y: float
var offset_x: float
var cols: int
var rows: int
var col_start: int
var col_end: int
var row_start: int
var row_end: int
var center: Vector2
var max_dist: float
var elapsed: float = 0.0
var total_duration: float
var appear_end: float
var cover_emitted: bool = false
var finished_emitted: bool = false
var viewport_size: Vector2

func _ready():
	hex_texture = load("res://六边形.png")
	viewport_size = get_viewport_rect().size

	# 禁用纹理二次插值，使用邻近采样保持像素边缘锐利
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# 六边形密铺参数：纹理 15x17 渲染为 150x170，尖顶朝上
	spacing_x = tex_width
	spacing_y = tex_height * 0.75
	offset_x = tex_width * 0.5

	# 向外多铺 2 列/2 行确保屏幕四边无空隙
	cols = ceili(viewport_size.x / spacing_x) + 1
	rows = ceili(viewport_size.y / spacing_y)
	col_start = -2
	col_end = cols + 2
	row_start = -2
	row_end = rows + 2
	center = viewport_size / 2.0

	# 计算四角到中心的距离，取最大值作为归一化基准
	var corners = [
		Vector2(0, 0),
		Vector2(viewport_size.x, 0),
		Vector2(0, viewport_size.y),
		Vector2(viewport_size.x, viewport_size.y),
	]
	max_dist = 0.0
	for corner in corners:
		var d = center.distance_to(corner)
		if d > max_dist:
			max_dist = d

	total_duration = wave_spread + appear_duration + disappear_duration
	appear_end = wave_spread + appear_duration

	position = Vector2.ZERO
	size = viewport_size
	set_process(false)
	visible = false

func start_transition():
	elapsed = 0.0
	cover_emitted = false
	finished_emitted = false
	visible = true
	set_process(true)

func _process(delta):
	elapsed += delta
	queue_redraw()

	if not cover_emitted and elapsed >= appear_end:
		cover_emitted = true
		cover_complete.emit()

	if elapsed >= total_duration:
		if not finished_emitted:
			finished_emitted = true
			transition_finished.emit()
		set_process(false)
		visible = false

func _draw():
	if not hex_texture:
		return

	for r in range(row_start, row_end):
		var row_offset = (r % 2) * offset_x
		for c in range(col_start, col_end):
			# 六边形中心坐标（奇数行水平偏移半个宽度）
			var cx = c * spacing_x + row_offset + tex_width * 0.5
			var cy = r * spacing_y + tex_height * 0.5

			var dist = center.distance_to(Vector2(cx, cy))
			var nd = dist / max_dist

			var result = _calc_anim(nd)
			if result.scale > 0.001 and result.alpha > 0.0:
				var rel_x = cx - center.x
				var rel_y = cy - center.y
				var draw_cx = center.x + rel_x * result.scale
				var draw_cy = center.y + rel_y * result.scale
				var draw_w = tex_width * result.scale
				var draw_h = tex_height * result.scale
				var rect = Rect2(draw_cx - draw_w * 0.5, draw_cy - draw_h * 0.5, draw_w, draw_h)

				# 深灰色影子：先绘制以落在后方
				draw_texture_rect(hex_texture, rect, false, Color(0.1, 0.1, 0.1) * result.alpha)
				# 六边形纹理覆盖在上层
				draw_texture_rect(hex_texture, rect, false, Color.WHITE * result.alpha)

func _calc_anim(nd: float) -> Dictionary:
	var delay = nd * wave_spread

	var enter_start = delay
	var enter_end = enter_start + appear_duration
	var exit_start = enter_end
	var exit_end = exit_start + disappear_duration

	if elapsed < enter_start:
		return {"scale": 0.0, "alpha": 0.0}

	elif elapsed < enter_end:
		var t = (elapsed - enter_start) / appear_duration
		var eased = ease_out_cubic(t)
		return {"scale": lerp(0.0, 1.0, eased), "alpha": eased}

	elif elapsed < exit_end:
		var t = (elapsed - exit_start) / disappear_duration
		var eased = ease_in_cubic(t)
		return {"scale": lerp(1.0, exit_scale_max, eased), "alpha": 1.0 - eased}

	else:
		return {"scale": 0.0, "alpha": 0.0}

func ease_out_cubic(t: float) -> float:
	return 1.0 - pow(1.0 - t, 3.0)

func ease_in_cubic(t: float) -> float:
	return pow(t, 3.0)
