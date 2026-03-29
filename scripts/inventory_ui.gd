extends CanvasLayer

class ItemIconDrawer extends Control:
	var item_id: String = ""
	func set_item(id: String) -> void:
		item_id = id
		queue_redraw()
	func _draw() -> void:
		if item_id == "":
			return
		var s := size
		var cx := s.x * 0.5
		var cy := s.y * 0.5
		match item_id:
			"mushroom":
				draw_rect(Rect2(cx-4, cy+2, 8, 10), Color(0.95,0.90,0.75))
				draw_rect(Rect2(cx-4, cy+2, 2, 10), Color(0.75,0.70,0.55))
				for i in range(-7, 8):
					var hx := float(i)
					var hy := -sqrt(max(0.0, 49.0 - hx*hx))
					if hy < 0:
						draw_circle(Vector2(cx+hx, cy+2+hy*0.55), 1.5, Color(0.85,0.15,0.1))
				draw_circle(Vector2(cx-3, cy-3), 2.0, Color(1,1,1,0.9))
				draw_circle(Vector2(cx+3, cy-5), 1.5, Color(1,1,1,0.9))
			"slime_gel":
				draw_circle(Vector2(cx, cy+4), 8.0, Color(0.2,0.75,0.55,0.9))
				draw_circle(Vector2(cx, cy-1), 5.5, Color(0.25,0.80,0.60,0.9))
				draw_circle(Vector2(cx, cy-6), 2.5, Color(0.30,0.82,0.62,0.85))
				draw_circle(Vector2(cx-3, cy+1), 2.0, Color(0.9,1.0,0.95,0.5))
				draw_circle(Vector2(cx-2, cy-2), 1.2, Color(1,1,1,0.55))
			_:
				draw_rect(Rect2(cx-8, cy-8, 16, 16), Color(0.72,0.55,0.10,0.90))

class VineDrawer extends Control:
	func _draw() -> void:
		var w := size.x
		var h := size.y
		_vine_h(Vector2(6,7), Vector2(w-6,7), Vector2(0,1), 0)
		_vine_h(Vector2(6,h-7), Vector2(w-6,h-7), Vector2(0,-1), 1)
		_vine_v(Vector2(7,6), Vector2(7,h-6), Vector2(1,0), 2)
		_vine_v(Vector2(w-7,6), Vector2(w-7,h-6), Vector2(-1,0), 3)

	func _vine_h(p0:Vector2, p1:Vector2, nrm:Vector2, si:int) -> void:
		var n := int(p0.distance_to(p1)/6.0)+1
		var pts := PackedVector2Array()
		for i in n+1:
			var t := float(i)/n
			pts.append(p0.lerp(p1,t)+Vector2(0, sin(t*TAU*2.5+si*1.7)*3.0))
		draw_polyline(pts, Color(0.06,0.18,0.03,0.95), 2.8, true)
		draw_polyline(pts, Color(0.20,0.50,0.10,0.65), 1.2, true)
		_leaves(pts, nrm, si)

	func _vine_v(p0:Vector2, p1:Vector2, nrm:Vector2, si:int) -> void:
		var n := int(p0.distance_to(p1)/6.0)+1
		var pts := PackedVector2Array()
		for i in n+1:
			var t := float(i)/n
			pts.append(p0.lerp(p1,t)+Vector2(sin(t*TAU*2.0+si*1.3)*3.0, 0))
		draw_polyline(pts, Color(0.06,0.18,0.03,0.95), 2.2, true)
		draw_polyline(pts, Color(0.20,0.50,0.10,0.65), 1.0, true)
		_leaves(pts, nrm, si)

	func _leaves(pts:PackedVector2Array, nrm:Vector2, si:int) -> void:
		var cnt := pts.size()
		var step : int = max(1, cnt/9)
		var li := 0
		var idx : int = step/2

		while idx < cnt-1:
			var lp := pts[idx]
			var side := 1.0 if li%2==0 else -1.0
			var sz := 5.0 + fmod(float((li+si)*7+3), 3.5)
			_leaf(lp, nrm*side, sz)
			if li%3 == si%3:
				var bp := lp + nrm*side*(sz+4.0)
				draw_circle(bp, 2.5, Color(0.50,0.08,0.08,0.9))
				draw_circle(bp, 1.2, Color(0.85,0.22,0.12,0.85))
			if li%4 == (si+1)%4:
				var tp := pts[min(idx+step/2, cnt-1)]
				_tendril(lp, tp+nrm*side*8.0)
			idx += step
			li += 1

	func _leaf(pos:Vector2, ld:Vector2, sz:float) -> void:
		var d := ld.normalized()
		var p := Vector2(-d.y, d.x)
		var poly := PackedVector2Array([pos+p*sz*0.4, pos+d*sz, pos-p*sz*0.4, pos])
		draw_colored_polygon(poly, Color(0.10,0.32,0.06,0.90))
		draw_line(pos, pos+d*sz, Color(0.20,0.55,0.12,0.6), 0.8, true)

	func _tendril(p0:Vector2, p1:Vector2) -> void:
		var pts := PackedVector2Array()
		var perp := (p1-p0).normalized().rotated(PI*0.5)
		for i in 8:
			var t := float(i)/7.0
			pts.append(p0.lerp(p1,t) + perp*sin(t*PI*2.0)*4.0*(1.0-t))
		draw_polyline(pts, Color(0.12,0.35,0.07,0.6), 0.9, true)

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
var _drag_icon   : Control
var _drag_bg     : ColorRect
var _drag_lbl    : Label
var _drag_draw   : ItemIconDrawer

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
var _craft_items       : Array = [null, null, null, null]

