extends Node

const HOTBAR_SIZE = 9
const BAG_SIZE = 27
const SLOT_HOTBAR = "hotbar"
const SLOT_BAG = "bag"
const SLOT_BAG_HOTBAR = "bh"

var hotbar: Array = []
var bag: Array = []
var selected_slot: int = 0

signal inventory_changed


func _ready() -> void:
	hotbar.resize(HOTBAR_SIZE)
	bag.resize(BAG_SIZE)
	hotbar.fill(null)
	bag.fill(null)


func add_item(item: ItemData) -> bool:
	if item == null:
		return true

	var changed: bool = false
	changed = _stack_item_into_items(hotbar, item) or changed
	changed = _stack_item_into_items(bag, item) or changed
	if item.quantity <= 0:
		_emit_inventory_changed_if_needed(changed)
		return true

	var placed: bool = _place_item_in_empty_slot(hotbar, item)
	changed = placed or changed
	if placed:
		_emit_inventory_changed_if_needed(changed)
		return true

	placed = _place_item_in_empty_slot(bag, item)
	changed = placed or changed
	_emit_inventory_changed_if_needed(changed)
	return placed


func find_stackable_slot(items: Array, item: ItemData) -> int:
	for i in items.size():
		var existing: ItemData = items[i]
		if existing != null and existing.item_id == item.item_id and existing.quantity < existing.max_stack:
			return i
	return -1


func find_empty_slot(items: Array) -> int:
	for i in items.size():
		if items[i] == null:
			return i
	return -1


func get_slot_item(src: String, idx: int) -> ItemData:
	var items: Array = _get_items_for_slot_source(src)
	if not _is_valid_index(items, idx):
		return null
	return items[idx]


func set_slot_item(src: String, idx: int, item: ItemData) -> bool:
	var items: Array = _get_items_for_slot_source(src)
	if not _is_valid_index(items, idx):
		return false
	items[idx] = item
	return true


func take_slot_item(src: String, idx: int) -> ItemData:
	var item: ItemData = get_slot_item(src, idx)
	if item == null:
		return null

	set_slot_item(src, idx, null)
	inventory_changed.emit()
	return item


func add_item_to_container(src: String, item: ItemData) -> bool:
	if item == null:
		return true

	var items: Array = _get_items_for_slot_source(src)
	if items.is_empty():
		return false

	var changed: bool = _stack_item_into_items(items, item)
	if item.quantity <= 0:
		_emit_inventory_changed_if_needed(changed)
		return true

	var placed: bool = _place_item_in_empty_slot(items, item)
	changed = placed or changed
	_emit_inventory_changed_if_needed(changed)
	return placed


func try_add_item_to_bag(item: ItemData) -> bool:
	return add_item_to_container(SLOT_BAG, item)


func remove_hotbar(index: int) -> ItemData:
	return take_slot_item(SLOT_HOTBAR, index)


func remove_bag(index: int) -> ItemData:
	return take_slot_item(SLOT_BAG, index)


func get_selected() -> ItemData:
	return hotbar[selected_slot]


func select_slot(index: int) -> void:
	if index < 0 or index >= HOTBAR_SIZE:
		return
	if selected_slot == index:
		return
	selected_slot = index
	inventory_changed.emit()


func scroll_select(dir: int) -> void:
	selected_slot = (selected_slot + dir + HOTBAR_SIZE) % HOTBAR_SIZE
	inventory_changed.emit()


func drop_selected() -> ItemData:
	return take_slot_item(SLOT_HOTBAR, selected_slot)


func swap_bag(a: int, b: int) -> void:
	swap_slots(SLOT_BAG, a, SLOT_BAG, b)


func swap_hotbar(a: int, b: int) -> void:
	swap_slots(SLOT_HOTBAR, a, SLOT_HOTBAR, b)


func swap_bag_hotbar(bag_idx: int, hotbar_idx: int) -> void:
	swap_slots(SLOT_BAG, bag_idx, SLOT_HOTBAR, hotbar_idx)


func swap_slots(src_a: String, idx_a: int, src_b: String, idx_b: int) -> bool:
	if not is_valid_slot(src_a, idx_a) or not is_valid_slot(src_b, idx_b):
		return false

	var item_a: ItemData = get_slot_item(src_a, idx_a)
	set_slot_item(src_a, idx_a, get_slot_item(src_b, idx_b))
	set_slot_item(src_b, idx_b, item_a)
	inventory_changed.emit()
	return true


func is_valid_slot(src: String, idx: int) -> bool:
	return _is_valid_index(_get_items_for_slot_source(src), idx)


func _get_items_for_slot_source(src: String) -> Array:
	if src == SLOT_HOTBAR or src == SLOT_BAG_HOTBAR:
		return hotbar
	if src == SLOT_BAG:
		return bag
	return []


func _is_valid_index(items: Array, idx: int) -> bool:
	return idx >= 0 and idx < items.size()


func _stack_item_into_items(items: Array, item: ItemData) -> bool:
	var changed := false
	for i in items.size():
		var existing: ItemData = items[i]
		if existing == null:
			continue
		if existing.item_id != item.item_id or existing.quantity >= existing.max_stack:
			continue

		var take: int = min(existing.max_stack - existing.quantity, item.quantity)
		existing.quantity += take
		item.quantity -= take
		changed = changed or take > 0
		if item.quantity <= 0:
			break
	return changed


func _place_item_in_empty_slot(items: Array, item: ItemData) -> bool:
	var empty_index: int = find_empty_slot(items)
	if empty_index < 0:
		return false
	items[empty_index] = item
	return true


func _emit_inventory_changed_if_needed(changed: bool) -> void:
	if changed:
		inventory_changed.emit()
