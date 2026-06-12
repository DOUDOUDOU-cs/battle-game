extends BaseLevel

@onready var tilemap: TileMapLayer = $TileMapLayer


func _on_level_ready() -> void:
	_configure_static_level_map(tilemap)


func _spawn_wave_enemies(enemy_count: int) -> void:
	var enemy_scene = preload("res://scenes/enemies/enemy.tscn")
	var enemy2_scene = preload("res://scenes/enemies/enemy2.tscn")
	var spawn_points: Array = _get_ground_spawn_points(tilemap, max(enemy_count, 7))
	if spawn_points.is_empty():
		spawn_points.append(player.global_position + Vector2(120.0, 0.0))

	for i in range(enemy_count):
		var enemy_scene_to_spawn = enemy2_scene if (i % 2 == 1) else enemy_scene
		var enemy = enemy_scene_to_spawn.instantiate()
		enemy.position = spawn_points[i % spawn_points.size()]
		_register_wave_enemy(enemy)

func _on_kill_zone_body_entered(body: Node) -> void:
	if body == player:
		get_tree().reload_current_scene()
	elif body.is_in_group("wave_enemy"):
		body.queue_free()
		WaveManager.on_enemy_died()

func _handle_right_transition(_body: Node) -> void:
	_change_to_level("res://scenes/levels/level2.tscn")