var _bag_open      := false
var _paused_by_bag := false
var _vp            : Vector2

var _sel_item : ItemData = null
var _sel_src  : String = ""
var _sel_idx  : int = -1

var _drag_active    : bool       = false
var _drag_slots     : Array      = []
var _drag_origin    : Dictionary = {}

var _last_click_time : float      = -1.0
var _last_click_slot : Dictionary = {}
const DOUBLE_CLICK_SEC := 0.35


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_vp = get_viewport().get_visible_rect().size
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
	_hotbar_root.position = Vector2((_vp.x-cw)*0.5, _vp.y-ch-10.0)
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
	var vine := VineDrawer.new()
	vine.size = _hotbar_root.size
	vine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotbar_root.add_child(vine)
	for i in Inventory.HOTBAR_SIZE:
		var lx := HPAD + i*(SLOT_SIZE+SLOT_GAP)
		_hotbar_slots.append(_make_slot(_hotbar_root, Vector2(lx,VPAD), C_SLOT_BG))
		_hotbar_rects.append(Rect2(_hotbar_root.position+Vector2(lx,VPAD), Vector2(SLOT_SIZE,SLOT_SIZE)))


func _build_bag() -> void:
	var gw := BAG_COLS*(SLOT_SIZE+SLOT_GAP)-SLOT_GAP
	var craft_extra := 2*(SLOT_SIZE+SLOT_GAP) + 32 + SLOT_SIZE + 20
	var pw := gw + (HPAD+BORDER_W)*2 + craft_extra
	var gh := BAG_ROWS*(SLOT_SIZE+SLOT_GAP)-SLOT_GAP
	var ph := BORDER_W*2 + VPAD + 34 + 10 + gh + 16 + SLOT_SIZE + VPAD
	_bag_panel = Control.new()
	_bag_panel.size = Vector2(pw,ph)
	_bag_panel.position = Vector2((_vp.x-pw)*0.5, (_vp.y-ph)*0.5)
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
	title.text = "背  包"
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
	var close_btn := Button.new()
	close_btn.text = "x"
	close_btn.position = Vector2(pw-BORDER_W-30, BORDER_W+6)
	close_btn.size = Vector2(26,26)
	close_btn.flat = true
	close_btn.add_theme_color_override("font_color", C_TITLE)
	close_btn.pressed.connect(_toggle_bag)
	_bag_panel.add_child(close_btn)
	var vine := VineDrawer.new()
	vine.size = _bag_panel.size
	vine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(vine)
	var gx := BORDER_W + HPAD
	var gy := BORDER_W + VPAD + 34 + 10
	for row in BAG_ROWS:
		for col in BAG_COLS:
			var lx := gx + col*(SLOT_SIZE+SLOT_GAP)
			var ly := gy + row*(SLOT_SIZE+SLOT_GAP)
			_bag_slots.append(_make_slot(_bag_panel, Vector2(lx,ly), C_BAG_SLOT))
			_bag_rects.append(Rect2(_bag_panel.position+Vector2(lx,ly), Vector2(SLOT_SIZE,SLOT_SIZE)))
	var sep := ColorRect.new()
	sep.position = Vector2(gx, gy+gh+7)
	sep.size = Vector2(gw,2); sep.color = C_SEP
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bag_panel.add_child(sep)
	var bh_y := gy+gh+14
	for i in Inventory.HOTBAR_SIZE:
		var lx := gx+i*(SLOT_SIZE+SLOT_GAP)
		_bh_slots.append(_make_slot(_bag_panel, Vector2(lx,bh_y), C_BAG_SLOT))
		_bh_rects.append(Rect2(_bag_panel.position+Vector2(lx,bh_y), Vector2(SLOT_SIZE,SLOT_SIZE)))
	_build_craft_inside_bag(gx, gy, gw)


