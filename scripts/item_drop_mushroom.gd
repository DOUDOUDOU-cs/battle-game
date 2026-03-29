extends Node2D
# 蘑菇掉落物 - 自定义绘制像素风蘑菇

const ATTRACT_RANGE = 80.0
const PICKUP_RANGE = 18.0
const ATTRACT_SPEED = 260.0
const GRAVITY = 500.0

var item_data: ItemData = null
var _velocity: Vector2 = Vector2.ZERO
var _pickup_delay: float = 0.6
var _landed: bool = false
var _land_y: float = 0.0
var _bob_time: float = 0.0
var _glow_time: float = 0.0

func setup(data: ItemData, throw_dir: Vector2 = Vector2.ZERO) -> void:
	item_data = data
	_velocity = throw_dir * 160.0 + Vector2(0, -180.0)
	_land_y = position.y + 90.0

func _ready() -> void:
	add_to_group("item_drops")

func _process(delta: float) -> void:
	_glow_time += delta

	if _pickup_delay > 0.0:
		_pickup_delay -= delta
		if not _landed:
			_velocity.y += GRAVITY * delta
			position += _velocity * delta
			if _velocity.y > 0 and position.y >= _land_y:
				_landed = true
				position.y = _land_y
				_velocity = Vector2.ZERO
		queue_redraw()
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		queue_redraw()
		return

	var dist = global_position.distance_to(player.global_position)
	if dist < ATTRACT_RANGE:
		var dir = (player.global_position - global_position).normalized()
		position += dir * ATTRACT_SPEED * delta
		if dist < PICKUP_RANGE:
			_try_pickup()
			return
	else:
		_bob_time += delta

	queue_redraw()

func _try_pickup() -> void:
	if item_data == null:
		return
	if Inventory.add_item(item_data):
		queue_free()

func _draw() -> void:
	var bob_y = sin(_bob_time * 3.2) * 3.5 if _landed else 0.0
	var c = Vector2(0.0, bob_y)

	# 十字光晕（白色，中间略粗）
	var pulse = 0.55 + 0.2 * sin(_glow_time * 4.0)
	var col_out = Color(1.0, 1.0, 1.0, pulse * 0.35)
	var col_mid = Color(1.0, 1.0, 1.0, pulse * 0.75)
	# 横臂
	draw_line(c + Vector2(-16, 0), c + Vector2(16, 0), col_out, 1.5, true)
	draw_line(c + Vector2(-10, 0), c + Vector2(10, 0), col_mid, 3.5, true)
	# 竖臂
	draw_line(c + Vector2(0, -16), c + Vector2(0, 16), col_out, 1.5, true)
	draw_line(c + Vector2(0, -10), c + Vector2(0, 10), col_mid, 3.5, true)
	# 中心亮点
	draw_circle(c, 2.5, Color(1.0, 1.0, 1.0, pulse))

	# 蘑菇茎（米白色矩形）
	var stem_rect = Rect2(c + Vector2(-3.0, 2.0), Vector2(6.0, 6.0))
	draw_rect(stem_rect, Color(0.95, 0.9, 0.75, 1.0))
	# 茎的阴影边
	draw_rect(Rect2(c + Vector2(-3.0, 2.0), Vector2(1.5, 6.0)), Color(0.75, 0.7, 0.55, 1.0))

	# 蘑菇帽（红色半圆）
	draw_circle(c + Vector2(0.0, 1.5), 7.0, Color(0.85, 0.15, 0.1, 1.0))
	# 遮掉帽子下半部分（露出茎）
	draw_rect(Rect2(c + Vector2(-8.0, 2.5), Vector2(16.0, 8.0)), Color(0, 0, 0, 0))

	# 用多个小圆代替半圆（更像像素风）
	# 重绘帽子上半弧
	for i in range(-6, 7):
		var hx = float(i)
		var hy = -sqrt(max(0.0, 49.0 - hx * hx))
		if hy < 0:
			draw_circle(c + Vector2(hx, 1.5 + hy * 0.6), 1.2, Color(0.85, 0.15, 0.1, 1.0))

	# 白色圆点装饰
	draw_circle(c + Vector2(-2.5, -1.5), 1.5, Color(1.0, 1.0, 1.0, 0.9))
	draw_circle(c + Vector2(2.5, -2.5), 1.2, Color(1.0, 1.0, 1.0, 0.9))
	draw_circle(c + Vector2(0.0, -4.5), 1.0, Color(1.0, 1.0, 1.0, 0.8))
