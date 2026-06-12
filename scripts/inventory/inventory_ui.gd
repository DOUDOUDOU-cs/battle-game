extends CanvasLayer

const SLOT_SIZE  = 52
const SLOT_GAP   = 4
const HPAD       = 14
const VPAD       = 12
const BORDER_W   = 8
const BAG_COLS   = 9
const BAG_ROWS   = 3

const C_SLOT_BG    = Color(0.18,0.13,0.06,0.80)
const C_SLOT_BOR   = Color(0.55,0.38,0.08,0.95)
const C_HOTBAR_BG  = Color(0.08,0.05,0.02,0.90)
const C_BAG_OUT    = Color(0.28,0.16,0.03,1.00)
const C_BAG_FRAME  = Color(0.55,0.38,0.08,1.00)
const C_BAG_IN     = Color(0.20,0.13,0.04,0.97)
const C_BAG_SLOT   = Color(0.16,0.10,0.03,0.90)
const C_SEP        = Color(0.58,0.40,0.10,0.80)
const C_TITLE      = Color(0.98,0.85,0.40,1.00)
const C_TEXT       = Color(0.90,0.82,0.58,1.00)
const C_SEL        = Color(0.78,0.58,0.14,0.45)
const C_CRAFT_SLOT = Color(0.14,0.20,0.08,0.90)

var _hotbar_root : Control
var _bag_panel   : Control
var _close_btn   : Button
var _drag_icon   : Control
var _drag_bg     : ColorRect
var _drag_lbl    : Label
var _drag_draw   : InventoryItemIconDrawer

var _hotbar_slots : Array = []
var _bag_slots    : Array = []
var _bh_slots     : Array = []
var _hotbar_rects : Array = []
var _bag_rects    : Array = []
var _bh_rects     : Array = []

var _craft_slots       : Array = []
var _craft_rects       : Array = []
var _craft_result_slot : Dictionary = {}
var _craft_result_rect : Rect2 = Rect2()
var _craft_state       : InventoryCraftState = InventoryCraftState.new()
var _ui_state         : InventoryUIState = InventoryUIState.new()
const DOUBLE_CLICK_SEC := 0.35


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_state.viewport_size = get_viewport().get_visible_rect().size
	_build_hotbar()
	_build_bag()
	_build_drag_icon()
	Inventory.inventory_changed.connect(_refresh)
	_refresh()


func _build_hotbar() -> void:
	var cw := BAG_COLS*(SLOT_SIZE+SLOT_GAP)-SLOT_GAP + HPAD*2
	var ch := SLOT_SIZE + VPAD*2
	_hotbar_root = Control.new()
	_hotbar_root.size = Vector2(cw, ch)
	_hotbar_root.position = Vector2((_ui_state.viewport_size.x-cw)*0.5, _ui_state.viewport_size.y-ch-10.0)
	_hotbar_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hotbar_root)
	var bg_outer := ColorRect.new()
	bg_outer.size = Vector2(cw,ch); bg_outer.color = C_BAG_OUT
	bg_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotbar_root.add_child(bg_outer)
	var bg_frame := ColorRect.new()
	bg_frame.position = Vector2(2,2)
	bg_frame.size = Vector2(cw-4,ch-4); bg_frame.color = C_BAG_FRAME
	bg_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotbar_root.add_child(bg_frame)
	var bg_inner := ColorRect.new()
	bg_inner.position = Vector2(4,4)
	bg_inner.size = Vector2(cw-8,ch-8); bg_inner.color = C_HOTBAR_BG
	bg_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotbar_root.add_child(bg_inner)
	var vine := InventoryVineDrawer.new()
	vine.size = _hotbar_root.size
	vine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotbar_root.add_child(vine)
	for i in Inventory.HOTBAR_SIZE:
		var lx := HPAD + i*(SLOT_SIZE+SLOT_GAP)
		_hotbar_slots.append(
			InventoryWidgetFactory.make_slot(
				_hotbar_root,
				Vector2(lx, VPAD),
				C_SLOT_BG,
				SLOT_SIZE,
				C_SLOT_BOR,
				C_TEXT
			)
		)
		_hotbar_rects.append(Rect2(_hotbar_root.position+Vector2(lx,VPAD), Vector2(SLOT_SIZE,SLOT_SIZE)))


