extends BaseLevel

@onready var tilemap: TileMapLayer = $TileMapLayer


func _on_level_ready() -> void:
	_configure_static_level_map(tilemap)


func _should_end_level_when_player_health_empty() -> bool:
	return true

func _spawn_wave_enemies(enemy_count: int) -> void:
	var enemy_scene = preload("res://scenes/enemies/enemy.tscn")

	for _i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		enemy.position = _get_level2_spawn_position()
		_register_wave_enemy(enemy)

func _get_level2_spawn_position() -> Vector2:
	var player_x: float = player.global_position.x
	var spawn_points: Array = _get_ground_spawn_points(tilemap, 10)
	spawn_points.shuffle()

	for point in spawn_points:
		var spawn_point: Vector2 = point as Vector2
		if abs(spawn_point.x - player_x) < 120.0:
			continue
		return spawn_point

	var bounds: Rect2 = _get_tilemap_world_bounds(tilemap)
	var fallback_x: float = bounds.end.x - 120.0 if player_x < bounds.position.x + bounds.size.x * 0.5 else bounds.position.x + 120.0
	var fallback_y: float = _get_ground_y_at_x(fallback_x)
	return Vector2(fallback_x, fallback_y if fallback_y > 0.0 else player.global_position.y)

func _on_wave_enemy_defeated() -> void:
	level_score += 10

func _handle_left_transition(_body: Node) -> void:
	_change_to_level("res://scenes/levels/main.tscn")

func _handle_right_transition(body: Node) -> void:
	if WaveManager.can_enter_level3():
		_change_to_level("res://scenes/levels/level3.tscn")
	else:
		var player_node: CharacterBody2D = body as CharacterBody2D
		if player_node:
			player_node.velocity.x = -300
