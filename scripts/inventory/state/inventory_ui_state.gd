class_name InventoryUIState
extends RefCounted

var bag_open: bool = false
var paused_by_bag: bool = false
var viewport_size: Vector2 = Vector2.ZERO

var cursor_item: ItemData = null
var cursor_src: String = ""
var cursor_idx: int = -1

var drag_active: bool = false
var drag_slots: Array = []
var drag_origin: Dictionary = {}

var last_click_time: float = -1.0
var last_click_slot: Dictionary = {}


func clear_cursor() -> void:
	cursor_item = null
	cursor_src = ""
	cursor_idx = -1


func reset_drag_state() -> void:
	drag_active = false
	drag_slots = []
	drag_origin = {}


func reset_click_state() -> void:
	last_click_time = -1.0
	last_click_slot = {}

