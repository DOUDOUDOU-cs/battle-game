class_name ItemTextureLibrary
extends RefCounted

const ITEM_TEXTURE_PATHS := {
	"mushroom": "res://assets/mushroom.png",
	"slime_gel": "res://assets/gel.png",
}

static var _cache: Dictionary = {}

static func preload_all() -> void:
	for item_id in ITEM_TEXTURE_PATHS.keys():
		get_texture(str(item_id))

static func get_texture(item_id: String, fallback_texture: Texture2D = null) -> Texture2D:
	if _cache.has(item_id):
		return _cache[item_id]

	if fallback_texture != null:
		_cache[item_id] = fallback_texture
		return fallback_texture

	var path: String = ITEM_TEXTURE_PATHS.get(item_id, "")
	if path == "":
		return null

	var texture: Texture2D = load(path) as Texture2D
	if texture != null:
		_cache[item_id] = texture
	return texture
