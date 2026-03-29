extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 980.0
const ATTACK_DURATION = 0.4
const COMBO_WINDOW = 0.8

var max_health = 8
var current_health = 8
var is_attacking = false
var attack_timer = 0.0
var facing_right = true
var knockback = Vector2.ZERO
var is_invincible = false
var combo_count = 0
var combo_timer = 0.0

@onready var attack_ray = $AttackRay
@onready var attack_visual = $AttackVisual
@onready var hurtbox = $Hurtbox
@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	attack_visual.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_set_facing(1)
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif Input.is_key_pressed(KEY_A):
		velocity.x = -SPEED
		_set_facing(-1)
	elif Input.is_key_pressed(KEY_D):
		velocity.x = SPEED
		_set_facing(1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if combo_timer > 0:
		combo_timer -= delta
	else:
		combo_count = 0

	if Input.is_action_just_pressed("attack") and not is_attacking:
		_start_attack()

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			_end_attack()

	velocity.x += knockback.x
	knockback.x = move_toward(knockback.x, 0, 8.0)

	move_and_slide()
	_update_animation()

func _set_facing(direction: int) -> void:
	if direction > 0 and facing_right:
		return
	if direction < 0 and not facing_right:
		return
	facing_right = direction > 0
	anim.flip_h = not facing_right
	if facing_right:
		attack_ray.target_position.x = 50
		attack_visual.position.x = 0
	else:
		attack_ray.target_position.x = -50
		attack_visual.position.x = -50

func _start_attack() -> void:
	is_attacking = true
	combo_count += 1
	if combo_count > 3:
		combo_count = 1
	attack_timer = ATTACK_DURATION
	attack_visual.visible = true

	# 根据连击数播放不同动画
	match combo_count:
		1: anim.play("attack1")
		2: anim.play("attack2")
		3: anim.play("attack3")

	# 检测攻击命中
	if attack_ray.is_colliding():
		var hit = attack_ray.get_collider()
		if hit.has_method("take_damage"):
			hit.take_damage(1, global_position)

func _end_attack() -> void:
	is_attacking = false
	attack_visual.visible = false
	combo_timer = COMBO_WINDOW
	if is_attacking:
		return
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("jump")
	elif abs(velocity.x) > 10:
		anim.play("run")
	else:
		anim.play("idle")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea" and not is_invincible:
		take_damage(1, area.get_parent().global_position)

func take_damage(amount: int, attacker_pos: Vector2) -> void:
	if is_invincible:
		return
	current_health -= amount
	var direction = sign(global_position.x - attacker_pos.x)
	knockback = Vector2(direction * 250, -100)
	is_invincible = true
	_blink()
	await get_tree().create_timer(1.5).timeout
	is_invincible = false
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0)
	if current_health <= 0:
		die()

func _blink() -> void:
	for i in range(5):
		$AnimatedSprite2D.modulate = Color(1.0, 0.3, 0.3)
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color(0.2, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0)

func die() -> void:
	get_tree().reload_current_scene()

func _update_animation() -> void:
	if is_attacking:
		return
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("jump")
	elif abs(velocity.x) > 10:
		anim.play("run")
	else:
		anim.play("idle")
