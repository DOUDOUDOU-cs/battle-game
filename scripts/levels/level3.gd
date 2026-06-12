extends BaseLevel

enum MapGenerationMode {
	SMALL,
	LARGE,
	GLITCH_ZONE
}

@onready var tilemap: TileMapLayer = $TileMap
@onready var kill_zone_collision: CollisionShape2D = $KillZone/CollisionShape2D

const ENTITY_GROUND_OFFSET = 40.0
const TILEMAP_SCALE = MAP_TILE_SCALE

@export_enum("Small", "Large", "Glitch Zone") var map_generation_mode: int = MapGenerationMode.LARGE

var map_generator: RandomLevelGenerator = RandomLevelGenerator.new()
var map_layout: Dictionary = {}
var platforms: Array = []

func _should_end_level_when_player_health_empty() -> bool:
	return true

func _on_level_ready() -> void:
	tilemap.scale = TILEMAP_SCALE
	_generate_level_layout()
	_align_generated_map_to_spawn_origin()
	_position_player_on_spawn()
	_configure_kill_zone()

func _get_world_tile_size() -> Vector2:
	return Vector2(tilemap.tile_set.tile_size) * tilemap.scale

func _generate_level_layout() -> void:
	match map_generation_mode:
		MapGenerationMode.SMALL:
			map_layout = map_generator.generate_small_map(tilemap)
		MapGenerationMode.GLITCH_ZONE:
			map_layout = map_generator.generate_glitch_zone_map(tilemap)
		_:
			map_layout = map_generator.generate_large_map(tilemap)

	platforms = map_layout["platforms"] if map_layout.has("platforms") else []

func _get_layout_int(key: String, fallback: int) -> int:
	if not map_layout.has(key):
		return fallback
	return int(map_layout[key])

func _get_layout_float(key: String, fallback: float) -> float:
	if not map_layout.has(key):
		return fallback
	return float(map_layout[key])

func _position_player_on_spawn() -> void:
	player.global_position = _initial_player_spawn


func _align_generated_map_to_spawn_origin() -> void:
	var world_tile_size: Vector2 = _get_world_tile_size()
	var spawn_cell_center_x: float = _get_layout_float("spawn_cell_center_x", 4.0)
	var spawn_surface_y: int = _get_layout_int("spawn_surface_y", 8)
	tilemap.position = Vector2(
		_initial_player_spawn.x - world_tile_size.x * spawn_cell_center_x,
		_initial_player_spawn.y + ENTITY_GROUND_OFFSET - world_tile_size.y * spawn_surface_y
	)

func _configure_kill_zone() -> void:
	var shape: RectangleShape2D = kill_zone_collision.shape as RectangleShape2D
	if shape == null:
		return

	var world_tile_size: Vector2 = _get_world_tile_size()
	var level_width: int = _get_layout_int("level_width", 36)
	var kill_zone_row: int = _get_layout_int("kill_zone_row", 18)
	var world_width = level_width * world_tile_size.x
	shape.size = Vector2(world_width + world_tile_size.x * 4.0, 160.0)
	kill_zone_collision.position = Vector2(
		tilemap.position.x + world_width * 0.5,
		tilemap.position.y + kill_zone_row * world_tile_size.y
	)

func _spawn_wave_enemies(enemy_count: int) -> void:
	var enemy_scene = preload("res://scenes/enemies/enemy.tscn")
	var enemy2_scene = preload("res://scenes/enemies/enemy2.tscn")

	for i in range(enemy_count):
		var enemy_scene_to_spawn = enemy2_scene if (i % 2 == 1) else enemy_scene
		var enemy = enemy_scene_to_spawn.instantiate()
		enemy.position = _get_level3_spawn_position()
		_register_wave_enemy(enemy)

func _get_level3_spawn_position() -> Vector2:
	var world_tile_size: Vector2 = _get_world_tile_size()
	if platforms.is_empty():
		var spawn_cell_center_x: float = _get_layout_float("spawn_cell_center_x", 12.0) + 8.0
		var spawn_surface_y: int = _get_layout_int("spawn_surface_y", 8)
		return Vector2(
			tilemap.position.x + world_tile_size.x * spawn_cell_center_x,
			tilemap.position.y + world_tile_size.y * spawn_surface_y - ENTITY_GROUND_OFFSET
		)

	var platform: Dictionary = platforms[randi() % platforms.size()]
	var platform_x: int = int(platform["x"])
	var platform_y: int = int(platform["y"])
	var platform_width: int = int(platform["width"])
	var x = tilemap.position.x + (platform_x + platform_width * 0.5) * world_tile_size.x
	var y = tilemap.position.y + platform_y * world_tile_size.y - ENTITY_GROUND_OFFSET
	return Vector2(x, y)

func _on_wave_enemy_defeated() -> void:
	level_score += 10

func _handle_left_transition(_body: Node) -> void:
	_change_to_level("res://scenes/levels/level2.tscn")

func _finish_level_game_over() -> void:
	is_level_transitioning = true
	WaveManager.reset()
	get_tree().change_scene_to_file("res://scenes/ui/start.tscn")

func _on_quit_pressed() -> void:
	is_level_transitioning = true
	get_tree().paused = false
	WaveManager.reset()
	get_tree().change_scene_to_file("res://scenes/ui/start.tscn")