func _build_craft_inside_bag(gx:int, gy:int, gw:int) -> void:
	var cx_start := gx + gw + 16
	var cy_start := gy
	var lbl := Label.new()
	lbl.text = "製  作"
	lbl.position = Vector2(cx_start, cy_start - 24)
	lbl.size = Vector2(2*(SLOT_SIZE+SLOT_GAP)+20, 20)
	lbl.add_theme_color_override("font_color", C_TITLE)
	lbl.add_theme_font_size_override("font_size", 14)
	_bag_panel.add_child(lbl)
	for i in 4:
		var col := i % 2
		var row := i / 2
		var lx := cx_start + col*(SLOT_SIZE+SLOT_GAP)
		var ly := cy_start + row*(SLOT_SIZE+SLOT_GAP)
		_craft_slots.append(_make_slot(_bag_panel, Vector2(lx,ly), C_CRAFT_SLOT))
		_craft_rects.append(Rect2(_bag_panel.position+Vector2(lx,ly), Vector2(SLOT_SIZE,SLOT_SIZE)))
	var arrow_lbl := Label.new()
	arrow_lbl.text = "→"
	arrow_lbl.position = Vector2(cx_start + 2*(SLOT_SIZE+SLOT_GAP)+2, cy_start + SLOT_SIZE*0.5 - 12)
	arrow_lbl.size = Vector2(28, 28)
	arrow_lbl.add_theme_color_override("font_color", C_TITLE)
	arrow_lbl.add_theme_font_size_override("font_size", 22)
	_bag_panel.add_child(arrow_lbl)
	var rx := cx_start + 2*(SLOT_SIZE+SLOT_GAP) + 32
	var ry := cy_start + SLOT_SIZE*0.5 - SLOT_SIZE*0.5
	_craft_result_slot = _make_slot(_bag_panel, Vector2(rx,ry), C_CRAFT_SLOT)
	_craft_result_rect = Rect2(_bag_panel.position+Vector2(rx,ry), Vector2(SLOT_SIZE,SLOT_SIZE))


func _build_drag_icon() -> void:
	_drag_icon = Control.new()
	_drag_icon.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	_drag_icon.visible = false
	_drag_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_icon.z_index = 100
	add_child(_drag_icon)
	_drag_bg = ColorRect.new()
	_drag_bg.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	_drag_bg.color = Color(0.4, 0.3, 0.1, 0.7)
	_drag_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_icon.add_child(_drag_bg)
	_drag_draw = ItemIconDrawer.new()
	_drag_draw.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	_drag_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_icon.add_child(_drag_draw)
	_drag_lbl = Label.new()
	_drag_lbl.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	_drag_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_drag_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_drag_lbl.add_theme_color_override("font_color", C_TEXT)
	_drag_lbl.add_theme_font_size_override("font_size", 14)
	_drag_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_icon.add_child(_drag_lbl)


