extends Node2D

@onready var player = $Player
@onready var health_bar = $CanvasLayer/Control/HUDFrame/HealthBar
@onready var wave_label = $CanvasLayer/Control/WaveLabel
@onready var pause_menu = $CanvasLayer/PauseMenu

var current_wave = 0
var enemies_per_wave = 3
var enemies_alive = 0
var wave_in_progress = false

var spawn_points_left = [200, 300, 400]
var spawn_points_right = [1500, 1600, 1700]

func _ready() -> void:
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	pause_menu.visible = false
	$CanvasLayer/PauseMenu/VBoxContainer/ResumeButton.pressed.connect(_on_resume)
	$CanvasLayer/PauseMenu/VBoxContainer/QuitButton.pressed.connect(_on_quit)
	$KillZone.body_entered.connect(_on_kill_zone_entered)
	$TransitionRight.body_entered.connect(_on_transition_right)
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()

func _process(_delta: float) -> void:
	health_bar.value = player.current_health
	if wave_in_progress and enemies_alive <= 0:
		wave_in_progress = false
		wave_label.text = "Wave " + str(current_wave) + " Clear!"
		await get_tree().create_timer(2.0).timeout
		_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	enemies_per_wave = 2 + current_wave
	enemies_alive = enemies_per_wave
	wave_in_progress = true
	wave_label.text = "Wave " + str(current_wave)

	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy2_scene = preload("res://scenes/enemy2.tscn")
	var candidate_xs = [180.0, 450.0, 750.0, 1050.0, 1350.0, 1650.0, 1850.0]
	for i in range(enemies_per_wave):
		var x = candidate_xs[i % candidate_xs.size()]
		var ground_y = _find_ground_y(x)
		if ground_y < 0.0:
			ground_y = 420.0
		var scene = enemy2_scene if (i % 2 == 1) else enemy_scene
		var enemy = scene.instantiate()
		enemy.position = Vector2(x, ground_y)
		enemy.tree_exiting.connect(_on_enemy_died)
		add_child(enemy)

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
	print("enemy died, remaining: ", enemies_alive)

func _on_kill_zone_entered(body: Node) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()
	elif body.has_method("take_damage"):
		body.queue_free()
		_on_enemy_died()

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

func _on_transition_right(body: Node) -> void:
	if body.name == "Player":
		get_tree().call_deferred("change_scene_to_file", "res://scenes/level2.tscn")

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start.tscn")
