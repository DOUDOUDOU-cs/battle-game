extends Node2D

@onready var player = $Player
@onready var health_bar = $CanvasLayer/Control/HUDFrame/HealthBar
@onready var wave_label = $CanvasLayer/Control/WaveLabel
@onready var pause_menu = $CanvasLayer/PauseMenu

var current_wave = 0
var enemies_per_wave = 3
var enemies_alive = 0
var wave_in_progress = false
var game_over = false
var score = 0

func _ready() -> void:
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	pause_menu.visible = false
	
	$CanvasLayer/PauseMenu/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$CanvasLayer/PauseMenu/VBoxContainer/QuitButton.pressed.connect(_on_quit)
	$KillZone.body_entered.connect(_on_kill_zone_entered)
	$TransitionLeft.body_entered.connect(_on_transition_left)
	
	# 监听玩家死亡
	player.tree_exiting.connect(_on_player_died)
	
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()

func _process(_delta: float) -> void:
	if game_over:
		return
	
	health_bar.value = player.current_health
	
	# 检查玩家是否死亡
	if player.current_health <= 0:
		_game_over()
		return
	
	# 波次清理逻辑
	if wave_in_progress and enemies_alive <= 0:
		wave_in_progress = false
		wave_label.text = "Wave " + str(current_wave) + " Clear!"
		await get_tree().create_timer(2.0).timeout
		_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	enemies_per_wave = 3 + (current_wave - 1)  # 每波增加 1 个敌人
	enemies_alive = enemies_per_wave
	wave_in_progress = true
	wave_label.text = "Wave " + str(current_wave)
	
	var enemy_scene = preload("res://scenes/enemy.tscn")
	for i in range(enemies_per_wave):
		var enemy = enemy_scene.instantiate()
		enemy.position = _random_spawn_pos()
		enemy.tree_exiting.connect(_on_enemy_died)
		add_child(enemy)

func _random_spawn_pos() -> Vector2:
	var player_x = player.global_position.x
	var candidate_xs = [150.0, 400.0, 650.0, 900.0, 1150.0, 1400.0, 1700.0, 1900.0]
	candidate_xs.shuffle()
	for x in candidate_xs:
		if abs(x - player_x) < 120.0:
			continue
		var ground_y = _find_ground_y(x)
		if ground_y > 0.0:
			return Vector2(x, ground_y)
	# 后备
	var fx = 1600.0 if player_x < 960.0 else 200.0
	return Vector2(fx, _find_ground_y(fx) if _find_ground_y(fx) > 0.0 else 420.0)

func _find_ground_y(x: float) -> float:
	var space = get_world_2d().direct_space_state
	var params = PhysicsRayQueryParameters2D.create(
		Vector2(x, 50.0), Vector2(x, 700.0))
	params.exclude = [player.get_rid()]
	var result = space.intersect_ray(params)
	if result:
		return result.position.y - 40.0
	return -1.0

func _on_enemy_died() -> void:
	enemies_alive -= 1
	score += 10  # 每杀死一个敌人加 10 分

func _on_kill_zone_entered(body: Node) -> void:
	if body.name == "Player":
		_game_over()
	elif body.has_method("take_damage"):
		body.queue_free()
		_on_enemy_died()

func _on_transition_left(body: Node) -> void:
	if body.name == "Player":
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")

func _on_player_died() -> void:
	_game_over()

func _game_over() -> void:
	if game_over:
		return
	game_over = true
	wave_in_progress = false
	wave_label.text = "Game Over!\nWave: " + str(current_wave) + "\nScore: " + str(score)
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	var paused = not get_tree().paused
	get_tree().paused = paused
	pause_menu.visible = paused

func _on_resume() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")
