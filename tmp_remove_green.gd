extends SceneTree

const SRC := "res://assets/mushroom_chroma.png"
const DST := "res://assets/mushroom.png"
const KEY_R := 0.0
const KEY_G := 1.0
const KEY_B := 0.0

func _init() -> void:
	var image := Image.load_from_file(SRC)
	if image == null:
		push_error("Failed to load %s" % SRC)
		quit()
		return
	image.convert(Image.FORMAT_RGBA8)
	var width := image.get_width()
	var height := image.get_height()
	for y in range(height):
		for x in range(width):
			var c := image.get_pixel(x, y)
			var dr := abs(c.r - KEY_R)
			var dg := abs(c.g - KEY_G)
			var db := abs(c.b - KEY_B)
			var dist := max(dr, max(dg, db))
			if dist < 0.03:
				image.set_pixel(x, y, Color(c.r, c.g, c.b, 0.0))
			elif dist < 0.20:
				var alpha := clamp((dist - 0.03) / 0.17, 0.0, 1.0)
				image.set_pixel(x, y, Color(c.r, c.g, c.b, alpha))
	var err := image.save_png(ProjectSettings.globalize_path(DST))
	if err != OK:
		push_error("Failed to save %s: %s" % [DST, err])
	quit()