func _make_slot(parent: Control, pos: Vector2, bg_col: Color) -> Dictionary:
	var c := Control.new()
	c.position = pos
	c.size = Vector2(SLOT_SIZE, SLOT_SIZE)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	var bg := ColorRect.new()
	bg.size = Vector2(SLOT_SIZE, SLOT_SIZE); bg.color = bg_col
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bg)
	var bor := ColorRect.new()
	bor.size = Vector2(SLOT_SIZE, SLOT_SIZE); bor.color = C_SLOT_BOR
	bor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bor)
	var bor2 := ColorRect.new()
	bor2.position = Vector2(2,2)
	bor2.size = Vector2(SLOT_SIZE-4, SLOT_SIZE-4); bor2.color = bg_col
	bor2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(bor2)
	var draw := ItemIconDrawer.new()
	draw.position = Vector2(4,4)
	draw.size = Vector2(SLOT_SIZE-8, SLOT_SIZE-8)
	draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(draw)
	var lbl := Label.new()
	lbl.size = Vector2(SLOT_SIZE-2, SLOT_SIZE-2)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	lbl.add_theme_color_override("font_color", C_TEXT)
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(lbl)
	var sel := ColorRect.new()
	sel.size = Vector2(SLOT_SIZE, SLOT_SIZE); sel.color = Color(0,0,0,0)
	sel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(sel)
	return {"root": c, "bg": bg, "draw": draw, "lbl": lbl, "sel": sel}


func _refresh() -> void:
	for i in Inventory.HOTBAR_SIZE:
		_update_slot(_hotbar_slots[i], Inventory.hotbar[i], i == Inventory.selected_slot)
	if _bag_open:
		for i in Inventory.BAG_SIZE:
			_update_slot(_bag_slots[i], Inventory.bag[i], false)
		for i in Inventory.HOTBAR_SIZE:
			_update_slot(_bh_slots[i], Inventory.hotbar[i], i == Inventory.selected_slot)
		_refresh_craft()


func _update_slot(slot: Dictionary, item: ItemData, selected: bool) -> void:
	slot["draw"].set_item(item.item_id if item != null else "")
	slot["lbl"].text = str(item.quantity) if (item != null and item.quantity > 1) else ""
	slot["sel"].color = C_SEL if selected else Color(0,0,0,0)


func _get_slot_item(src: String, idx: int) -> ItemData:
	if src == "hotbar" or src == "bh":
		return Inventory.hotbar[idx]
	elif src == "bag":
		return Inventory.bag[idx]
	elif src == "craft":
		return _craft_items[idx]
	return null


func _set_slot_item(src: String, idx: int, item: ItemData) -> void:
	if src == "hotbar" or src == "bh":
		Inventory.hotbar[idx] = item
	elif src == "bag":
		Inventory.bag[idx] = item
	elif src == "craft":
		_craft_items[idx] = item
		_refresh_craft()


func _update_cursor_icon() -> void:
	if _sel_item == null:
		_drag_icon.visible = false
		return
	_drag_draw.set_item(_sel_item.item_id)
	_drag_lbl.text = str(_sel_item.quantity) if _sel_item.quantity > 1 else ""
	_drag_icon.visible = true


func _clear_cursor() -> void:
	_sel_item = null
	_sel_src  = ""
	_sel_idx  = -1
	_drag_icon.visible = false


func _process(_delta: float) -> void:
	if _sel_item != null:
		var mp := get_viewport().get_mouse_position()
		_drag_icon.position = mp - Vector2(SLOT_SIZE*0.5, SLOT_SIZE*0.5)
		if _drag_active:
			var res := _slot_at(mp)
			if not res.is_empty() and res.get("src") != "craft_result":
				var already := false
				for s in _drag_slots:
					if s["src"] == res["src"] and s["idx"] == res["idx"]:
						already = true
						break
				if not already:
					_drag_slots.append(res)


func _input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		var mbe := ev as InputEventMouseButton
		var mp  := mbe.position
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
		var ike := ev as InputEventKey
		if ike.pressed and not ike.echo:
			if ike.physical_keycode == KEY_E:
				_toggle_bag()
				get_viewport().set_input_as_handled()
			elif ike.physical_keycode == KEY_Q and not _bag_open:
				_drop_selected()
				get_viewport().set_input_as_handled()


func _toggle_bag() -> void:
	_bag_open = !_bag_open
	_bag_panel.visible = _bag_open
	if _bag_open:
		if not get_tree().paused:
			get_tree().paused = true
			_paused_by_bag = true
		_refresh()
	else:
		if _paused_by_bag:
			get_tree().paused = false
			_paused_by_bag = false
		if _sel_item != null:
			Inventory.add_item(_sel_item)
			Inventory.inventory_changed.emit()
			_clear_cursor()
		_drag_active = false
		_drag_slots = []
		_drag_origin = {}