func _build_bag() -> void:
	var gw := BAG_COLS*(SLOT_SIZE+SLOT_GAP)-SLOT_GAP
	var craft_extra := 2*(SLOT_SIZE+SLOT_GAP) + 32 + SLOT_SIZE + 20
	var pw := gw + (HPAD+BORDER_W)*2 + craft_extra
	var gh := BAG_ROWS*(SLOT_SIZE+SLOT_GAP)-SLOT_GAP
	var ph := BORDER_W*2 + VPAD + 34 + 10 + gh + 16 + SLOT_SIZE + VPAD
	_bag_panel = Control.new()
	_bag_panel.size = Vector2(pw,ph)
	_bag_panel.position = Vector2((_ui_state.viewport_size.x-pw)*0.5, (_ui_state.viewport_size.y-ph)*0.5)
	_bag_panel.visible = false
	_bag_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bag_panel)
	var outer := ColorRect.new()
	outer.size = Vector2(pw,ph); outer.color = C_BAG_OUT
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(outer)
	var frame := ColorRect.new()
	frame.position = Vector2(3,3)
	frame.size = Vector2(pw-6,ph-6); frame.color = C_BAG_FRAME
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(frame)
	var inner := ColorRect.new()
	inner.position = Vector2(BORDER_W,BORDER_W)
	inner.size = Vector2(pw-BORDER_W*2,ph-BORDER_W*2); inner.color = C_BAG_IN
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(inner)
	for cp in [Vector2(0,0), Vector2(pw-14,0), Vector2(0,ph-14), Vector2(pw-14,ph-14)]:
		var ca := ColorRect.new()
		ca.position = cp; ca.size = Vector2(14,14); ca.color = C_BAG_FRAME
		ca.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bag_panel.add_child(ca)
		var ca2 := ColorRect.new()
		ca2.position = cp+Vector2(3,3); ca2.size = Vector2(8,8); ca2.color = Color(0.75,0.52,0.12,1.0)
		ca2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bag_panel.add_child(ca2)
	var title := Label.new()
	title.text = "Inventory"
	title.position = Vector2(BORDER_W, BORDER_W+VPAD)
	title.size = Vector2(pw-BORDER_W*2, 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", C_TITLE)
	title.add_theme_font_size_override("font_size", 22)
	_bag_panel.add_child(title)
	var sep_top := ColorRect.new()
	sep_top.position = Vector2(BORDER_W, BORDER_W+VPAD+34+4)
	sep_top.size = Vector2(pw-BORDER_W*2, 2); sep_top.color = C_SEP
	sep_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(sep_top)
	_close_btn = Button.new()
	_close_btn.text = "x"
	_close_btn.position = Vector2(pw-BORDER_W-30, BORDER_W+6)
	_close_btn.size = Vector2(26,26)
	_close_btn.flat = true
	_close_btn.add_theme_color_override("font_color", C_TITLE)
	_close_btn.pressed.connect(_toggle_bag)
	_bag_panel.add_child(_close_btn)
	var vine := InventoryVineDrawer.new()
	vine.size = _bag_panel.size
	vine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(vine)
	var gx := BORDER_W + HPAD
	var gy := BORDER_W + VPAD + 34 + 10
	for row in BAG_ROWS:
		for col in BAG_COLS:
			var lx := gx + col*(SLOT_SIZE+SLOT_GAP)
			var ly := gy + row*(SLOT_SIZE+SLOT_GAP)
			_bag_slots.append(
				InventoryWidgetFactory.make_slot(
					_bag_panel,
					Vector2(lx, ly),
					C_BAG_SLOT,
					SLOT_SIZE,
					C_SLOT_BOR,
					C_TEXT
				)
			)
			_bag_rects.append(Rect2(_bag_panel.position+Vector2(lx,ly), Vector2(SLOT_SIZE,SLOT_SIZE)))
	var sep := ColorRect.new()
	sep.position = Vector2(gx, gy+gh+7)
	sep.size = Vector2(gw,2); sep.color = C_SEP
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(sep)
	var bh_y := gy+gh+14
	for i in Inventory.HOTBAR_SIZE:
		var lx := gx+i*(SLOT_SIZE+SLOT_GAP)
		_bh_slots.append(
			InventoryWidgetFactory.make_slot(
				_bag_panel,
				Vector2(lx, bh_y),
				C_BAG_SLOT,
				SLOT_SIZE,
				C_SLOT_BOR,
				C_TEXT
			)
		)
		_bh_rects.append(Rect2(_bag_panel.position+Vector2(lx,bh_y), Vector2(SLOT_SIZE,SLOT_SIZE)))
	var craft_panel: Dictionary = InventoryWidgetFactory.build_craft_panel(
		_bag_panel,
		_bag_panel.position,
		gx,
		gy,
		gw,
		SLOT_SIZE,
		SLOT_GAP,
		C_TITLE,
		C_CRAFT_SLOT,
		C_SLOT_BOR,
		C_TEXT
	)
	_craft_slots = craft_panel["slots"]
	_craft_rects = craft_panel["rects"]
	_craft_result_slot = craft_panel["result_slot"]
	_craft_result_rect = craft_panel["result_rect"]


func _build_drag_icon() -> void:
	var drag_icon_parts: Dictionary = InventoryWidgetFactory.build_drag_icon(self, SLOT_SIZE, C_TEXT)
	_drag_icon = drag_icon_parts["root"]
	_drag_bg = drag_icon_parts["bg"]
	_drag_draw = drag_icon_parts["draw"]
	_drag_lbl = drag_icon_parts["lbl"]


func _refresh() -> void:
	for i in Inventory.HOTBAR_SIZE:
		_update_slot(_hotbar_slots[i], Inventory.get_slot_item("hotbar", i), i == Inventory.selected_slot)
	if _ui_state.bag_open:
		for i in Inventory.BAG_SIZE:
			_update_slot(_bag_slots[i], Inventory.get_slot_item("bag", i), false)
		for i in Inventory.HOTBAR_SIZE:
			_update_slot(_bh_slots[i], Inventory.get_slot_item("bh", i), i == Inventory.selected_slot)
		_refresh_craft()


func _update_slot(slot: Dictionary, item: ItemData, selected: bool) -> void:
	slot["draw"].set_item(item.item_id if item != null else "")
	slot["lbl"].text = str(item.quantity) if (item != null and item.quantity > 1) else ""
	slot["sel"].color = C_SEL if selected else Color(0,0,0,0)


func _get_slot_item(src: String, idx: int) -> ItemData:
	return InventorySlotService.get_slot_item(src, idx, _craft_state)


func _set_slot_item(src: String, idx: int, item: ItemData) -> void:
	InventorySlotService.set_slot_item(src, idx, item, _craft_state)
	if src == "craft":
		_refresh_craft()


func _update_cursor_icon() -> void:
	if _ui_state.cursor_item == null:
		_drag_icon.visible = false
		return
	_drag_draw.set_item(_ui_state.cursor_item.item_id)
	_drag_lbl.text = str(_ui_state.cursor_item.quantity) if _ui_state.cursor_item.quantity > 1 else ""
	_drag_icon.visible = true


func _clear_cursor() -> void:
	_ui_state.clear_cursor()
	_drag_icon.visible = false


func _reset_drag_state() -> void:
	_ui_state.reset_drag_state()


func _stash_cursor_item() -> void:
	if _ui_state.cursor_item == null:
		return

	_ui_state.cursor_item = InventorySlotService.stash_cursor_item(
		_ui_state.cursor_item,
		_ui_state.cursor_src,
		_ui_state.cursor_idx,
		_craft_state
	)
	if _ui_state.cursor_item == null:
		_clear_cursor()
	else:
		_update_cursor_icon()


func _process(_delta: float) -> void:
	if _ui_state.cursor_item != null:
		var mp: Vector2 = get_viewport().get_mouse_position()
		_drag_icon.position = mp - Vector2(SLOT_SIZE*0.5, SLOT_SIZE*0.5)
		if _ui_state.drag_active:
			var res: Dictionary = _slot_at(mp)
			if not res.is_empty() and res.get("src") != "craft_result":
				var already: bool = false
				for s in _ui_state.drag_slots:
					if s["src"] == res["src"] and s["idx"] == res["idx"]:
						already = true
						break
				if not already:
					_ui_state.drag_slots.append(res)


func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		var mbe: InputEventMouseButton = ev as InputEventMouseButton
		var mp: Vector2 = mbe.position
		match mbe.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if mbe.pressed:
					Inventory.scroll_select(-1)
					get_viewport().set_input_as_handled()
			MOUSE_BUTTON_WHEEL_DOWN:
				if mbe.pressed:
					Inventory.scroll_select(1)
					get_viewport().set_input_as_handled()
			MOUSE_BUTTON_LEFT:
				if mbe.pressed:
					_on_lmb_press(mp, mbe.shift_pressed)
				else:
					_on_lmb_release(mp)
	elif ev is InputEventKey:
		var ike: InputEventKey = ev as InputEventKey
		if ike.pressed and not ike.echo:
			var slot_index: int = _hotbar_key_to_index(ike.physical_keycode)
			if slot_index >= 0:
				Inventory.select_slot(slot_index)
				get_viewport().set_input_as_handled()
			elif ike.physical_keycode == KEY_I or ike.physical_keycode == KEY_E:
				_toggle_bag()
				get_viewport().set_input_as_handled()
			elif ike.physical_keycode == KEY_Q and not _ui_state.bag_open:
				_drop_selected()
				get_viewport().set_input_as_handled()


func _hotbar_key_to_index(physical_keycode: Key) -> int:
	match physical_keycode:
		KEY_1:
			return 0
		KEY_2:
			return 1
		KEY_3:
			return 2
		KEY_4:
			return 3
		KEY_5:
			return 4
		KEY_6:
			return 5
		KEY_7:
			return 6
		KEY_8:
			return 7
		KEY_9:
			return 8
		_:
			return -1


func _toggle_bag() -> void:
	if _ui_state.bag_open:
		_close_bag()
	else:
		_open_bag()


func _open_bag() -> void:
	_ui_state.bag_open = true
	_bag_panel.visible = true
	if not get_tree().paused:
		get_tree().paused = true
		_ui_state.paused_by_bag = true
	_refresh()


func _close_bag() -> void:
	if _ui_state.cursor_item != null:
		_stash_cursor_item()
		Inventory.inventory_changed.emit()
		if _ui_state.cursor_item != null:
			return

	_ui_state.bag_open = false
	_bag_panel.visible = false
	if _ui_state.paused_by_bag:
		get_tree().paused = false
		_ui_state.paused_by_bag = false
	_reset_drag_state()
	_ui_state.reset_click_state()


func _drop_selected() -> void:
	var item: ItemData = Inventory.drop_selected()
	if item == null:
		return
	_spawn_drop(item)


func _on_lmb_press(mp: Vector2, shift: bool) -> void:
	if _is_close_button_hit(mp):
		_toggle_bag()
		get_viewport().set_input_as_handled()
		return

	var route: Dictionary = InventoryInputRouter.begin_slot_interaction(
		mp,
		_ui_state.bag_open,
		_ui_state.cursor_item,
		shift,
		_slot_at
	)
	if not route["handled"]:
		return
	var res: Dictionary = route["slot"]
	if route["stash_cursor"]:
		if _ui_state.cursor_item != null:
			_stash_cursor_item()
			Inventory.inventory_changed.emit()
		return
	if route["shift_click"]:
		_shift_click(res["src"], res["idx"])
		get_viewport().set_input_as_handled()
		return
	_reset_drag_state()
	if route["set_drag_origin"]:
		_ui_state.drag_origin = res
	get_viewport().set_input_as_handled()


func _on_lmb_release(mp: Vector2) -> void:
	var route: Dictionary = InventoryInputRouter.finish_slot_interaction(
		mp,
		_ui_state.bag_open,
		_ui_state.drag_active,
		_ui_state.cursor_item,
		_ui_state.drag_slots,
		_ui_state.last_click_time,
		_ui_state.last_click_slot,
		DOUBLE_CLICK_SEC,
		_slot_at
	)
	if not route["handled"]:
		return
	if route["action"] == "finish_drag":
		_finish_drag_distribute()
		get_viewport().set_input_as_handled()
		return
	_ui_state.drag_active = false
	_ui_state.drag_slots = []
	_ui_state.last_click_time = route["next_click_time"]
	_ui_state.last_click_slot = route["next_click_slot"]
	var res: Dictionary = route["slot"]
	if route["action"] == "stash_cursor":
		if _ui_state.cursor_item != null:
			_stash_cursor_item()
			Inventory.inventory_changed.emit()
		return
	if route["action"] == "double_click":
		_double_click(res["src"], res["idx"])
		get_viewport().set_input_as_handled()
		return
	if res.is_empty():
		return
	_left_click(res["src"], res["idx"])
	get_viewport().set_input_as_handled()


func _left_click(src: String, idx: int) -> void:
	if src == "craft_result":
		return
	var result: Dictionary = InventorySlotService.apply_left_click(
		src,
		idx,
		_ui_state.cursor_item,
		_ui_state.cursor_src,
		_ui_state.cursor_idx,
		_craft_state
	)
	_ui_state.cursor_item = result["cursor_item"]
	_ui_state.cursor_src = result["cursor_src"]
	_ui_state.cursor_idx = result["cursor_idx"]
	_ui_state.drag_active = result["drag_active"]
	_ui_state.drag_slots = result["drag_slots"]
	_ui_state.drag_origin = result["drag_origin"]
	if _ui_state.cursor_item == null:
		_clear_cursor()
	else:
		_update_cursor_icon()
	if result["inventory_changed"]:
		Inventory.inventory_changed.emit()
	if src == "craft":
		_refresh_craft()


func _finish_drag_distribute() -> void:
	if _ui_state.cursor_item == null or _ui_state.drag_slots.size() == 0:
		_reset_drag_state()
		return
	var result: Dictionary = InventorySlotService.distribute_drag(
		_ui_state.cursor_item,
		_ui_state.drag_slots,
		_ui_state.drag_origin,
		_craft_state
	)
	_ui_state.cursor_item = result["cursor_item"]
	if _ui_state.cursor_item != null:
		_update_cursor_icon()
	else:
		_clear_cursor()
	if result["inventory_changed"]:
		Inventory.inventory_changed.emit()
	_refresh_craft()
	_reset_drag_state()


func _shift_click(src: String, idx: int) -> void:
	InventorySlotService.shift_click(src, idx, _craft_state)
	Inventory.inventory_changed.emit()
	if src == "craft":
		_refresh_craft()


func _double_click(src: String, idx: int) -> void:
	InventorySlotService.double_click(_ui_state.cursor_item, src, idx)
	_update_cursor_icon()
	Inventory.inventory_changed.emit()


func _refresh_craft() -> void:
	for i in 4:
		_update_slot(_craft_slots[i], _craft_state.get_item(i), false)


func _spawn_drop(item: ItemData) -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
	var scene: Node = get_tree().current_scene
	if player == null or scene == null:
		return
	var drop_scene: PackedScene = preload("res://scenes/drops/item_drop.tscn")
	var drop: Node2D = drop_scene.instantiate() as Node2D
	var dir: Vector2 = Vector2(1.0 if player.facing_right else -1.0, 0.0)
	drop.position = player.global_position + dir * 50.0
	scene.add_child(drop)
	drop._land_y = drop.position.y + 90.0
	drop.setup(item, dir)


func _slot_at(mp: Vector2) -> Dictionary:
	return InventorySlotService.find_slot_at(
		mp,
		_ui_state.bag_open,
		_hotbar_rects,
		_bag_rects,
		_bh_rects,
		_craft_rects,
		_craft_result_rect
	)

func _is_close_button_hit(mp: Vector2) -> bool:
	return (
		_ui_state.bag_open
		and _close_btn != null
		and _close_btn.visible
		and _close_btn.get_global_rect().has_point(mp)
	)
