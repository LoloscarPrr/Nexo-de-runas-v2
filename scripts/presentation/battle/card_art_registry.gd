class_name CardArtRegistry
extends RefCounted

## Presentation-only: maps canonical card IDs to individually exported art.
## Text, cost, attack, health, and effects remain dynamic in the card renderer.
## Never map an image by display name or by its position in the deck.

const PILOT_ART = {
	"bs_001_brote_del_claro": {
		"path": "res://assets/domains/forest/cards/art/bs_001_brote_del_claro.webp",
		"focus": Vector2(0.50, 0.42)
	},
	"bs_006_lobo_de_manada": {
		"path": "res://assets/domains/forest/cards/art/bs_006_lobo_de_manada.webp",
		"focus": Vector2(0.53, 0.41)
	},
	"bs_013_avatar_del_bosque": {
		"path": "res://assets/domains/forest/cards/art/bs_013_avatar_del_bosque.webp",
		"focus": Vector2(0.52, 0.37)
	}
}

static func art_path(card_id: String) -> String:
	if not PILOT_ART.has(card_id):
		return ""
	return str(PILOT_ART[card_id]["path"])

static func focal_point(card_id: String) -> Vector2:
	if not PILOT_ART.has(card_id):
		return Vector2(0.5, 0.5)
	return PILOT_ART[card_id]["focus"]

static func load_art(card_id: String) -> Texture2D:
	var path := art_path(card_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D

static func art_crop(card_id: String, source_size: Vector2, target_size: Vector2) -> Rect2:
	if source_size.x <= 0.0 or source_size.y <= 0.0 or target_size.x <= 0.0 or target_size.y <= 0.0:
		return Rect2(Vector2.ZERO, source_size)
	var focus := focal_point(card_id)
	var target_aspect := target_size.x / target_size.y
	var crop := source_size
	if source_size.x / source_size.y > target_aspect:
		crop.x = source_size.y * target_aspect
	else:
		crop.y = source_size.x / target_aspect
	var origin := Vector2(
		clampf(focus.x * source_size.x - crop.x * 0.5, 0.0, source_size.x - crop.x),
		clampf(focus.y * source_size.y - crop.y * 0.5, 0.0, source_size.y - crop.y)
	)
	return Rect2(origin, crop)
