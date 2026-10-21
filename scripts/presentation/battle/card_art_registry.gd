class_name CardArtRegistry
extends RefCounted

## Presentation-only: maps canonical card IDs to individually exported art.
## Text, cost, attack, health, and effects remain dynamic in the card renderer.
## Never map an image by display name or by its position in the deck.

const PILOT_ART = {
	"bs_001_brote_del_claro": {
		"path": "res://assets/domains/forest/cards/art/bs_001_brote_del_claro.webp",
		"focus": Vector2(0.50, 0.42),
		"subject": Rect2(0.10, 0.04, 0.80, 0.88)
	},
	"bs_006_lobo_de_manada": {
		"path": "res://assets/domains/forest/cards/art/bs_006_lobo_de_manada.webp",
		"focus": Vector2(0.53, 0.41),
		"subject": Rect2(0.025, 0.13, 0.86, 0.63)
	},
	"bs_013_avatar_del_bosque": {
		"path": "res://assets/domains/forest/cards/art/bs_013_avatar_del_bosque.webp",
		"focus": Vector2(0.52, 0.37),
		"subject": Rect2(0.02, 0.0, 0.96, 0.96)
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
	# A wide hand slot must not crop away a portrait's head, paws or roots.
	# Expand to the protected subject, then fit proportionally into the slot.
	var subject := Rect2(Vector2.ZERO, source_size)
	if PILOT_ART.has(card_id):
		var normalized: Rect2 = PILOT_ART[card_id]["subject"]
		subject = Rect2(normalized.position * source_size, normalized.size * source_size)
		crop = crop.max(subject.size).min(source_size)
	var origin := Vector2(
		clampf(focus.x * source_size.x - crop.x * 0.5, 0.0, source_size.x - crop.x),
		clampf(focus.y * source_size.y - crop.y * 0.5, 0.0, source_size.y - crop.y)
	)
	if PILOT_ART.has(card_id):
		origin.x = clampf(origin.x, maxf(0.0, subject.end.x - crop.x), minf(subject.position.x, source_size.x - crop.x))
		origin.y = clampf(origin.y, maxf(0.0, subject.end.y - crop.y), minf(subject.position.y, source_size.y - crop.y))
	return Rect2(origin, crop)

static func art_destination(source_size: Vector2, slot: Rect2) -> Rect2:
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return slot
	var factor := minf(slot.size.x / source_size.x, slot.size.y / source_size.y)
	var fitted := source_size * factor
	return Rect2(slot.position + (slot.size - fitted) * 0.5, fitted)
