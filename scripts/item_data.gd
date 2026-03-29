class_name ItemData
extends Resource

@export var item_id: String = ""
@export var item_name: String = "物品"
@export var icon: Texture2D = null
@export var quantity: int = 1
@export var max_stack: int = 64
@export var description: String = ""

func duplicate_item() -> ItemData:
	var copy = ItemData.new()
	copy.item_id = item_id
	copy.item_name = item_name
	copy.icon = icon
	copy.quantity = quantity
	copy.max_stack = max_stack
	copy.description = description
	return copy
