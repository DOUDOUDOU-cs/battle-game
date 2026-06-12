extends SceneTree

const INPUTS := {
	"res://assets/mushroom.webp": "res://assets/mushroom.png",
	"res://assets/gel.jpg": "res://assets/gel.png"
}

const BG_BRIGHTNESS_MIN := 0.70
const BG_SATURATION_MAX := 0.28
const EDGE_BRIGHTNESS_MIN := 0.68
const EDGE_SATURATION_MAX := 0.34
const EDGE_ALPHA := 0.43

func _init() -> void:
	for src in INPUTS.keys():
		_process_image(src, INPUTS[src])
	quit()

func _process_image(src_path: String, dst_path: String) -> void:
	var image := Image.load_from_file(src_path)
	if image == null:
		push_error("Failed to load %s" % src_path)
		return
	image.convert(Image.FORMAT_RGBA8)
	_clear_connected_background(image)
	_soften_edge_pixels(image)
	var abs_dst := ProjectSettings.globalize_path(dst_path)
	var err := image.save_png(abs_dst)
	if err != OK:
		push_error("Failed to save %s: %s" % [dst_path, err])

func _clear_connected_background(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)
	var stack: Array[Vector2i] = []

	for x in range(width):
		_push_if_background(image, visited, stack, Vector2i(x, 0), width)
		_push_if_background(image, visited, stack, Vector2i(x, height - 1), width)
	for y in range(height):
		_push_if_background(image, visited, stack, Vector2i(0, y), width)
		_push_if_background(image, visited, stack, Vector2i(width - 1, y), width)

	while not stack.is_empty():
		var pixel := stack.pop_back()
		var idx := pixel.y * width + pixel.x
		if visited[idx] == 2:
			continue
		var color := image.get_pixelv(pixel)
		if not _is_background_candidate(color):
			continue
		visited[idx] = 2
		image.set_pixelv(pixel, Color(color.r, color.g, color.b, 0.0))
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next := pixel + offset
			if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
				continue
			_push_if_background(image, visited, stack, next, width)

func _soften_edge_pixels(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	for y in range(height):
		for x in range(width):
			var color := image.get_pixel(x, y)
			if color.a <= 0.0:
				continue
			if not _is_light_edge_candidate(color):
				continue
			if not _touches_transparent_pixel(image, x, y, width, height):
				continue
			color.a = min(color.a, EDGE_ALPHA)
			image.set_pixel(x, y, color)

func _push_if_background(image: Image, visited: PackedByteArray, stack: Array[Vector2i], pixel: Vector2i, width: int) -> void:
	var idx := pixel.y * width + pixel.x
	if visited[idx] != 0:
		return
	visited[idx] = 1
	if _is_background_candidate(image.get_pixelv(pixel)):
		stack.append(pixel)

func _touches_transparent_pixel(image: Image, x: int, y: int, width: int, height: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			var nx := x + ox
			var ny := y + oy
			if nx < 0 or ny < 0 or nx >= width or ny >= height:
				continue
			if image.get_pixel(nx, ny).a <= 0.0:
				return true
	return false

func _is_background_candidate(color: Color) -> bool:
	if color.a <= 0.0:
		return false
	var max_channel := max(color.r, max(color.g, color.b))
	var min_channel := min(color.r, min(color.g, color.b))
	var saturation := max_channel - min_channel
	return max_channel >= BG_BRIGHTNESS_MIN and saturation <= BG_SATURATION_MAX

func _is_light_edge_candidate(color: Color) -> bool:
	var max_channel := max(color.r, max(color.g, color.b))
	var min_channel := min(color.r, min(color.g, color.b))
	var saturation := max_channel - min_channel
	return max_channel >= EDGE_BRIGHTNESS_MIN and saturation <= EDGE_SATURATION_MAX
