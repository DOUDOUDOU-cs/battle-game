class_name RandomLevelGenerator
extends RefCounted

const TILE_SOURCE_ID = 0

# Structured jungle tileset usage is based on the user's explicit row/column mapping.
# Atlas coordinates here are stored as Vector2i(column, row).
# Top row: top-left corner, horizontal top, top-right corner
# Middle row: left wall, deep fill, right wall
# Bottom row: bottom-left corner, bottom face, bottom-right corner
# Row 3: one-tile-thick floating ledges (left cap, center, right cap)
# Extra confirmed inner-corner tiles:
# (5,1) visible top-left corner, used for a bottom-right fold
# (5,2) visible top-right corner, used for a bottom-left fold
# (6,1) visible bottom-left corner, used for a top-right fold
# (6,2) visible bottom-right corner, used for a top-left fold
# Rows 2-4 are reserved for glitch mode only.
const STRUCTURED_TOP_LEFT_TILE = Vector2i(0, 0)
const STRUCTURED_TOP_TILE = Vector2i(1, 0)
const STRUCTURED_TOP_RIGHT_TILE = Vector2i(2, 0)

const STRUCTURED_LEFT_WALL_TILE = Vector2i(0, 1)
const STRUCTURED_DEEP_FILL_TILE = Vector2i(1, 1)
const STRUCTURED_RIGHT_WALL_TILE = Vector2i(2, 1)

const STRUCTURED_BOTTOM_LEFT_TILE = Vector2i(0, 2)
const STRUCTURED_BOTTOM_TILE = Vector2i(1, 2)
const STRUCTURED_BOTTOM_RIGHT_TILE = Vector2i(2, 2)

const STRUCTURED_THIN_LEFT_TILE = Vector2i(0, 3)
const STRUCTURED_THIN_CENTER_TILE = Vector2i(1, 3)
const STRUCTURED_THIN_RIGHT_TILE = Vector2i(2, 3)

const STRUCTURED_INNER_TOP_LEFT_TILE = Vector2i(5, 1)
const STRUCTURED_INNER_TOP_RIGHT_TILE = Vector2i(5, 2)
const STRUCTURED_INNER_BOTTOM_LEFT_TILE = Vector2i(6, 1)
const STRUCTURED_INNER_BOTTOM_RIGHT_TILE = Vector2i(6, 2)

const GLITCH_SURFACE_TILES = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)
]
const GLITCH_FILL_TILES = [
	Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2),
	Vector2i(8, 2), Vector2i(9, 2), Vector2i(10, 2),
	Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 3), Vector2i(7, 3),
	Vector2i(8, 3), Vector2i(9, 3), Vector2i(10, 3),
	Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(8, 4)
]

func generate_small_map(tilemap: TileMapLayer) -> Dictionary:
	return _generate_map(tilemap, {
		"level_width": 68,
		"ground_y": 17,
		"ground_depth": 7,
		"terrain_variation": 2,
		"segment_min_width": 8,
		"segment_max_width": 14,
		"start_platform_width": 12,
		"end_platform_width": 12,
		"canopy_count": 4,
		"canopy_min_width": 4,
		"canopy_max_width": 6,
		"canopy_min_height": 5,
		"canopy_max_height": 8,
		"style": "structured"
	})

func generate_large_map(tilemap: TileMapLayer) -> Dictionary:
	return _generate_map(tilemap, {
		"level_width": 104,
		"ground_y": 17,
		"ground_depth": 7,
		"terrain_variation": 3,
		"segment_min_width": 9,
		"segment_max_width": 16,
		"start_platform_width": 14,
		"end_platform_width": 14,
		"canopy_count": 6,
		"canopy_min_width": 4,
		"canopy_max_width": 7,
		"canopy_min_height": 5,
		"canopy_max_height": 9,
		"style": "structured"
	})

func generate_glitch_zone_map(tilemap: TileMapLayer) -> Dictionary:
	return _generate_map(tilemap, {
		"level_width": 68,
		"ground_y": 17,
		"ground_depth": 7,
		"terrain_variation": 2,
		"segment_min_width": 8,
		"segment_max_width": 14,
		"start_platform_width": 12,
		"end_platform_width": 12,
		"canopy_count": 4,
		"canopy_min_width": 4,
		"canopy_max_width": 6,
		"canopy_min_height": 5,
		"canopy_max_height": 8,
		"style": "glitch"
	})

