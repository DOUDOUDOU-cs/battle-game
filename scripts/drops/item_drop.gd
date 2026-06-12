extends Node2D

const ATTRACT_RANGE := 80.0
const PICKUP_RANGE := 18.0
const ATTRACT_SPEED := 260.0
const GRAVITY := 500.0
const THROW_SPEED := 160.0
const LIFT_SPEED := -180.0
const STARBURST_RAYS := 18

var item_data: ItemData = null

var _velocity: Vector2 = Vector2.ZERO
var _pickup_delay: float = 0.6
var _landed: bool = false
var _land_y: float = 0.0
var _bob_time: float = 0.0
var _glow_time: float = 0.0
var _item_texture: Texture2D = null


func setup(data: ItemData, throw_dir: Vector2 = Vector2.ZERO) -> void:
	item_data = data
	_item_texture = _resolve_item_texture()
	_velocity = throw_dir * THROW_SPEED + Vector2(0.0, LIFT_SPEED)
	_land_y = position.y + 90.0


func _ready() -> void:
	add_to_group("item_drops")
	_item_texture = _resolve_item_texture()


func _process(delta: float) -> void:
	_glow_time += delta

	if _pickup_delay > 0.0:
		_pickup_delay -= delta
		if not _landed:
			_velocity.y += GRAVITY * delta
			position += _velocity * delta
			if _velocity.y > 0.0 and position.y >= _land_y:
				_landed = true
				position.y = _land_y
				_velocity = Vector2.ZERO
		queue_redraw()
		return

	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		queue_redraw()
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist < ATTRACT_RANGE:
		var dir: Vector2 = (player.global_position - global_position).normalized()
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


func _resolve_item_texture() -> Texture2D:
	if item_data == null:
		return null
	return ItemTextureLibrary.get_texture(item_data.item_id, item_data.icon)


func _draw() -> void:
	var bob_y: float = sin(_bob_time * 3.2) * 3.5 if _landed else 0.0
	var center := Vector2(0.0, bob_y)
	var pulse := 0.7 + 0.2 * sin(_glow_time * 4.0)
	var spin := _glow_time * 0.45

	_draw_starbust(center, pulse, spin)
	_draw_item_texture(center, pulse)


func _draw_starbust(center: Vector2, pulse: float, spin: float) -> void:
	var core_color := Color(1.0, 0.97, 0.70, 0.95 * pulse)
	var mid_color := Color(1.0, 0.90, 0.28, 0.42 * pulse)
	var outer_color := Color(0.95, 0.78, 0.08, 0.22 * pulse)

	draw_circle(center, 7.5, outer_color)
	draw_circle(center, 5.0, mid_color)
	draw_circle(center, 2.8, core_color)

	for i in range(STARBURST_RAYS):
		var angle: float = spin + TAU * float(i) / float(STARBURST_RAYS)
		var long_ray: bool = (i % 2) == 0
		var ray_length: float = 40.0 if long_ray else 27.0
		ray_length += 2.0 * sin(_glow_time * 2.0 + i)
		var ray_width: float = 4.2 if long_ray else 2.4
		var inner_point := center + Vector2.RIGHT.rotated(angle) * 3.0
		var outer_point := center + Vector2.RIGHT.rotated(angle) * ray_length
		draw_line(inner_point, outer_point, outer_color, ray_width, true)
		draw_line(inner_point, center + Vector2.RIGHT.rotated(angle) * (ray_length * 0.72), mid_color, max(ray_width - 1.4, 1.0), true)


func _draw_item_texture(center: Vector2, pulse: float) -> void:
	if _item_texture == null:
		draw_circle(center, 9.0, Color(0.92, 0.84, 0.40, 0.9))
		return

	var tex_size: Vector2 = _item_texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return

	var max_side: float = max(tex_size.x, tex_size.y)
	var scale: float = 24.0 / max_side
	var draw_size := tex_size * scale
	var draw_rect := Rect2(center - draw_size * 0.5, draw_size)

	draw_texture_rect(_item_texture, draw_rect.grow(2.0), false, Color(1.0, 0.95, 0.70, 0.18 * pulse))
	draw_texture_rect(_item_texture, draw_rect, false, Color(1.0, 1.0, 1.0, 1.0))
