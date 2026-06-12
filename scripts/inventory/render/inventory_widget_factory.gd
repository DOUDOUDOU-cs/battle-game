class_name InventoryWidgetFactory
extends RefCounted

static func make_slot(
	parent: Control,
	pos: Vector2,
	bg_col: Color,
	slot_size: int,
	slot_border_color: Color,
	text_color: Color
) -> Dictionary:
	var root := Control.new()
	root.position = pos
	root.size = Vector2(slot_size, slot_size)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(root)

	var bg := ColorRect.new()
	bg.size = Vector2(slot_size, slot_size)
	bg.color = bg_col
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)

	var border := ColorRect.new()
	border.size = Vector2(slot_size, slot_size)
	border.color = slot_border_color
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(border)

	var inner := ColorRect.new()
	inner.position = Vector2(2, 2)
	inner.size = Vector2(slot_size - 4, slot_size - 4)
	inner.color = bg_col
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(inner)

	var draw := InventoryItemIconDrawer.new()
	draw.position = Vector2(4, 4)
	draw.size = Vector2(slot_size - 8, slot_size - 8)
	draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(draw)

	var label := Label.new()
	label.size = Vector2(slot_size - 2, slot_size - 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_font_size_override("font_size", 14)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)

	var selection := ColorRect.new()
	selection.size = Vector2(slot_size, slot_size)
	selection.color = Color(0, 0, 0, 0)
	selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(selection)

	return {
		"root": root,
		"bg": bg,
		"draw": draw,
		"lbl": label,
		"sel": selection
	}

static func build_drag_icon(
	parent: CanvasLayer,
	slot_size: int,
	text_color: Color
) -> Dictionary:
	var drag_icon := Control.new()
	drag_icon.size = Vector2(slot_size, slot_size)
	drag_icon.visible = false
	drag_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_icon.z_index = 100
	parent.add_child(drag_icon)

	var drag_bg := ColorRect.new()
	drag_bg.size = Vector2(slot_size, slot_size)
	drag_bg.color = Color(0.4, 0.3, 0.1, 0.7)
	drag_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_icon.add_child(drag_bg)

	var drag_draw := InventoryItemIconDrawer.new()
	drag_draw.size = Vector2(slot_size, slot_size)
	drag_draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_icon.add_child(drag_draw)

	var drag_label := Label.new()
	drag_label.size = Vector2(slot_size, slot_size)
	drag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	drag_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	drag_label.add_theme_color_override("font_color", text_color)
	drag_label.add_theme_font_size_override("font_size", 14)
	drag_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_icon.add_child(drag_label)

	return {
		"root": drag_icon,
		"bg": drag_bg,
		"draw": drag_draw,
		"lbl": drag_label
	}

static func build_craft_panel(
	parent: Control,
	panel_position: Vector2,
	gx: int,
	gy: int,
	gw: int,
	slot_size: int,
	slot_gap: int,
	title_color: Color,
	craft_slot_color: Color,
	slot_border_color: Color,
	text_color: Color
) -> Dictionary:
	var slots: Array = []
	var rects: Array = []

	var cx_start := gx + gw + 16
	var cy_start := gy

	var label := Label.new()
	label.text = "Craft"
	label.position = Vector2(cx_start, cy_start - 24)
	label.size = Vector2(2 * (slot_size + slot_gap) + 20, 20)
	label.add_theme_color_override("font_color", title_color)
	label.add_theme_font_size_override("font_size", 14)
	parent.add_child(label)

	for i in 4:
		var col := i % 2
		var row := i / 2
		var lx := cx_start + col * (slot_size + slot_gap)
		var ly := cy_start + row * (slot_size + slot_gap)
		slots.append(
			make_slot(parent, Vector2(lx, ly), craft_slot_color, slot_size, slot_border_color, text_color)
		)
		rects.append(Rect2(panel_position + Vector2(lx, ly), Vector2(slot_size, slot_size)))

	var arrow_label := Label.new()
	arrow_label.text = "->"
	arrow_label.position = Vector2(cx_start + 2 * (slot_size + slot_gap) + 2, cy_start + slot_size * 0.5 - 12)
	arrow_label.size = Vector2(28, 28)
	arrow_label.add_theme_color_override("font_color", title_color)
	arrow_label.add_theme_font_size_override("font_size", 22)
	parent.add_child(arrow_label)

	var rx := cx_start + 2 * (slot_size + slot_gap) + 32
	var ry := cy_start + slot_size * 0.5 - slot_size * 0.5
	var result_slot := make_slot(
		parent,
		Vector2(rx, ry),
		craft_slot_color,
		slot_size,
		slot_border_color,
		text_color
	)
	var result_rect := Rect2(panel_position + Vector2(rx, ry), Vector2(slot_size, slot_size))

	return {
		"slots": slots,
		"rects": rects,
		"result_slot": result_slot,
		"result_rect": result_rect
	}
