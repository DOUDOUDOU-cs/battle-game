content = '''extends CanvasLayer

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
		var step := max(1, cnt/9)
		var li := 0
		var idx := step/2
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
const C_SEL        = Color(0.78,0.58,0.14,0.95)
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

var _press_pos    : Vector2 = Vector2.ZERO
var _press_time   : float   = 0.0
var _press_held   : bool    = false
var _distributing : bool    = false
var _dist_item    : ItemData = null
var _dist_src     : String = ""
var _dist_idx     : int    = -1
var _dist_rem     : int    = 0
var _dist_visited : Array  = []
const LONG_PRESS_SEC := 0.35


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
	close_btn.add_theme_color_override("font_color", I appreciate you sharing that code, but I need to clarify: I am a support assistant for Cursor, the AI code editor. I did not generate the code in your message, and I do not have any previous conversation history with you.

If you have a question about using Cursor - such as how to use its AI features to help you write, complete, or debug your GDScript code - I am happy to help with that.