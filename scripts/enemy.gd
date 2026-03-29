extends CharacterBody2D

const GRAVITY = 980.0
const PATROL_SPEED = 40.0
const CHASE_SPEED = 80.0
const DETECT_RANGE = 300.0
const ATTACK_RANGE = 30.0
const ATTACK_COOLDOWN = 2.0
const ATTACK_DAMAGE = 1
const KNOCKBACK_FRICTION = 8.0

enum State { PATROL, CHASE, ATTACK }
var current_state = State.PATROL

var max_health = 3
var current_health = 3
var knockback = Vector2.ZERO
var patrol_direction = 1
var patrol_timer = 0.0
var attack_timer = 0.0
var player = null
var is_dead = false
var is_hit = false
var enter_attack_timer = 0.0

@onready var hurtbox = $Hurtbox
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	player = get_tree().get_first_node_in_group("player")
	attack_timer = 2.0    # 生成后2秒内不攻击

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	velocity.x = knockback.x
	knockback.x = move_toward(knockback.x, 0, KNOCKBACK_FRICTION)
	if attack_timer > 0:
		attack_timer -= delta
	if enter_attack_timer > 0:      # ← 新增倒计时
		enter_attack_timer -= delta
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		_update_state(distance)
		_execute_state(delta, distance)
	move_and_slide()
	_update_animation()

func _update_state(distance: float) -> void:
	match current_state:
		State.PATROL:
			if distance < DETECT_RANGE:
				current_state = State.CHASE
		State.CHASE:
			if distance > DETECT_RANGE * 1.5:
				current_state = State.PATROL
			elif distance < ATTACK_RANGE:
				current_state = State.ATTACK
				enter_attack_timer = 0.5  # ← 进入攻击状态后0.5秒才能攻击
		State.ATTACK:
			if distance > ATTACK_RANGE * 1.5:
				current_state = State.CHASE

func _execute_state(delta: float, distance: float) -> void:
	match current_state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase()
		State.ATTACK:
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
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * CHASE_SPEED

func _do_attack() -> void:
	velocity.x = 0
	# 进入攻击状态的延迟倒计时
	if enter_attack_timer > 0:
		return
	if attack_timer <= 0 and player != null:
		var dist = global_position.distance_to(player.global_position)
		if dist < ATTACK_RANGE:
			attack_timer = ATTACK_COOLDOWN
			player.take_damage(ATTACK_DAMAGE, global_position)

func _update_animation() -> void:
	if is_dead or is_hit:   # ← 受击时不更新动画
		return
	match current_state:
		State.PATROL:
			if abs(velocity.x) > 0:
				anim.play("run")
				anim.flip_h = velocity.x > 0
			else:
				anim.play("idle")
		State.CHASE:
			anim.play("run")
			anim.flip_h = velocity.x > 0
		State.ATTACK:
			anim.play("attack")
			if player != null:
				anim.flip_h = player.global_position.x > global_position.x

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
	anim.stop()
	anim.play("hit")

	# 用Timer代替await，更可靠
	var hit_timer = get_tree().create_timer(0.3)
	hit_timer.timeout.connect(func():
		if not is_dead and is_instance_valid(self):
			is_hit = false
			if current_health <= 0:
				die()
	)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	hurtbox.set_deferred("monitoring", false)
	anim.stop()
	anim.play("die")
	_spawn_drops()

	# 等死亡动画播完
	var die_timer = get_tree().create_timer(0.8)
	die_timer.timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _spawn_drops() -> void:
	var drop_scene = preload("res://scenes/item_drop_mushroom.tscn")
	var count = randi_range(1, 2)
	for i in range(count):
		var drop = drop_scene.instantiate()
		get_parent().add_child(drop)
		drop.global_position = global_position
		var data = ItemData.new()
		data.item_id = "mushroom"
		data.item_name = "蘑菇"
		data.quantity = 1
		var dir = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()
		drop.setup(data, dir)