func _generate_map(tilemap: TileMapLayer, config: Dictionary) -> Dictionary:
	var level_width: int = int(config["level_width"])
	var ground_y: int = int(config["ground_y"])
	var ground_depth: int = int(config["ground_depth"])
	var start_platform_width: int = int(config["start_platform_width"])
	var end_platform_width: int = int(config["end_platform_width"])
	var style: String = str(config["style"])

	var ground_heights: Array = _build_ground_profile(config)
	var platforms: Array = []
	tilemap.clear()
	platforms.append_array(_collect_ground_surfaces(ground_heights))
	var canopy_surfaces: Array = _collect_canopy_surfaces(ground_heights, config)
	platforms.append_array(canopy_surfaces)

	if style == "structured":
		var solid_cells: Dictionary = {}
		_add_ground_cells(solid_cells, ground_heights, ground_depth)
		_add_platform_cells(solid_cells, canopy_surfaces, 1)
		_paint_structured_cells(tilemap, solid_cells)
	else:
		_paint_ground_columns(tilemap, ground_heights, ground_depth, style)
		_paint_canopy_surfaces(tilemap, canopy_surfaces, style)

	var max_ground_y: int = ground_y
	for height in ground_heights:
		max_ground_y = max(max_ground_y, int(height))

	var spawn_index: int = min(int(start_platform_width / 2), ground_heights.size() - 1)
	var spawn_surface_y: int = int(ground_heights[spawn_index])

	return {
		"platforms": platforms,
		"level_width": level_width,
		"ground_y": ground_y,
		"kill_zone_row": max_ground_y + ground_depth + 6,
		"spawn_cell_center_x": start_platform_width * 0.5,
		"spawn_surface_y": spawn_surface_y
	}

func _make_platform_data(x: int, y: int, width: int) -> Dictionary:
	return {"x": x, "y": y, "width": width}

func _build_ground_profile(config: Dictionary) -> Array:
	var level_width: int = int(config["level_width"])
	var base_ground_y: int = int(config["ground_y"])
	var terrain_variation: int = int(config["terrain_variation"])
	var segment_min_width: int = int(config["segment_min_width"])
	var segment_max_width: int = int(config["segment_max_width"])
	var start_platform_width: int = int(config["start_platform_width"])
	var end_platform_width: int = int(config["end_platform_width"])

	var heights: Array = []
	var anchors: Array = [{"x": 0, "y": base_ground_y}]
	var anchor_x: int = start_platform_width
	var previous_y: int = base_ground_y

	while anchor_x < level_width - end_platform_width:
		var next_y: int = clamp(
			previous_y + randi_range(-1, 1),
			base_ground_y - terrain_variation,
			base_ground_y + terrain_variation
		)
		anchors.append({"x": anchor_x, "y": next_y})
		previous_y = next_y
		anchor_x += randi_range(segment_min_width, segment_max_width)

	anchors.append({"x": level_width - end_platform_width, "y": base_ground_y})
	anchors.append({"x": level_width - 1, "y": base_ground_y})

	heights = _interpolate_heights(anchors, level_width)
	_flatten_range(heights, 0, start_platform_width, base_ground_y)
	_flatten_range(heights, level_width - end_platform_width, level_width, base_ground_y)
	_smooth_height_profile(heights, 2)
	_flatten_range(heights, 0, start_platform_width, base_ground_y)
	_flatten_range(heights, level_width - end_platform_width, level_width, base_ground_y)
	return heights

func _interpolate_heights(anchors: Array, level_width: int) -> Array:
	var heights: Array = []
	heights.resize(level_width)

	for i in range(anchors.size() - 1):
		var start_anchor: Dictionary = anchors[i]
		var end_anchor: Dictionary = anchors[i + 1]
		var start_x: int = int(start_anchor["x"])
		var end_x: int = int(end_anchor["x"])
		var start_y: int = int(start_anchor["y"])
		var end_y: int = int(end_anchor["y"])
		var span: int = max(1, end_x - start_x)

		for x in range(start_x, min(end_x + 1, level_width)):
			var t: float = float(x - start_x) / float(span)
			var curved_t: float = t * t * (3.0 - 2.0 * t)
			heights[x] = int(round(lerp(float(start_y), float(end_y), curved_t)))

	for x in range(level_width):
		if heights[x] == null:
			heights[x] = int(anchors[anchors.size() - 1]["y"])

	return heights

