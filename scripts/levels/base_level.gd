extends Node2D
class_name BaseLevel

const MAP_TILE_SCALE := Vector2(1.2, 1.2)
const PLAYER_GROUND_OFFSET := 40.0
const PLAYER_CLEARANCE_TILES := 6
const PLAYER_MIN_PLATFORM_TILES := 4

@onready var player: CharacterBody2D = $Player
@onready var health_bar: ProgressBar = $CanvasLayer/Control/HUDFrame/HealthBar
@onready var wave_label: Label = $CanvasLayer/Control/WaveLabel
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var player_camera: Camera2D = $Player/Camera2D if has_node("Player/Camera2D") else null

var is_level_game_over: bool = false
var is_level_transitioning: bool = false
var level_score: int = 0
var _initial_player_spawn: Vector2 = Vector2.ZERO

func _ready() -> void:
	_initial_player_spawn = player.global_position
	_setup_level_ui()
	_connect_level_signals()
	_on_level_ready()
	await get_tree().create_timer(1.0).timeout
	_resume_or_start_wave()

func _process(delta: float) -> void:
	if is_level_game_over:
		return

	health_bar.value = player.current_health
	_on_level_process(delta)

	if _should_end_level_when_player_health_empty() and player.current_health <= 0:
		_start_level_game_over()

func _setup_level_ui() -> void:
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	pause_menu.visible = false

func _connect_level_signals() -> void:
	$CanvasLayer/PauseMenu/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$CanvasLayer/PauseMenu/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$KillZone.body_entered.connect(_on_kill_zone_body_entered)

	if has_node("TransitionLeft"):
		$TransitionLeft.body_entered.connect(_on_transition_left_body_entered)
	if has_node("TransitionRight"):
		$TransitionRight.body_entered.connect(_on_transition_right_body_entered)
	if _should_watch_player_tree_exiting():
		player.tree_exiting.connect(_on_player_tree_exiting)

	WaveManager.wave_cleared.connect(_on_wave_cleared)

func _resume_or_start_wave() -> void:
	if WaveManager.wave_in_progress and WaveManager.enemies_alive > 0:
		_spawn_wave_enemies(WaveManager.enemies_alive)
		wave_label.text = _format_wave_text(WaveManager.current_wave)
	else:
		_start_next_wave()

func _start_next_wave() -> void:
	WaveManager.start_wave(WaveManager.current_wave + 1)
	wave_label.text = _format_wave_text(WaveManager.current_wave)
	_spawn_wave_enemies(WaveManager.enemies_alive)

func _format_wave_text(wave_num: int) -> String:
	return "Wave " + str(wave_num)

func _register_wave_enemy(enemy: Node2D) -> void:
	if enemy.has_signal("died"):
		enemy.died.connect(_on_wave_enemy_died)
	add_child(enemy)

func _on_wave_enemy_died() -> void:
	WaveManager.on_enemy_died()
	_on_wave_enemy_defeated()

func _get_ground_y_at_x(x: float) -> float:
	var space = get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.create(
		Vector2(x, 50.0), Vector2(x, 700.0)
	)
	params.exclude = [player.get_rid()]
	var result = space.intersect_ray(params)
	if result:
		return result.position.y - 40.0
	return -1.0

func _change_to_level(scene_path: String) -> void:
	is_level_transitioning = true
	get_tree().call_deferred("change_scene_to_file", scene_path)

func _start_level_game_over() -> void:
	if is_level_game_over:
		return

	is_level_game_over = true
	WaveManager.wave_in_progress = false
	wave_label.text = _format_game_over_text()
	await get_tree().create_timer(_get_game_over_delay()).timeout
	_finish_level_game_over()

func _format_game_over_text() -> String:
	return "Game Over!\nWave: %d\nCleared: %d\nScore: %d" % [
		WaveManager.current_wave,
		WaveManager.cleared_wave_count,
		level_score
	]

func _get_game_over_delay() -> float:
	return 3.0

func _toggle_pause_menu() -> void:
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused

func _on_level_ready() -> void:
	pass

func _on_level_process(_delta: float) -> void:
	pass

func _spawn_wave_enemies(_enemy_count: int) -> void:
	push_error("_spawn_wave_enemies must be implemented by child level scripts.")

func _on_wave_enemy_defeated() -> void:
	pass

func _should_end_level_when_player_health_empty() -> bool:
	return false

func _should_watch_player_tree_exiting() -> bool:
	return false

func _finish_level_game_over() -> void:
	get_tree().reload_current_scene()

func _handle_left_transition(_body: Node) -> void:
	pass

func _handle_right_transition(_body: Node) -> void:
	pass

func _on_wave_cleared(wave_num: int) -> void:
	wave_label.text = _format_wave_text(wave_num) + " Clear!"
	await get_tree().create_timer(2.0).timeout
	_start_next_wave()

func _on_kill_zone_body_entered(body: Node) -> void:
	if body == player:
		_start_level_game_over()
	elif body.is_in_group("wave_enemy"):
		body.queue_free()
		WaveManager.on_enemy_died()
		_on_wave_enemy_defeated()

func _on_transition_left_body_entered(body: Node) -> void:
	if body == player:
		_handle_left_transition(body)

func _on_transition_right_body_entered(body: Node) -> void:
	if body == player:
		_handle_right_transition(body)

func _on_player_tree_exiting() -> void:
	if is_level_game_over or is_level_transitioning:
		return
	_start_level_game_over()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause_menu()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_quit_pressed() -> void:
	is_level_transitioning = true
	get_tree().paused = false
	WaveManager.reset()
	get_tree().change_scene_to_file("res://scenes/ui/start.tscn")


