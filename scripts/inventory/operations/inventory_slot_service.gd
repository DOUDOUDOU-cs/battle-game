class_name InventorySlotService
extends RefCounted

static func get_slot_item(src: String, idx: int, craft_state: InventoryCraftState) -> ItemData:
	if src == "hotbar" or src == "bh" or src == "bag":
		return Inventory.get_slot_item(src, idx)
	if src == "craft":
		return craft_state.get_item(idx)
	return null

static func set_slot_item(src: String, idx: int, item: ItemData, craft_state: InventoryCraftState) -> void:
	if src == "hotbar" or src == "bh" or src == "bag":
		Inventory.set_slot_item(src, idx, item)
	elif src == "craft":
		craft_state.set_item(idx, item)

static func stash_cursor_item(
	cursor_item: ItemData,
	cursor_src: String,
	cursor_idx: int,
	craft_state: InventoryCraftState
) -> ItemData:
	if cursor_item == null:
		return null

	var remaining_item: ItemData = cursor_item
	if cursor_src != "" and cursor_idx >= 0:
		var origin_item: ItemData = get_slot_item(cursor_src, cursor_idx, craft_state)
		if origin_item == null:
			set_slot_item(cursor_src, cursor_idx, remaining_item, craft_state)
			return null
		if origin_item.item_id == remaining_item.item_id and origin_item.quantity < origin_item.max_stack:
			var give: int = min(origin_item.max_stack - origin_item.quantity, remaining_item.quantity)
			origin_item.quantity += give
			remaining_item.quantity -= give
			if remaining_item.quantity <= 0:
				return null

	if Inventory.add_item(remaining_item):
		return null
	return remaining_item

static func apply_left_click(
	src: String,
	idx: int,
	cursor_item: ItemData,
	cursor_src: String,
	cursor_idx: int,
	craft_state: InventoryCraftState
) -> Dictionary:
	var slot_item: ItemData = get_slot_item(src, idx, craft_state)
	var result := {
		"cursor_item": cursor_item,
		"cursor_src": cursor_src,
		"cursor_idx": cursor_idx,
		"drag_active": false,
		"drag_slots": [],
		"drag_origin": {},
		"inventory_changed": false
	}

	if cursor_item == null and slot_item == null:
		return result

	if cursor_item == null and slot_item != null:
		set_slot_item(src, idx, null, craft_state)
		result["cursor_item"] = slot_item
		result["cursor_src"] = src
		result["cursor_idx"] = idx
		result["drag_active"] = true
		result["drag_slots"] = [{"src": src, "idx": idx}]
		result["drag_origin"] = {"src": src, "idx": idx}
		result["inventory_changed"] = true
		return result

	if cursor_item != null and slot_item == null:
		set_slot_item(src, idx, cursor_item, craft_state)
		result["cursor_item"] = null
		result["cursor_src"] = ""
		result["cursor_idx"] = -1
		result["inventory_changed"] = true
		return result

	if cursor_item != null and slot_item != null:
		if cursor_item.item_id == slot_item.item_id:
			var space: int = slot_item.max_stack - slot_item.quantity
			var give: int = min(space, cursor_item.quantity)
			slot_item.quantity += give
			cursor_item.quantity -= give
			if cursor_item.quantity <= 0:
				result["cursor_item"] = null
				result["cursor_src"] = ""
				result["cursor_idx"] = -1
			result["inventory_changed"] = true
			return result

		set_slot_item(src, idx, cursor_item, craft_state)
		result["cursor_item"] = slot_item
		result["cursor_src"] = src
		result["cursor_idx"] = idx
		result["inventory_changed"] = true

	return result

