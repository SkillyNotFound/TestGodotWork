extends Control

@onready var background = get_node("../TextureRect")

var hex_texture: Texture2D
var tex_width: float = 150.0
var tex_height: float = 170.0
var spacing_x: float
var spacing_y: float
var offset_x: float

@export var tint_color: Color = Color.WHITE
@export var tint_alpha: float = 1.0

var border_coords: Array = []

func _ready():
	hex_texture = load("res://六边形.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var pixel_scale = tex_width / 15.0
	spacing_x = tex_width - pixel_scale
	spacing_y = tex_height * 0.75 - pixel_scale
	offset_x = 7.0 * pixel_scale

	_build_border()

	var bg_rect = background.get_global_rect()
	position = bg_rect.position
	size = bg_rect.size
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_border():
	# 硬编码地图边框坐标列表 [col, row]
	# 基于背景图片尺寸对应的六边形网格，这里绘制矩形外框
	border_coords = [
		# 顶边 row=0
		[0,0], [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0], [8,0], [9,0], [10,0], [11,0], [12,0],
		# 底边 row=8
		[0,8], [1,8], [2,8], [3,8], [4,8], [5,8], [6,8], [7,8], [8,8], [9,8], [10,8], [11,8], [12,8],
		# 左边 col=0（跳过顶底角）
		[0,1], [0,2], [0,3], [0,4], [0,5], [0,6], [0,7],
		# 右边 col=12（跳过顶底角）
		[12,1], [12,2], [12,3], [12,4], [12,5], [12,6], [12,7],
	]

func _draw():
	if not hex_texture:
		return

	for coord in border_coords:
		var col = coord[0]
		var row = coord[1]
		var row_offset = (row % 2) * offset_x
		var cx = col * spacing_x + row_offset + tex_width * 0.5
		var cy = row * spacing_y + tex_height * 0.5
		var rect = Rect2(cx - tex_width * 0.5, cy - tex_height * 0.5, tex_width, tex_height)
		draw_texture_rect(hex_texture, rect, false, Color(tint_color, tint_alpha))
