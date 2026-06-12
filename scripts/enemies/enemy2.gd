extends BaseEnemy

func _on_damage_taken() -> void:
	anim.scale = Vector2(0.5, 0.5)

func _finish_hit_recovery() -> void:
	anim.scale = Vector2(0.5, 0.5)
	super._finish_hit_recovery()

func _get_die_duration() -> float:
	return 1.0

func _spawn_drops() -> void:
	var drop_scene = preload("res://scenes/drops/item_drop_slime_gel.tscn")
	var drop_count = randi_range(1, 2)

	for _i in range(drop_count):
		var drop = drop_scene.instantiate()
		get_parent().add_child(drop)
		drop.global_position = global_position

		var item_data = ItemData.new()
		item_data.item_id = "slime_gel"
		item_data.item_name = "Slime Gel"
		item_data.quantity = 1

		var throw_dir = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()
		drop.setup(item_data, throw_dir)
