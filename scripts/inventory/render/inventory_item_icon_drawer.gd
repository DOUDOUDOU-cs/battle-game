class_name InventoryItemIconDrawer
extends Control

var item_id: String = ""


func set_item(id: String) -> void:
	item_id = id
	queue_redraw()


func _draw() -> void:
	if item_id == "":
		return

	var texture: Texture2D = ItemTextureLibrary.get_texture(item_id)
	if texture == null:
		_draw_fallback()
		return

	var tex_size: Vector2 = texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		_draw_fallback()
		return

	var max_side: float = max(tex_size.x, tex_size.y)
	var scale: float = min(size.x, size.y) * 0.82 / max_side
	var draw_size := tex_size * scale
	var draw_rect := Rect2((size - draw_size) * 0.5, draw_size)
	draw_texture_rect(texture, draw_rect, false, Color(1.0, 1.0, 1.0, 1.0))


func _draw_fallback() -> void:
	var s := size
	var cx := s.x * 0.5
	var cy := s.y * 0.5
	draw_rect(Rect2(cx - 8.0, cy - 8.0, 16.0, 16.0), Color(0.72, 0.55, 0.10, 0.90))
