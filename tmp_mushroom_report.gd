extends SceneTree

func _init():
	var out := FileAccess.open("res://tmp_mushroom_report.txt", FileAccess.WRITE)
	for path in ["res://assets/mushroom.webp", "res://assets/gel.png"]:
		var image := Image.load_from_file(path)
		if image == null:
			out.store_line(path + " load_failed")
			continue
		image.convert(Image.FORMAT_RGBA8)
		var w := image.get_width()
		var h := image.get_height()
		var pts := {
			"tl": image.get_pixel(0, 0),
			"tr": image.get_pixel(w - 1, 0),
			"bl": image.get_pixel(0, h - 1),
			"br": image.get_pixel(w - 1, h - 1),
			"center": image.get_pixel(w / 2, h / 2)
		}
		out.store_line(path + " " + str(w) + "x" + str(h) + " " + str(pts))
	out.close()
	quit()