static func distribute_drag(
	cursor_item: ItemData,
	drag_slots: Array,
	drag_origin: Dictionary,
	craft_state: InventoryCraftState
) -> Dictionary:
	var result := {
		"cursor_item": cursor_item,
		"inventory_changed": false
	}
	if cursor_item == null or drag_slots.is_empty():
		return result

	var targets: Array = []
	for s in drag_slots:
		if s["src"] == drag_origin.get("src") and s["idx"] == drag_origin.get("idx"):
			continue
		var existing: ItemData = get_slot_item(s["src"], s["idx"], craft_state)
		if existing != null and existing.item_id != cursor_item.item_id:
			continue
		targets.append(s)

	if targets.is_empty():
		set_slot_item(drag_origin["src"], drag_origin["idx"], cursor_item, craft_state)
		result["cursor_item"] = null
		result["inventory_changed"] = true
		return result

	var total_quantity: int = cursor_item.quantity
	var base_amount: int = total_quantity / targets.size()
	var remainder: int = total_quantity % targets.size()
	var moved_any: bool = false

	for i in range(targets.size()):
		var s: Dictionary = targets[i]
		var desired: int = base_amount + (1 if i < remainder else 0)
		if desired <= 0 and cursor_item.quantity > 0:
			desired = 1
		if desired <= 0:
			continue

		var existing: ItemData = get_slot_item(s["src"], s["idx"], craft_state)
		var move_amount: int = desired
		if existing == null:
			move_amount = min(move_amount, cursor_item.quantity)
			if move_amount <= 0:
				continue
			var one: ItemData = cursor_item.duplicate_item()
			one.quantity = move_amount
			set_slot_item(s["src"], s["idx"], one, craft_state)
			cursor_item.quantity -= move_amount
			moved_any = true
		else:
			var available_space: int = existing.max_stack - existing.quantity
			move_amount = min(move_amount, available_space, cursor_item.quantity)
			if move_amount <= 0:
				continue
			existing.quantity += move_amount
			cursor_item.quantity -= move_amount
			moved_any = true

	if not moved_any:
		set_slot_item(drag_origin["src"], drag_origin["idx"], cursor_item, craft_state)
		result["cursor_item"] = null
	elif cursor_item.quantity <= 0:
		result["cursor_item"] = null

	result["inventory_changed"] = true
	return result

static func shift_click(src: String, idx: int, craft_state: InventoryCraftState) -> void:
	var item: ItemData = get_slot_item(src, idx, craft_state)
	if item == null:
		return

	set_slot_item(src, idx, null, craft_state)
	if src == "bag" or src == "craft":
		if not Inventory.add_item(item):
			set_slot_item(src, idx, item, craft_state)
	elif src == "hotbar" or src == "bh":
		if not Inventory.try_add_item_to_bag(item):
			set_slot_item(src, idx, item, craft_state)

static func double_click(cursor_item: ItemData, src: String, idx: int) -> void:
	if cursor_item == null:
		return

	var target_id: String = cursor_item.item_id
	for i in Inventory.BAG_SIZE:
		if cursor_item.quantity >= cursor_item.max_stack:
			break
		var bag_item: ItemData = Inventory.get_slot_item("bag", i)
		if bag_item != null and bag_item.item_id == target_id:
			var take: int = min(bag_item.quantity, cursor_item.max_stack - cursor_item.quantity)
			cursor_item.quantity += take
			bag_item.quantity -= take
			if bag_item.quantity <= 0:
				Inventory.set_slot_item("bag", i, null)

	for i in Inventory.HOTBAR_SIZE:
		if cursor_item.quantity >= cursor_item.max_stack:
			break
		if i == idx and (src == "hotbar" or src == "bh"):
			continue
		var hotbar_item: ItemData = Inventory.get_slot_item("hotbar", i)
		if hotbar_item != null and hotbar_item.item_id == target_id:
			var take: int = min(hotbar_item.quantity, cursor_item.max_stack - cursor_item.quantity)
			cursor_item.quantity += take
			hotbar_item.quantity -= take
			if hotbar_item.quantity <= 0:
				Inventory.set_slot_item("hotbar", i, null)

static func find_slot_at(
	mp: Vector2,
	bag_open: bool,
	hotbar_rects: Array,
	bag_rects: Array,
	bh_rects: Array,
	craft_rects: Array,
	craft_result_rect: Rect2
) -> Dictionary:
	if bag_open:
		for i in bh_rects.size():
			if bh_rects[i].has_point(mp):
				return {"src": "bh", "idx": i}
		for i in bag_rects.size():
			if bag_rects[i].has_point(mp):
				return {"src": "bag", "idx": i}
		for i in craft_rects.size():
			if craft_rects[i].has_point(mp):
				return {"src": "craft", "idx": i}
		if craft_result_rect.has_point(mp):
			return {"src": "craft_result", "idx": 0}
	else:
		for i in hotbar_rects.size():
			if hotbar_rects[i].has_point(mp):
				return {"src": "hotbar", "idx": i}
	return {}
