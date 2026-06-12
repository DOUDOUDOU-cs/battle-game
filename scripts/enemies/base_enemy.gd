extends CharacterBody2D
class_name BaseEnemy

signal died

const GRAVITY = 980.0
const PATROL_SPEED = 40.0
const CHASE_SPEED = 80.0
const DETECT_RANGE = 300.0
const ATTACK_RANGE = 30.0
const ATTACK_VERTICAL_TOLERANCE = 42.0
const PERSONAL_SPACE_RANGE = 18.0
const PLAYER_PUSH_SPEED = 140.0
const PLAYER_PUSH_DISTANCE = 26.0
const ATTACK_COOLDOWN = 2.0
const ATTACK_DAMAGE = 1
const KNOCKBACK_FRICTION = 8.0
const ATTACK_WINDUP = 0.5

enum EnemyState { PATROL, CHASE, ATTACK }

var current_state = EnemyState.PATROL
var max_health = 3
var current_health = 3
var knockback = Vector2.ZERO
var patrol_direction = 1
var patrol_timer = 0.0
var attack_timer = 0.0
var player: CharacterBody2D = null
var is_dead = false
var is_hit = false
var enter_attack_timer = 0.0
var _default_anim_position: Vector2 = Vector2.ZERO

@onready var hurtbox = $Hurtbox
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	attack_timer = 2.0
	add_to_group("wave_enemy")
	_default_anim_position = anim.position
	_on_enemy_ready()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	velocity.x = knockback.x
	knockback.x = move_toward(knockback.x, 0, KNOCKBACK_FRICTION)

	if attack_timer > 0:
		attack_timer -= delta
	if enter_attack_timer > 0:
		enter_attack_timer -= delta

	if player != null and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		var horizontal_distance = abs(player.global_position.x - global_position.x)
		var vertical_distance = abs(player.global_position.y - global_position.y)
		var has_line_of_sight = _has_line_of_sight_to_player()
		_update_state(distance, horizontal_distance, vertical_distance, has_line_of_sight)
		_execute_state(delta)

	move_and_slide()
	_apply_player_separation(delta)
	_update_animation()

func _update_state(
	distance: float,
	horizontal_distance: float,
	vertical_distance: float,
	has_line_of_sight: bool
) -> void:
	match current_state:
		EnemyState.PATROL:
			if has_line_of_sight and distance < DETECT_RANGE:
				current_state = EnemyState.CHASE
		EnemyState.CHASE:
			if distance > DETECT_RANGE * 1.5 or not has_line_of_sight:
				current_state = EnemyState.PATROL
			elif horizontal_distance < ATTACK_RANGE and vertical_distance < ATTACK_VERTICAL_TOLERANCE:
				current_state = EnemyState.ATTACK
				enter_attack_timer = ATTACK_WINDUP
		EnemyState.ATTACK:
			if horizontal_distance > ATTACK_RANGE * 1.5 or vertical_distance > ATTACK_VERTICAL_TOLERANCE * 1.5:
				current_state = EnemyState.CHASE if has_line_of_sight else EnemyState.PATROL
			elif not has_line_of_sight:
				current_state = EnemyState.PATROL

func _execute_state(delta: float) -> void:
	match current_state:
		EnemyState.PATROL:
			_do_patrol(delta)
		EnemyState.CHASE:
			_do_chase()
		EnemyState.ATTACK:
			_do_attack()

func _do_patrol(delta: float) -> void:
	patrol_timer -= delta
	if patrol_timer <= 0:
		patrol_direction *= -1
		patrol_timer = randf_range(1.5, 3.0)
	velocity.x = patrol_direction * PATROL_SPEED

func _do_chase() -> void:
	if player == null:
		return

	var offset_x = player.global_position.x - global_position.x
	if abs(offset_x) <= PERSONAL_SPACE_RANGE:
		velocity.x = 0
		return

	var direction = sign(offset_x)
	velocity.x = direction * CHASE_SPEED

