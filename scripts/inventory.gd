extends Node

const HOTBAR_SIZE = 9
const BAG_SIZE = 27  # 3 行 x 9 列

var hotbar: Array = []
var bag: Array = []
var selected_slot: int = 0

signal inventory_changed

func _ready() -> void:
	hotbar.resize(HOTBAR_SIZE)
	bag.resize(BAG_SIZE)
	hotbar.fill(null)
	bag.fill(null)

# 自动放入背包，优先堆叠，其次空格，先物品栏再背包
func add_item(item: ItemData) -> bool:
	# 尝试在物品栏堆叠
	for i in HOTBAR_SIZE:
		if hotbar[i] != null and hotbar[i].item_id == item.item_id \
				and hotbar[i].quantity < hotbar[i].max_stack:
			var space = hotbar[i].max_stack - hotbar[i].quantity
			var take = min(space, item.quantity)
			hotbar[i].quantity += take
			item.quantity -= take
			if item.quantity <= 0:
				inventory_changed.emit()
				return true
	# 尝试在背包堆叠
	for i in BAG_SIZE:
		if bag[i] != null and bag[i].item_id == item.item_id \
				and bag[i].quantity < bag[i].max_stack:
			var space = bag[i].max_stack - bag[i].quantity
			var take = min(space, item.quantity)
			bag[i].quantity += take
			item.quantity -= take
			if item.quantity <= 0:
				inventory_changed.emit()
				return true
	# 找空的物品栏格子
	for i in HOTBAR_SIZE:
		if hotbar[i] == null:
			hotbar[i] = item
			inventory_changed.emit()
			return true
	# 找空的背包格子
	for i in BAG_SIZE:
		if bag[i] == null:
			bag[i] = item
			inventory_changed.emit()
			return true
	return false  # 背包已满

func remove_hotbar(index: int) -> ItemData:
	var item = hotbar[index]
	hotbar[index] = null
	if item:
		inventory_changed.emit()
	return item

func remove_bag(index: int) -> ItemData:
	var item = bag[index]
	bag[index] = null
	if item:
		inventory_changed.emit()
	return item

func get_selected() -> ItemData:
	return hotbar[selected_slot]

func scroll_select(dir: int) -> void:
	selected_slot = (selected_slot + dir + HOTBAR_SIZE) % HOTBAR_SIZE
	inventory_changed.emit()

func drop_selected() -> ItemData:
	var item = hotbar[selected_slot]
	hotbar[selected_slot] = null
	if item:
		inventory_changed.emit()
	return item

# 交换两个背包格子
func swap_bag(a: int, b: int) -> void:
	var tmp = bag[a]
	bag[a] = bag[b]
	bag[b] = tmp
	inventory_changed.emit()

# 交换两个物品栏格子
func swap_hotbar(a: int, b: int) -> void:
	var tmp = hotbar[a]
	hotbar[a] = hotbar[b]
	hotbar[b] = tmp
	inventory_changed.emit()

# 背包格子和物品栏格子互换
func swap_bag_hotbar(bag_idx: int, hotbar_idx: int) -> void:
	var tmp = hotbar[hotbar_idx]
	hotbar[hotbar_idx] = bag[bag_idx]
	bag[bag_idx] = tmp
	inventory_changed.emit()