func _drop_selected() -> void:
	var item := Inventory.drop_selected()
	if item == null:
		return
	_spawn_drop(item)


func _on_lmb_press(mp: Vector2, shift: bool) -> void:
	if not _bag_open:
		return
	var res := _slot_at(mp)
	if res.is_empty():
		if _sel_item != null:
			Inventory.add_item(_sel_item)
			Inventory.inventory_changed.emit()
			_clear_cursor()
		return
	if shift:
		_shift_click(res["src"], res["idx"])
		get_viewport().set_input_as_handled()
		return
	_drag_origin = res
	_drag_active = false
	_drag_slots = []
	get_viewport().set_input_as_handled()


func _on_lmb_release(mp: Vector2) -> void:
	if not _bag_open:
		return
	if _drag_active and _sel_item != null and _drag_slots.size() > 1:
		_finish_drag_distribute()
		get_viewport().set_input_as_handled()
		return
	_drag_active = false
	var res := _slot_at(mp)
	if not res.is_empty() and res.get("src") != "craft_result":
		var now := Time.get_ticks_msec() / 1000.0
		var same_slot : bool = not _last_click_slot.is_empty() and _last_click_slot.get("src") == res.get("src") and _last_click_slot.get("idx") == res.get("idx")
		if same_slot and (now - _last_click_time) < DOUBLE_CLICK_SEC:
			_double_click(res["src"], res["idx"])
			_last_click_time = -1.0
			_last_click_slot = {}
			get_viewport().set_input_as_handled()
			return
		_last_click_time = now
		_last_click_slot = res
	if res.is_empty():
		if _sel_item != null:
			Inventory.add_item(_sel_item)
			Inventory.inventory_changed.emit()
			_clear_cursor()
		return
	_left_click(res["src"], res["idx"])
	get_viewport().set_input_as_handled()


func _left_click(src: String, idx: int) -> void:
	if src == "craft_result":
		return
	var slot_item := _get_slot_item(src, idx)
	if _sel_item == null and slot_item == null:
		return
	if _sel_item == null and slot_item != null:
		_set_slot_item(src, idx, null)
		_sel_item = slot_item
		_sel_src  = src
		_sel_idx  = idx
		_drag_active = true
		_drag_slots  = [{"src": src, "idx": idx}]
		_drag_origin = {"src": src, "idx": idx}
		_update_cursor_icon()
		Inventory.inventory_changed.emit()
		return
	if _sel_item != null and slot_item == null:
		_set_slot_item(src, idx, _sel_item)
		_clear_cursor()
		Inventory.inventory_changed.emit()
		return
	if _sel_item != null and slot_item != null:
		if _sel_item.item_id == slot_item.item_id:
			var space: int = slot_item.max_stack - slot_item.quantity
			var give: int = min(space, _sel_item.quantity)
			slot_item.quantity += give
			_sel_item.quantity -= give
			if _sel_item.quantity <= 0:
				_clear_cursor()
			else:
				_update_cursor_icon()
			Inventory.inventory_changed.emit()
		else:
			_set_slot_item(src, idx, _sel_item)
			_sel_item = slot_item
			_sel_src  = src
			_sel_idx  = idx
			_update_cursor_icon()
			Inventory.inventory_changed.emit()


func _finish_drag_distribute() -> void:
	if _sel_item == null or _drag_slots.size() == 0:
		_drag_active = false
		_drag_slots = []
		return
	var targets : Array = []
	for s in _drag_slots:
		if s["src"] == _drag_origin.get("src") and s["idx"] == _drag_origin.get("idx"):
			continue
		var existing := _get_slot_item(s["src"], s["idx"])
		if existing != null and existing.item_id != _sel_item.item_id:
			continue
		targets.append(s)
	if targets.size() == 0:
		_set_slot_item(_drag_origin["src"], _drag_origin["idx"], _sel_item)
		_clear_cursor()
		Inventory.inventory_changed.emit()
		_drag_active = false
		_drag_slots = []
		return
	var per_slot : int = _sel_item.quantity / targets.size()
	var remainder : int = _sel_item.quantity % targets.size()
	for s in targets:
		if per_slot <= 0:
			break
		var existing := _get_slot_item(s["src"], s["idx"])
		if existing == null:
			var one := _sel_item.duplicate_item()
			one.quantity = per_slot
			_set_slot_item(s["src"], s["idx"], one)
		else:
			existing.quantity += per_slot
	if remainder > 0:
		_sel_item.quantity = remainder
		_update_cursor_icon()
	else:
		_clear_cursor()
	Inventory.inventory_changed.emit()
	_drag_active = false
	_drag_slots = []