func _flatten_range(heights: Array, start_x: int, end_x: int, value: int) -> void:
	var from_x: int = max(0, start_x)
	var to_x: int = min(end_x, heights.size())
	for x in range(from_x, to_x):
		heights[x] = value

func _smooth_height_profile(heights: Array, passes: int) -> void:
	for _pass in range(passes):
		var snapshot: Array = heights.duplicate()
		for x in range(1, heights.size() - 1):
			var blended: float = (float(snapshot[x - 1]) + float(snapshot[x]) * 2.0 + float(snapshot[x + 1])) / 4.0
			heights[x] = int(round(blended))

func _paint_ground_columns(tilemap: TileMapLayer, ground_heights: Array, ground_depth: int, style: String) -> void:
	if ground_heights.is_empty():
		return

	var bottom_y: int = 0
	for height in ground_heights:
		bottom_y = max(bottom_y, int(height) + ground_depth - 1)

	for x in range(ground_heights.size()):
		var top_y: int = int(ground_heights[x])
		for cell_y in range(top_y, bottom_y + 1):
			var atlas_coords: Vector2i = _pick_ground_tile(style, ground_heights, x, cell_y, top_y, bottom_y)
			_set_level_tile(tilemap, Vector2i(x, cell_y), atlas_coords)

func _add_ground_cells(solid_cells: Dictionary, ground_heights: Array, ground_depth: int) -> void:
	if ground_heights.is_empty():
		return

	var bottom_y: int = 0
	for height in ground_heights:
		bottom_y = max(bottom_y, int(height) + ground_depth - 1)

	for x in range(ground_heights.size()):
		var top_y: int = int(ground_heights[x])
		for cell_y in range(top_y, bottom_y + 1):
			solid_cells[Vector2i(x, cell_y)] = true

func _add_platform_cells(solid_cells: Dictionary, surfaces: Array, thickness: int) -> void:
	for surface_data in surfaces:
		var surface: Dictionary = surface_data
		var start_x: int = int(surface["x"])
		var top_y: int = int(surface["y"])
		var width: int = int(surface["width"])
		for offset_x in range(width):
			for fill_row in range(thickness):
				solid_cells[Vector2i(start_x + offset_x, top_y + fill_row)] = true

func _paint_structured_cells(tilemap: TileMapLayer, solid_cells: Dictionary) -> void:
	for cell_key in solid_cells.keys():
		var cell: Vector2i = cell_key as Vector2i
		_set_level_tile(tilemap, cell, _pick_structured_tile_for_cell(cell, solid_cells))

func _pick_structured_tile_for_cell(cell: Vector2i, solid_cells: Dictionary) -> Vector2i:
	var up: bool = solid_cells.has(cell + Vector2i(0, -1))
	var down: bool = solid_cells.has(cell + Vector2i(0, 1))
	var left: bool = solid_cells.has(cell + Vector2i(-1, 0))
	var right: bool = solid_cells.has(cell + Vector2i(1, 0))
	var up_left: bool = solid_cells.has(cell + Vector2i(-1, -1))
	var up_right: bool = solid_cells.has(cell + Vector2i(1, -1))
	var down_left: bool = solid_cells.has(cell + Vector2i(-1, 1))
	var down_right: bool = solid_cells.has(cell + Vector2i(1, 1))

	if not up and not down:
		if not left and right:
			return STRUCTURED_THIN_LEFT_TILE
		if left and not right:
			return STRUCTURED_THIN_RIGHT_TILE
		return STRUCTURED_THIN_CENTER_TILE

	if not up:
		if not left and right:
			return STRUCTURED_TOP_LEFT_TILE
		if left and not right:
			return STRUCTURED_TOP_RIGHT_TILE
		return STRUCTURED_TOP_TILE

	if not down:
		if not left and right:
			return STRUCTURED_BOTTOM_LEFT_TILE
		if left and not right:
			return STRUCTURED_BOTTOM_RIGHT_TILE
		return STRUCTURED_BOTTOM_TILE

	if not left and right:
		return STRUCTURED_LEFT_WALL_TILE
	if left and not right:
		return STRUCTURED_RIGHT_WALL_TILE

	if up and down and left and right:
		if not down_right:
			return STRUCTURED_INNER_TOP_LEFT_TILE
		if not down_left:
			return STRUCTURED_INNER_TOP_RIGHT_TILE
		if not up_right:
			return STRUCTURED_INNER_BOTTOM_LEFT_TILE
		if not up_left:
			return STRUCTURED_INNER_BOTTOM_RIGHT_TILE

	return STRUCTURED_DEEP_FILL_TILE

