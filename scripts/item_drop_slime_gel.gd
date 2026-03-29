extends Node2D
# 史莱姆凝胶掉落物 - 自定义绘制像素风凝胶

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

	# 凝胶主体（半透明蓝绿水滴形）
	# 底部扁圆
	draw_circle(c + Vector2(0.0, 2.0), 6.5, Color(0.2, 0.75, 0.55, 0.85))
	# 顶部略窄
	draw_circle(c + Vector2(0.0, -1.5), 4.5, Color(0.25, 0.8, 0.6, 0.85))
	# 顶部尖端小圆
	draw_circle(c + Vector2(0.0, -5.0), 2.2, Color(0.3, 0.82, 0.62, 0.8))

	# 内部高光（模拟半透明果冻感）
	draw_circle(c + Vector2(0.0, 1.5), 4.0, Color(0.4, 0.9, 0.75, 0.35))

	# 小高光点
	draw_circle(c + Vector2(-2.0, -0.5), 1.5, Color(0.9, 1.0, 0.95, 0.75))
	draw_circle(c + Vector2(-1.0, -2.5), 1.0, Color(1.0, 1.0, 1.0, 0.6))
