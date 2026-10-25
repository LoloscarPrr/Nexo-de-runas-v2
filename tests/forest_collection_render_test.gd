extends SceneTree

## Real production navigation and GL framebuffer. Desktop captures do not
## claim device testing of the newly added Collection screen.
const MainScene = preload("res://scenes/main.tscn")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Art = preload("res://scripts/presentation/battle/card_art_registry.gd")
var app
var failures := 0
var output_directory := "res://build/forest_collection"

func _initialize() -> void:
	root.size = Vector2i(864, 1536)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_directory = argument.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	app = MainScene.instantiate()
	root.add_child(app)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	await _settle()
	await _click(app.find_child("MainCollectionButton", true, false))
	var view = app.collection_screen
	check(view.visible and view.visible_cards.size() == 20, "Actual Collection button opens the twenty-card catalog")
	await _capture("01_collection.png")
	_check_bounds(view)
	await _click(view.search_field)
	for letter in "chaman":
		var key := InputEventKey.new()
		key.pressed = true
		key.unicode = letter.unicode_at(0)
		root.push_input(key)
	await _settle()
	check(view.visible_cards.size() == 1 and view.visible_cards[0].get("set_id") == "BS-007", "Typed input reaches the real search field and accepts unaccented names")
	await _click(view.find_child("ResetCollectionFilters", true, false))
	var first = view.card_grid.get_child(0).get_node("Preview").card_view
	check(first._get_art_texture() != null, "Existing Brote illustration is reused in the collection grid")
	await _click(first)
	check(view.card_detail.visible, "Actual card tap opens inspection")
	await _capture("02_collection_brote.png")
	view.card_detail.hide_detail()
	for definition in Catalog.cards_for_domain("forest"):
		view.search_field.text = str(definition.get("set_id"))
		view.search_field.text_changed.emit(view.search_field.text)
		await _settle()
		check(view.visible_cards.size() == 1, "All twenty IDs can be located independently")
		var focus_bounds: Rect2 = view._focus_panel.get_global_rect().grow(0.1)
		for label in [view._focus_name, view._focus_metadata, view._focus_rules]:
			check(focus_bounds.encloses(label.get_global_rect()), "Selected names and full rules fit inside their panel")
		var preview = view.card_grid.get_child(0).get_node("Preview").card_view
		check(preview.card == definition, "Grid card uses the exact canonical definition")
		var expected_art := not Art.art_path(str(definition.get("id"))).is_empty()
		check((preview._get_art_texture() != null) == expected_art, "Only approved art is loaded; other cards retain the provisional renderer")
		await _click(preview)
		check(view.card_detail.visible and view.card_detail.card_view.card == definition, "Each card opens its own detail")
		await _settle()
		_check_detail_bounds(view.card_detail)
		if str(definition.get("set_id")) in ["BS-006", "BS-013", "BS-016", "BS-020"]:
			await _capture("detail_%s.png" % definition.get("set_id"))
		await _click(view.card_detail.find_child("CloseDetail", true, false))
		check(not view.card_detail.visible and view.visible_cards.size() == 1, "Closing detail preserves the current search")
	await _click(view.find_child("ResetCollectionFilters", true, false))
	view.card_scroll.scroll_vertical = int(view.card_scroll.get_v_scroll_bar().max_value)
	await _settle()
	var saved_scroll: int = view.card_scroll.scroll_vertical
	check(saved_scroll > 0, "Twenty-card grid scrolls to its final row")
	var last = view.card_grid.get_child(19).get_node("Preview").card_view
	await _click(last)
	check(view.card_detail.visible and view.card_detail.card_view.card.get("set_id") == "BS-020", "The final card remains touch reachable")
	view.card_detail.hide_detail()
	await _settle()
	check(view.card_scroll.scroll_vertical == saved_scroll, "Inspection preserves collection scroll position")
	await _capture("03_collection_final_row.png")
	var first_last_row = view.card_grid.get_child(18).get_node("Preview").card_view
	var point: Vector2 = first_last_row.get_global_rect().get_center()
	_pointer(point, true)
	var move := InputEventMouseMotion.new()
	move.button_mask = MOUSE_BUTTON_MASK_LEFT
	move.position = point + Vector2(0, -70)
	move.relative = Vector2(0, -70)
	root.push_input(move)
	await create_timer(0.60).timeout
	_pointer(move.position, false)
	await _settle()
	check(not view.card_detail.visible, "Dragging a catalog card does not open its detail")
	view.search_field.text = "Sin coincidencias"
	view.search_field.text_changed.emit(view.search_field.text)
	await _capture("04_collection_empty.png")
	check(view.visible_cards.is_empty() and view.find_child("CollectionEmptyState", true, false).visible, "Empty searches have visible recovery guidance")
	await _click(view.find_child("ResetCollectionFilters", true, false))
	root.size = Vector2i(864, 1968)
	await _settle()
	_check_bounds(view)
	await _capture("05_collection_tall.png")
	await _click(view.find_child("CollectionBack", true, false))
	check(app.menu_screen.visible and not view.visible, "Collection Back returns to the playable menu")
	await _click(app.find_child("MainVisualPilotButton", true, false))
	check(app.battle_screen.visible and Array(app.battle_screen.current_snapshot().get("hand", [])).slice(0, 3) == ["bs_001_brote_del_claro", "bs_006_lobo_de_manada", "bs_013_avatar_del_bosque"], "The illustrated pilot remains playable after browsing")
	print("Forest collection rendered checks: %d failures; captures in %s" % [failures, output_directory])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)

func _check_bounds(view: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(root.size)).grow(0.1)
	for node_name in ["CollectionContent", "CollectionSearch", "CollectionTypeFilter", "CollectionCostFilter", "CollectionSelectedCard", "CollectionScroll", "CollectionBack"]:
		var control := view.find_child(node_name, true, false) as Control
		check(bounds.encloses(control.get_global_rect()), "%s stays within the portrait viewport" % node_name)
	check(view.find_child("CollectionScroll", true, false).size.y >= 300, "The portrait catalog retains usable scrolling space")

func _check_detail_bounds(detail: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(root.size)).grow(0.1)
	for control in [detail.card_view, detail.title_label, detail.metadata_label, detail.stats_label, detail.effect_label, detail.find_child("CloseDetail", true, false)]:
		check(bounds.encloses(control.get_global_rect()), "Card art, metadata, rules and close action fit the portrait detail")

func _settle() -> void:
	for frame in range(4):
		await process_frame

func _pointer(point: Vector2, pressed_state: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = pressed_state
	root.push_input(event)

func _click(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	_pointer(point, true)
	_pointer(point, false)
	await _settle()

func _capture(filename: String) -> void:
	await _settle()
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture != null and not picture.is_empty(), "Real Godot framebuffer is available")
	if picture != null and not picture.is_empty():
		check(picture.save_png(output_directory.path_join(filename)) == OK, "Capture saved: %s" % filename)