func _shift_click(src: String, idx: int) -> void:
	var item := _get_slot_item(src, idx)
	if item == null:
		return
	_set_slot_item(src, idx, null)
	if src == "bag" or src == "craft":
		if not Inventory.add_item(item):
			_set_slot_item(src, idx, item)
	elif src == "hotbar" or src == "bh":
		var placed := false
		for i in Inventory.BAG_SIZE:
			if Inventory.bag[i] != null and Inventory.bag[i].item_id == item.item_id and Inventory.bag[i].quantity < Inventory.bag[i].max_stack:
				var space: int = Inventory.bag[i].max_stack - Inventory.bag[i].quantity
				var give: int = min(space, item.quantity)
				Inventory.bag[i].quantity += give
				item.quantity -= give
				if item.quantity <= 0:
					placed = true
					break
		if not placed:
			for i in Inventory.BAG_SIZE:
				if Inventory.bag[i] == null:
					Inventory.bag[i] = item
					placed = true
					break
		if not placed:
			_set_slot_item(src, idx, item)
	Inventory.inventory_changed.emit()


func _double_click(src: String, idx: int) -> void:
	if _sel_item == null:
		return
	var target_id := _sel_item.item_id
	for i in Inventory.BAG_SIZE:
		if _sel_item.quantity >= _sel_item.max_stack:
			break
		var it: ItemData = Inventory.bag[i]
		if it != null and it.item_id == target_id:
			var take: int = min(it.quantity, _sel_item.max_stack - _sel_item.quantity)
			_sel_item.quantity += take
			it.quantity -= take
			if it.quantity <= 0:
				Inventory.bag[i] = null
	for i in Inventory.HOTBAR_SIZE:
		if _sel_item.quantity >= _sel_item.max_stack:
			break
		if i == _sel_idx and (src == "hotbar" or src == "bh"):
			continue
		var it: ItemData = Inventory.hotbar[i]
		if it != null and it.item_id == target_id:
			var take: int = min(it.quantity, _sel_item.max_stack - _sel_item.quantity)
			_sel_item.quantity += take
			it.quantity -= take
			if it.quantity <= 0:
				Inventory.hotbar[i] = null
	_update_cursor_icon()
	Inventory.inventory_changed.emit()


func _refresh_craft() -> void:
	for i in 4:
		_update_slot(_craft_slots[i], _craft_items[i], false)


func _spawn_drop(item: ItemData) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var scene  = get_tree().current_scene
	if player == null or scene == null:
		return
	var drop_scene = preload("res://scenes/item_drop.tscn")
	var drop = drop_scene.instantiate()
	var dir  = Vector2(1.0 if player.facing_right else -1.0, 0.0)
	drop.position = player.global_position + dir * 50.0
	scene.add_child(drop)
	drop._land_y = drop.position.y + 90.0
	drop.setup(item, dir)


func _slot_at(mp: Vector2) -> Dictionary:
	if _bag_open:
		for i in _bh_rects.size():
			if _bh_rects[i].has_point(mp):
				return {"src": "bh", "idx": i}
		for i in _bag_rects.size():
			if _bag_rects[i].has_point(mp):
				return {"src": "bag", "idx": i}
		for i in _craft_rects.size():
			if _craft_rects[i].has_point(mp):
				return {"src": "craft", "idx": i}
		if _craft_result_rect.has_point(mp):
			return {"src": "craft_result", "idx": 0}
	else:
		for i in _hotbar_rects.size():
			if _hotbar_rects[i].has_point(mp):
				return {"src": "hotbar", "idx": i}
	return {}