func _pick_ground_tile(
	style: String,
	ground_heights: Array,
	x: int,
	cell_y: int,
	top_y: int,
	bottom_y: int
) -> Vector2i:
	if cell_y == top_y:
		return _pick_surface_tile(style, _surface_local_x(ground_heights, x), _surface_width(ground_heights, x), x + top_y)
	if cell_y == top_y + 1:
		return _pick_subsurface_tile(style, ground_heights, x)
	return _pick_ground_fill_tile(style, ground_heights, x, cell_y, bottom_y)

func _pick_subsurface_tile(style: String, ground_heights: Array, x: int) -> Vector2i:
	if style == "glitch":
		return GLITCH_FILL_TILES[posmod(x * 5 + 1, GLITCH_FILL_TILES.size())]

	var local_x: int = _surface_local_x(ground_heights, x)
	var surface_width: int = _surface_width(ground_heights, x)
	if surface_width <= 1:
		return STRUCTURED_DEEP_FILL_TILE
	if local_x == 0:
		return STRUCTURED_LEFT_WALL_TILE
	if local_x == surface_width - 1:
		return STRUCTURED_RIGHT_WALL_TILE
	return STRUCTURED_DEEP_FILL_TILE

func _pick_ground_fill_tile(style: String, ground_heights: Array, x: int, cell_y: int, bottom_y: int) -> Vector2i:
	if style == "glitch":
		return GLITCH_FILL_TILES[posmod(x + cell_y * 3, GLITCH_FILL_TILES.size())]
	var has_left_neighbor: bool = _has_ground_at(ground_heights, x - 1, cell_y, bottom_y)
	var has_right_neighbor: bool = _has_ground_at(ground_heights, x + 1, cell_y, bottom_y)
	return _pick_structured_deep_fill_tile(x, cell_y, has_left_neighbor, has_right_neighbor)

func _pick_structured_deep_fill_tile(
	x: int,
	cell_y: int,
	has_left_neighbor: bool,
	has_right_neighbor: bool
) -> Vector2i:
	if not has_left_neighbor and has_right_neighbor:
		return STRUCTURED_LEFT_WALL_TILE
	if has_left_neighbor and not has_right_neighbor:
		return STRUCTURED_RIGHT_WALL_TILE
	return STRUCTURED_DEEP_FILL_TILE

func _has_ground_at(ground_heights: Array, x: int, cell_y: int, bottom_y: int) -> bool:
	if x < 0 or x >= ground_heights.size():
		return false
	var top_y: int = int(ground_heights[x])
	return cell_y >= top_y and cell_y <= bottom_y

func _collect_ground_surfaces(ground_heights: Array) -> Array:
	var surfaces: Array = []
	if ground_heights.is_empty():
		return surfaces

	var run_start: int = 0
	var run_height: int = int(ground_heights[0])

	for x in range(1, ground_heights.size() + 1):
		var reached_end: bool = x == ground_heights.size()
		var next_height: int = run_height if reached_end else int(ground_heights[x])
		if reached_end or next_height != run_height:
			var width: int = x - run_start
			if width >= 4:
				surfaces.append(_make_platform_data(run_start, run_height, width))
			if not reached_end:
				run_start = x
				run_height = next_height

	return surfaces

