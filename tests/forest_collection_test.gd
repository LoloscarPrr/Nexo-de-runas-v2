extends SceneTree

const Collection = preload("res://scripts/application/collection/canonical_collection.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const TextScript = preload("res://scripts/presentation/cards/card_text.gd")
const MainScript = preload("res://scripts/main.gd")

var failures := 0
var app

func _initialize() -> void:
	app = MainScript.new()
	root.add_child(app)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	var canonical_before := Catalog.all_cards()
	var forest := Collection.cards_for_domain("forest")
	check(forest.size() == 20, "Forest catalog exposes exactly twenty definitions")
	check(forest[0].get("set_id") == "BS-001" and forest[19].get("set_id") == "BS-020", "Collection is ordered by foundational ID")
	for card in forest:
		check(card == Catalog.find_by_id(str(card.get("id"))), "Collection retains every canonical field")
		check(not TextScript.rules_text(card).is_empty(), "Every Forest card has readable rules or an explicit no-ability state")
	forest[0]["cost"] = 99
	Array(forest[0]["keywords"]).append("TEST_ONLY")
	check(Catalog.all_cards() == canonical_before, "Editing a returned result cannot mutate the canonical set")
	check(Collection.cards_for_domain("forest", "  CHAMAN  ").size() == 1, "Search ignores case, accents and outer whitespace")
	check(Collection.cards_for_domain("forest", "raíces").size() == 2, "Search accepts accented names")
	check(Collection.cards_for_domain("forest", "bs-013")[0].get("id") == "bs_013_avatar_del_bosque", "Foundational ID search resolves the real card")
	check(Collection.cards_for_domain("forest", "", "creature").size() == 13, "Creature filter uses canonical types")
	check(Collection.cards_for_domain("forest", "", "rite", 2).size() == 2, "Cost and type filters combine")
	check(Collection.cards_for_domain("forest", "lobo", "creature", 6).is_empty(), "No-match queries do not invent results")
	check(Collection.cards_for_domain("unknown").is_empty(), "Unknown domains have an empty catalog")
	check(TextScript.rules_text(Catalog.find_by_id("bs_011_anciano_de_raices")).contains("Enraizado") and TextScript.rules_text(Catalog.find_by_id("bs_011_anciano_de_raices")).contains("+0/+1"), "Detail preserves both keywords and effect text")
	check(TextScript.rules_text(Catalog.find_by_id("bs_014_savia_vital")).contains("+0/+2"), "Savia Vital displays the current permanent health bonus")
	await process_frame
	await process_frame
	app._start_visual_pilot_battle()
	var battle_before: Dictionary = app.battle_screen.current_snapshot()
	app._return_to_menu()
	app.find_child("MainCollectionButton", true, false).pressed.emit()
	await process_frame
	var view = app.collection_screen
	check(view.visible and not app.menu_screen.visible and not app.battle_screen.visible, "Real menu button opens Collection exclusively")
	check(view.visible_cards.size() == 20 and view.card_grid.get_child_count() == 20, "Collection renders all twenty cards")
	view.search_field.text = "lobo"
	view.search_field.text_changed.emit(view.search_field.text)
	check(view.visible_cards.size() == 2, "Search updates the displayed list")
	view.type_filter.select(2)
	view.type_filter.item_selected.emit(2)
	check(view.visible_cards.is_empty() and view.find_child("CollectionEmptyState", true, false).visible, "Combined filters show a useful empty state")
	view.find_child("ResetCollectionFilters", true, false).pressed.emit()
	check(view.visible_cards.size() == 20 and view.search_field.text.is_empty(), "Clear restores the complete catalog")
	view.search_field.text = "BS-013"
	view.search_field.text_changed.emit(view.search_field.text)
	view.card_grid.get_child(0).get_node("Preview").inspection_requested.emit()
	check(view.card_detail.visible and view.card_detail.card_view.card.get("id") == "bs_013_avatar_del_bosque", "Collection opens the shared portrait detail")
	check(view.card_detail.stats_label.text.contains("ATQ 6") and view.card_detail.stats_label.text.contains("SAL 8"), "Collection inspection shows base stats, independent of combat buffs")
	check(view.card_detail.metadata_label.text.contains("BS-013") and view.card_detail.metadata_label.text.contains("Única"), "Detail includes the real ID and unique metadata")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(view.visible and not view.card_detail.visible, "Android Back closes the detail before leaving Collection")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.menu_screen.visible and not view.visible, "Android Back returns to the actual menu")
	check(app.battle_screen.current_snapshot() == battle_before, "Browsing never mutates the existing battle")
	check(Catalog.all_cards() == canonical_before, "The full eighty-card set remains unchanged after browsing")
	app.queue_free()
	await process_frame
	print("Forest collection checks: %d failures" % failures)
	quit(1 if failures else 0)
