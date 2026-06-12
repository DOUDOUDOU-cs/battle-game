class_name InventoryInputRouter
extends RefCounted

static func begin_slot_interaction(
	mp: Vector2,
	bag_open: bool,
	cursor_item: ItemData,
	shift_pressed: bool,
	slot_lookup: Callable
) -> Dictionary:
	var result: Dictionary = {
		"handled": false,
		"slot": {},
		"shift_click": false,
		"stash_cursor": false,
		"set_drag_origin": false
	}
	if not bag_open:
		return result

	result["handled"] = true
	var slot: Dictionary = slot_lookup.call(mp)
	result["slot"] = slot
	if slot.is_empty():
		result["stash_cursor"] = cursor_item != null
		return result

	if shift_pressed:
		result["shift_click"] = true
		return result

	result["set_drag_origin"] = true
	return result


static func finish_slot_interaction(
	mp: Vector2,
	bag_open: bool,
	drag_active: bool,
	cursor_item: ItemData,
	drag_slots: Array,
	last_click_time: float,
	last_click_slot: Dictionary,
	double_click_sec: float,
	slot_lookup: Callable
) -> Dictionary:
	var result: Dictionary = {
		"handled": false,
		"slot": {},
		"action": "none",
		"next_click_time": last_click_time,
		"next_click_slot": last_click_slot
	}
	if not bag_open:
		return result

	result["handled"] = true
	if drag_active and cursor_item != null and drag_slots.size() > 1:
		result["action"] = "finish_drag"
		return result

	var slot: Dictionary = slot_lookup.call(mp)
	result["slot"] = slot
	if slot.is_empty():
		if cursor_item != null:
			result["action"] = "stash_cursor"
		return result

	if slot.get("src") == "craft_result":
		result["action"] = "left_click"
		return result

	var now: float = Time.get_ticks_msec() / 1000.0
	var same_slot: bool = (
		not last_click_slot.is_empty()
		and last_click_slot.get("src") == slot.get("src")
		and last_click_slot.get("idx") == slot.get("idx")
	)
	if same_slot and (now - last_click_time) < double_click_sec:
		result["action"] = "double_click"
		result["next_click_time"] = -1.0
		result["next_click_slot"] = {}
		return result

	result["action"] = "left_click"
	result["next_click_time"] = now
	result["next_click_slot"] = slot
	return result