func _collect_canopy_surfaces(ground_heights: Array, config: Dictionary) -> Array:
	var surfaces: Array = []
	var canopy_count: int = int(config["canopy_count"])
	var min_width: int = int(config["canopy_min_width"])
	var max_width: int = int(config["canopy_max_width"])
	var min_height: int = int(config["canopy_min_height"])
	var max_height: int = int(config["canopy_max_height"])
	var start_platform_width: int = int(config["start_platform_width"])
	var end_platform_width: int = int(config["end_platform_width"])
	var used_ranges: Array = []

	for _i in range(canopy_count):
		var width: int = randi_range(min_width, max_width)
		var min_x: int = start_platform_width + 2
		var max_x: int = max(min_x, ground_heights.size() - end_platform_width - width - 2)
		if max_x <= min_x:
			break

		var platform_x: int = randi_range(min_x, max_x)
		if _intersects_used_ranges(platform_x, width, used_ranges):
			continue
		var ground_top: int = int(ground_heights[platform_x + width / 2])
		var platform_y: int = ground_top - randi_range(min_height, max_height)
		if platform_y >= ground_top - min_height:
			platform_y = ground_top - min_height
		surfaces.append(_make_platform_data(platform_x, platform_y, width))
		used_ranges.append(Vector2i(platform_x - 2, platform_x + width + 2))

	return surfaces

func _paint_canopy_surfaces(tilemap: TileMapLayer, surfaces: Array, style: String) -> void:
	for surface_data in surfaces:
		var surface: Dictionary = surface_data
		_paint_platform(
			tilemap,
			int(surface["x"]),
			int(surface["width"]),
			int(surface["y"]),
			1,
			style
		)

func _intersects_used_ranges(start_x: int, width: int, used_ranges: Array) -> bool:
	var end_x: int = start_x + width
	for used_range in used_ranges:
		var range_data: Vector2i = used_range as Vector2i
		if start_x < range_data.y and end_x > range_data.x:
			return true
	return false

func _surface_local_x(ground_heights: Array, x: int) -> int:
	var local_x: int = 0
	for prev_x in range(x - 1, -1, -1):
		if int(ground_heights[prev_x]) != int(ground_heights[x]):
			break
		local_x += 1
	return local_x

func _surface_width(ground_heights: Array, x: int) -> int:
	var width: int = 1
	for prev_x in range(x - 1, -1, -1):
		if int(ground_heights[prev_x]) != int(ground_heights[x]):
			break
		width += 1
	for next_x in range(x + 1, ground_heights.size()):
		if int(ground_heights[next_x]) != int(ground_heights[x]):
			break
		width += 1
	return width

func _paint_platform(
	tilemap: TileMapLayer,
	start_x: int,
	width: int,
	top_y: int,
	thickness: int,
	style: String
) -> void:
	for x in range(width):
		var cell_x: int = start_x + x
		_set_level_tile(
			tilemap,
			Vector2i(cell_x, top_y),
			_pick_surface_tile(style, x, width, cell_x + top_y)
		)

		for fill_row in range(1, thickness):
			var cell_y: int = top_y + fill_row
			_set_level_tile(
				tilemap,
				Vector2i(cell_x, cell_y),
				_pick_fill_tile(style, x, width, cell_x + cell_y * 3)
			)

func _set_level_tile(tilemap: TileMapLayer, cell: Vector2i, atlas_coords: Vector2i) -> void:
	tilemap.set_cell(cell, TILE_SOURCE_ID, atlas_coords)

func _pick_surface_tile(style: String, local_x: int, width: int, seed_value: int) -> Vector2i:
	if style == "glitch":
		return GLITCH_SURFACE_TILES[posmod(seed_value, GLITCH_SURFACE_TILES.size())]

	if width <= 1:
		return STRUCTURED_TOP_TILE
	if local_x == 0:
		return STRUCTURED_TOP_LEFT_TILE
	if local_x == width - 1:
		return STRUCTURED_TOP_RIGHT_TILE
	return STRUCTURED_TOP_TILE

func _pick_fill_tile(style: String, local_x: int, width: int, seed_value: int) -> Vector2i:
	if style == "glitch":
		return GLITCH_FILL_TILES[posmod(seed_value, GLITCH_FILL_TILES.size())]

	if width <= 1:
		return STRUCTURED_THIN_CENTER_TILE
	if local_x == 0:
		return STRUCTURED_THIN_LEFT_TILE
	if local_x == width - 1:
		return STRUCTURED_THIN_RIGHT_TILE
	return STRUCTURED_THIN_CENTER_TILE
