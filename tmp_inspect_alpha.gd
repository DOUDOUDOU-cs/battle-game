extends SceneTree

func _init():
	for path in ["res://assets/mushroom.webp", "res://assets/gel.png"]:
		var image := Image.load_from_file(path)
		if image == null:
			print(path, " load_failed")
			continue
			
		image.convert(Image.FORMAT_RGBA8)
		var w := image.get_width()
		var h := image.get_height()
		var samples := {
			"tl": image.get_pixel(0, 0),
			"tr": image.get_pixel(w - 1, 0),
			"bl": image.get_pixel(0, h - 1),
			"br": image.get_pixel(w - 1, h - 1),
			"center": image.get_pixel(w / 2, h / 2)
		}
		print(path, " ", w, "x", h, " ", samples)
	quit()
