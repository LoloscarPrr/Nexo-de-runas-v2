extends SceneTree

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Art = preload("res://scripts/presentation/battle/card_art_registry.gd")
const CardScript = preload("res://scripts/presentation/battle/vertical_battle_card_faithful.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var pilot := {
		"bs_001_brote_del_claro": ["BS-001", 1, 1, 2],
		"bs_006_lobo_de_manada": ["BS-006", 3, 3, 3],
		"bs_013_avatar_del_bosque": ["BS-013", 6, 6, 8]
	}
	for card_id in pilot:
		var expected: Array = pilot[card_id]
		var card: Dictionary = Catalog.find_by_id(card_id)
		check(not card.is_empty(), "Canonical pilot id exists: %s" % card_id)
		check(str(card.get("set_id", "")) == expected[0], "Official set id unchanged for %s" % card_id)
		check(int(card.get("cost", -1)) == expected[1], "Original cost unchanged for %s" % card_id)
		check(int(card.get("attack", -1)) == expected[2], "Original attack unchanged for %s" % card_id)
		check(int(card.get("health", -1)) == expected[3], "Original health unchanged for %s" % card_id)
		var path := Art.art_path(card_id)
		check(path.begins_with("res://assets/domains/forest/cards/art/"), "Canonical art root for %s" % card_id)
		check(path.get_extension() == "webp", "WebP asset format for %s" % card_id)
		var source_rect := Art.art_crop(card_id, Vector2(384, 512), Vector2(176, 117))
		check(source_rect.size.x > 0 and source_rect.size.y > 0, "Valid hand art crop for %s" % card_id)
		check(source_rect.position.x >= 0 and source_rect.position.y >= 0, "Crop stays in illustration for %s" % card_id)
		check(source_rect.end.x <= 384.001 and source_rect.end.y <= 512.001, "Crop does not overrun image for %s" % card_id)

		var renderer = CardScript.new()
		renderer.configure(card, 99, 77, false, false, true)
		check(renderer.current_attack == 99 and renderer.current_health == 77, "ATQ/SAL remain dynamic for %s" % card_id)
		renderer.free()

	check(Art.art_path("bs_003_lobo_joven").is_empty(), "Unimplemented Forest art remains unassigned")
	check(Art.art_path("ch_001_rata_de_osario").is_empty(), "Other domains retain existing fallback")
	check(Art.art_crop("", Vector2(384, 512), Vector2(134, 159)).size.x > 0, "Compact art crop valid")
	print("Visual pilot three cards: %d failures" % failures)
	quit(1 if failures else 0)
