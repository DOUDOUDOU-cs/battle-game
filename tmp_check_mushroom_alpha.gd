extends SceneTree

func _init() -> void:
	var image := Image.load_from_file("res://assets/mushroom.png")
	if image == null:
		print("load_failed")
		quit()
		return
	image.convert(Image.FORMAT_RGBA8)
	var w := image.get_width()
	var h := image.get_height()
	print("tl=", image.get_pixel(0,0))
	print("tr=", image.get_pixel(w-1,0))
	print("bl=", image.get_pixel(0,h-1))
	print("br=", image.get_pixel(w-1,h-1))
	quit()
