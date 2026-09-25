class_name SketchAtlas
extends RefCounted

const SHEET := preload("res://assets/mockup_sketches/sketch_atlas.webp")

const REGIONS := {
	"title": Rect2(4, 4, 134, 31),
	"map": Rect2(142, 4, 66, 24),
	"balance": Rect2(212, 4, 91, 121),
	"totem": Rect2(307, 4, 45, 121),
	"portrait": Rect2(4, 129, 79, 77),
	"rule_panel": Rect2(87, 129, 79, 57),
	"turn": Rect2(170, 129, 79, 29),
	"draw": Rect2(253, 129, 79, 29),
	"end": Rect2(4, 210, 71, 55),
	"deck": Rect2(79, 210, 52, 64),
	"squirrels": Rect2(135, 210, 52, 68)
}

static func texture_for(key: String) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = SHEET
	atlas.region = REGIONS.get(key, Rect2())
	return atlas
