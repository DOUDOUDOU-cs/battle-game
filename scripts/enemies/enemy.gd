extends BaseEnemy

func _get_die_duration() -> float:
	return 0.8

func _get_animation_offset(animation_name: StringName, frame: int) -> Vector2:
	if animation_name == &"attack":
		return Vector2(0.0, -4.0) if frame >= 3 else Vector2.ZERO
	return Vector2.ZERO

func _spawn_drops() -> void:
	var drop_scene = preload("res://scenes/drops/item_drop_mushroom.tscn")
	var drop_count = randi_range(1, 2)

	for _i in range(drop_count):
		var drop = drop_scene.instantiate()
		get_parent().add_child(drop)
		drop.global_position = global_position

		var item_data = ItemData.new()
		item_data.item_id = "mushroom"
		item_data.item_name = "Mushroom"
		item_data.quantity = 1

		var throw_dir = Vector2(randf_range(-1.0, 1.0), -1.0).normalized()
		drop.setup(item_data, throw_dir)
