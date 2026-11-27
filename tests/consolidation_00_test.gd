extends SceneTree

## Gate de consolidación: protege el catálogo canónico, los cuatro dominios,
## la apertura de batalla por Application y las cuatro artes aprobadas.
## No modifica Domain, los guardados ni las mecánicas de combate.

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const SessionScript = preload("res://scripts/application/battle/canonical_battle_session.gd")
const Art = preload("res://scripts/presentation/battle/card_art_registry.gd")

const DOMAINS = ["forest", "crypt", "tower", "forge"]
const PILOT_IDS = [
	"bs_001_brote_del_claro",
	"bs_006_lobo_de_manada",
	"bs_013_avatar_del_bosque",
	"bs_010_oso_musgoso"
]

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	check(Catalog.validate_catalog().is_empty(), "Canonical catalog remains valid")
	check(Catalog.all_card_ids().size() == 80, "Foundational set retains 80 cards")
	for domain in DOMAINS:
		var definitions: Array = Catalog.cards_for_domain(domain)
		check(definitions.size() == 20, "Domain retains 20 cards: %s" % domain)
		var deck: Array[String] = Catalog.starter_deck(domain)
		check(deck.size() == 20 and Catalog.validate_deck(deck, domain).is_empty(), "Domain deck stays legal: %s" % domain)
		var session = SessionScript.new()
		var snapshot: Dictionary = session.start_vs_cpu(domain)
		check(str(snapshot.get("player_domain", "")) == domain, "Application opens selected domain: %s" % domain)
		check(int(snapshot.get("lane_count", 0)) == 5, "Five tactical lanes: %s" % domain)
		check(Array(snapshot.get("player_lanes", [])).size() == 5 and Array(snapshot.get("enemy_lanes", [])).size() == 5, "Both lane arrays are complete: %s" % domain)
		check(Array(snapshot.get("hand", [])).size() == 4, "Four opening cards: %s" % domain)
		check(int(snapshot.get("player_integrity", 0)) == 20 and int(snapshot.get("enemy_integrity", 0)) == 20, "Both Nexuses start intact: %s" % domain)

	check(Art.PILOT_ART.size() == 4, "Only four approved individual pilot art mappings exist")
	for card_id in PILOT_IDS:
		var path: String = Art.art_path(card_id)
		check(path.begins_with("res://assets/domains/forest/cards/art/"), "Art belongs to its canonical domain: %s" % card_id)
		check(ResourceLoader.exists(path), "Godot imported the approved art: %s" % card_id)
		var texture = Art.load_art(card_id)
		check(texture != null, "Art loads as Texture2D: %s" % card_id)
		if texture == null:
			continue
		var source_size: Vector2 = texture.get_size()
		var safe_normalized: Rect2 = Art.PILOT_ART[card_id]["subject"]
		var protected_subject := Rect2(safe_normalized.position * source_size, safe_normalized.size * source_size)
		for slot in [Vector2(174, 115), Vector2(132, 157), Vector2(246, 298)]:
			var crop: Rect2 = Art.art_crop(card_id, source_size, slot)
			check(crop.grow(0.01).encloses(protected_subject), "Subject is preserved across crop: %s" % card_id)
			check(Rect2(Vector2.ZERO, source_size).grow(0.01).encloses(crop), "Crop fits art source: %s" % card_id)
			var fitted := Art.art_destination(crop.size, Rect2(Vector2.ZERO, slot))
			check(Rect2(Vector2.ZERO, slot).grow(0.01).encloses(fitted), "No art spills outside slot: %s" % card_id)

	var bear: Dictionary = Catalog.find_by_id("bs_010_oso_musgoso")
	check(str(bear.get("set_id", "")) == "BS-010", "Oso Musgoso keeps canonical identity")
	check(int(bear.get("cost", -1)) == 4 and int(bear.get("attack", -1)) == 4 and int(bear.get("health", -1)) == 6, "Oso Musgoso retains canonical stats")
	check(str(bear.get("effect_id", "")).is_empty() and str(bear.get("rarity", "")) == "common", "Oso Musgoso retains common rarity and no fabricated effect")

	print("Consolidation 00: %d failures" % failures)
	quit(1 if failures else 0)