func _configure_static_level_map(tilemap: TileMapLayer) -> void:
	if tilemap == null:
		return

	tilemap.scale = MAP_TILE_SCALE
	var spawn_data: Dictionary = _find_static_spawn_data(tilemap)
	_align_tilemap_to_spawn(tilemap, spawn_data, _initial_player_spawn)
	player.global_position = _initial_player_spawn
	_sync_level_boundaries_to_tilemap(tilemap)


func _align_tilemap_to_spawn(tilemap: TileMapLayer, spawn_data: Dictionary, spawn_world: Vector2) -> void:
	var world_tile_size: Vector2 = _get_tilemap_world_tile_size(tilemap)
	var spawn_cell_center_x: float = float(spawn_data.get("center_x", 1.5))
	var spawn_surface_y: int = int(spawn_data.get("surface_y", 1))
	tilemap.position = Vector2(
		spawn_world.x - world_tile_size.x * spawn_cell_center_x,
		spawn_world.y + PLAYER_GROUND_OFFSET - world_tile_size.y * spawn_surface_y
	)


func _find_static_spawn_data(tilemap: TileMapLayer) -> Dictionary:
	var used_rect: Rect2i = tilemap.get_used_rect()

	for y in range(used_rect.position.y, used_rect.end.y):
		var run_start: int = -1
		for x in range(used_rect.position.x, used_rect.end.x + 1):
			var on_surface: bool = (
				x < used_rect.end.x
				and _tile_exists(tilemap, Vector2i(x, y))
				and not _tile_exists(tilemap, Vector2i(x, y - 1))
			)

			if on_surface:
				if run_start < 0:
					run_start = x
				continue

			if run_start >= 0:
				var run_width: int = x - run_start
				if run_width >= PLAYER_MIN_PLATFORM_TILES and _has_headroom(tilemap, run_start, run_width, y):
					return {
						"x": run_start,
						"width": run_width,
						"surface_y": y,
						"center_x": run_start + run_width * 0.5
					}
				run_start = -1

	return {
		"x": used_rect.position.x,
		"width": max(PLAYER_MIN_PLATFORM_TILES, used_rect.size.x),
		"surface_y": used_rect.position.y,
		"center_x": used_rect.position.x + max(PLAYER_MIN_PLATFORM_TILES, used_rect.size.x) * 0.5
	}


func _has_headroom(tilemap: TileMapLayer, start_x: int, width: int, surface_y: int) -> bool:
	for x in range(start_x, start_x + width):
		for offset_y in range(1, PLAYER_CLEARANCE_TILES + 1):
			if _tile_exists(tilemap, Vector2i(x, surface_y - offset_y)):
				return false
	return true


func _tile_exists(tilemap: TileMapLayer, cell: Vector2i) -> bool:
	return tilemap.get_cell_source_id(cell) != -1


func _get_tilemap_world_tile_size(tilemap: TileMapLayer) -> Vector2:
	return Vector2(tilemap.tile_set.tile_size) * tilemap.scale


func _get_tilemap_world_bounds(tilemap: TileMapLayer) -> Rect2:
	var used_rect: Rect2i = tilemap.get_used_rect()
	var world_tile_size: Vector2 = _get_tilemap_world_tile_size(tilemap)
	var top_left := tilemap.position + Vector2(used_rect.position) * world_tile_size
	var world_size := Vector2(used_rect.size) * world_tile_size
	return Rect2(top_left, world_size)


func _sync_level_boundaries_to_tilemap(tilemap: TileMapLayer) -> void:
	var bounds: Rect2 = _get_tilemap_world_bounds(tilemap)
	var bottom_margin: float = 120.0
	var side_margin: float = 48.0

	if has_node("KillZone/CollisionShape2D"):
		var kill_shape_node: CollisionShape2D = $KillZone/CollisionShape2D
		var kill_rect: RectangleShape2D = kill_shape_node.shape as RectangleShape2D
		if kill_rect != null:
			kill_rect.size = Vector2(bounds.size.x + side_margin * 2.0, 120.0)
			kill_shape_node.position = Vector2(bounds.position.x + bounds.size.x * 0.5, bounds.end.y + bottom_margin)

	if has_node("TransitionLeft/CollisionShape2D"):
		$TransitionLeft/CollisionShape2D.position = Vector2(bounds.position.x - side_margin, bounds.position.y + bounds.size.y * 0.5)

	if has_node("TransitionRight/CollisionShape2D"):
		$TransitionRight/CollisionShape2D.position = Vector2(bounds.end.x + side_margin, bounds.position.y + bounds.size.y * 0.5)

	if player_camera != null:
		player_camera.limit_left = int(bounds.position.x - side_margin * 0.5)
		player_camera.limit_right = int(bounds.end.x + side_margin * 0.5)
		player_camera.limit_top = int(bounds.position.y - 220.0)
		player_camera.limit_bottom = int(bounds.end.y + 80.0)


func _get_ground_spawn_points(tilemap: TileMapLayer, desired_count: int) -> Array:
	var points: Array = []
	if tilemap == null or desired_count <= 0:
		return points

	var bounds: Rect2 = _get_tilemap_world_bounds(tilemap)
	var segment_count: int = max(desired_count, 6)
	var inset: float = 64.0

	for i in range(segment_count):
		var t: float = 0.0 if segment_count == 1 else float(i + 1) / float(segment_count + 1)
		var sample_x: float = lerp(bounds.position.x + inset, bounds.end.x - inset, t)
		var ground_y: float = _get_ground_y_at_x(sample_x)
		if ground_y <= 0.0:
			continue
		points.append(Vector2(sample_x, ground_y))

	return points
