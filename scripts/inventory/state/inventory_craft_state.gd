class_name InventoryCraftState
extends RefCounted

var items: Array = [null, null, null, null]

func get_item(idx: int) -> ItemData:
	return items[idx]

func set_item(idx: int, item: ItemData) -> void:
	items[idx] = item

func clear() -> void:
	items = [null, null, null, null]