func _do_attack() -> void:
	velocity.x = 0
	if enter_attack_timer > 0:
		return

	if attack_timer <= 0 and player != null:
		var horizontal_distance = abs(player.global_position.x - global_position.x)
		var vertical_distance = abs(player.global_position.y - global_position.y)
		if (
			horizontal_distance < ATTACK_RANGE
			and vertical_distance < ATTACK_VERTICAL_TOLERANCE
			and _has_line_of_sight_to_player()
		):
			attack_timer = ATTACK_COOLDOWN
			player.take_damage(ATTACK_DAMAGE, global_position)

func _has_line_of_sight_to_player() -> bool:
	if player == null or not is_instance_valid(player):
		return false

	var space = get_world_2d().direct_space_state
	var from = global_position + Vector2(0, -16)
	var to = player.global_position + Vector2(0, -24)
	var params = PhysicsRayQueryParameters2D.create(from, to)
	params.exclude = [get_rid(), player.get_rid()]
	var result = space.intersect_ray(params)
	return result.is_empty()

func _update_animation() -> void:
	if is_dead or is_hit:
		return

	match current_state:
		EnemyState.PATROL:
			if abs(velocity.x) > 0:
				anim.play("run")
				anim.flip_h = velocity.x > 0
			else:
				anim.play("idle")
		EnemyState.CHASE:
			anim.play("run")
			anim.flip_h = velocity.x > 0
		EnemyState.ATTACK:
			anim.play("attack")
			if player != null:
				anim.flip_h = player.global_position.x > global_position.x

	_apply_animation_alignment()

func _apply_player_separation(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var vertical_distance: float = abs(player.global_position.y - global_position.y)
	if vertical_distance > ATTACK_VERTICAL_TOLERANCE:
		return

	var offset_x: float = global_position.x - player.global_position.x
	if abs(offset_x) >= PLAYER_PUSH_DISTANCE:
		return

	var player_velocity_x: float = player.velocity.x
	if abs(player_velocity_x) <= 0.01:
		return

	var push_direction: float = sign(offset_x) if abs(offset_x) > 0.01 else sign(player_velocity_x)
	var player_is_pushing: bool = sign(player_velocity_x) == push_direction
	if player_is_pushing:
		var desired_push: float = sign(player_velocity_x) * min(abs(player_velocity_x) * 0.55, PLAYER_PUSH_SPEED)
		velocity.x = desired_push if abs(desired_push) > abs(velocity.x) else velocity.x

func _apply_animation_alignment() -> void:
	anim.position = _default_anim_position + _get_animation_offset(StringName(anim.animation), anim.frame)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackRay":
		take_damage(1, area.get_parent().global_position)

func take_damage(amount: int, attacker_pos: Vector2) -> void:
	if is_dead or is_hit:
		return

	current_health -= amount
	var direction = sign(global_position.x - attacker_pos.x)
	knockback = Vector2(direction * 300, -150)

	is_hit = true
	_play_hit_animation()
	_on_damage_taken()

	var hit_timer = get_tree().create_timer(_get_hit_recover_duration())
	hit_timer.timeout.connect(func():
		if not is_dead and is_instance_valid(self):
			_finish_hit_recovery()
			if current_health <= 0:
				die()
	)

func die() -> void:
	if is_dead:
		return

	is_dead = true
	remove_from_group("wave_enemy")
	died.emit()
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	anim.stop()
	anim.play("die")
	_spawn_drops()

	var die_timer = get_tree().create_timer(_get_die_duration())
	die_timer.timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _play_hit_animation() -> void:
	anim.stop()
	anim.play("hit")

func _finish_hit_recovery() -> void:
	is_hit = false

func _get_hit_recover_duration() -> float:
	return 0.3

func _get_die_duration() -> float:
	return 0.8

func _get_animation_offset(_animation_name: StringName, _frame: int) -> Vector2:
	return Vector2.ZERO

func _on_enemy_ready() -> void:
	pass

func _on_damage_taken() -> void:
	pass

func _spawn_drops() -> void:
	push_error("_spawn_drops must be implemented by enemy child scripts.")
