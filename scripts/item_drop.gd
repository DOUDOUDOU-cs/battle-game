extends Node2D

const ATTRACT_RANGE = 80.0
const PICKUP_RANGE = 18.0
const ATTRACT_SPEED = 260.0
const GRAVITY = 500.0
const GROUND_Y_OFFSET = 12.0  # 落地后贴地偏移

var item_data: ItemData = null

var _velocity: Vector2 = Vector2.ZERO
var _pickup_delay: float = 0.6   # 抛出后多久才能被拾取
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
		# 抛出阶段：简单抛物线
		if not _landed:
			_velocity.y += GRAVITY * delta
			position += _velocity * delta
			# 简单落地检测：速度向下且 y 超过初始 y + 一定距离就落地
			if _velocity.y > 0 and position.y >= _land_y:
				_landed = true
				position.y = _land_y
				_velocity = Vector2.ZERO
		queue_redraw()
		return

	# 吸附阶段
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
		# 悬浮上下浮动
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

	# 外光晕（随时间脉冲）
	var pulse = 0.18 + 0.07 * sin(_glow_time * 4.0)
	draw_circle(c, 14.0, Color(0.85, 0.65, 0.1, pulse))

	# 中间光圈
	draw_circle(c, 9.5, Color(0.9, 0.75, 0.2, 0.45))

	# 主球体
	draw_circle(c, 7.0, Color(0.65, 0.45, 0.05, 1.0))

	# 高光边缘
	draw_arc(c, 7.0, 0.0, TAU, 32, Color(1.0, 0.88, 0.35, 1.0), 1.5, true)

	# 小高光点
	draw_circle(c + Vector2(-2.5, -2.5), 1.8, Color(1.0, 1.0, 0.8, 0.85))
