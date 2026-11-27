extends SceneTree

## Actual menu -> edit -> save -> fresh app -> JUGAR -> CPU round.
## All disk writes stay in this test's isolated save root. Requires GL/Xvfb.
const MainScene = preload("res://scenes/main.tscn")
const RepositoryScript = preload("res://scripts/infrastructure/persistence/json_save_repository.gd")
const DeckScript = preload("res://scripts/application/decks/forest_deck_editor.gd")
const BROTE := "bs_001_brote_del_claro"
const AVATAR := "bs_013_avatar_del_bosque"
var app
var repository
var failures := 0
var output_directory := "res://build/forest_deckbuilder"

func _initialize() -> void:
	root.size = Vector2i(864, 1536)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_directory = argument.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	repository = RepositoryScript.new("user://tests_forest_deckbuilder_render")
	repository.delete(DeckScript.SAVE_SLOT)
	app = MainScene.instantiate()
	app.deck_repository = repository
	root.add_child(app)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	await _settle()
	await _click(app.find_child("MainDeckbuilderButton", true, false))
	var builder = app.deckbuilder_screen
	check(builder.visible and app.deck_editor.snapshot().get("count") == 20, "Actual menu opens the functional starter editor")
	_check_bounds(builder)
	await _capture("01_deckbuilder.png")
	await _search(builder, "BS-001")
	var brote_tile = builder.card_grid.get_child(0)
	check(brote_tile.get_node("Preview").card_view._get_art_texture() != null, "Existing Brote art remains in the editable catalog")
	await _click(brote_tile.get_node("QuantityControls/Remove"))
	check(app.deck_editor.snapshot().get("count") == 19 and builder.save_button.disabled and builder.play_button.disabled, "Actual minus touch removes one card and blocks an incomplete deck")
	await _capture("02_incomplete_deck.png")
	await _search(builder, "BS-013")
	var avatar_tile = builder.card_grid.get_child(0)
	check(not avatar_tile.get_node("QuantityControls/Add").disabled, "Avatar can be added after freeing space")
	await _click(avatar_tile.get_node("QuantityControls/Add"))
	check(app.deck_editor.snapshot().get("count") == 20 and app.deck_editor.card_state(AVATAR).get("quantity") == 1, "Actual plus touch inserts the unique Avatar")
	check(avatar_tile.get_node("QuantityControls/Add").disabled, "A second unique copy is unavailable")
	await _click(avatar_tile.get_node("Preview").card_view)
	check(builder.card_detail.visible and builder.card_detail.stats_label.text.contains("SAL 8"), "Builder card tap opens the shared accurate portrait detail")
	await _capture("03_deckbuilder_avatar.png")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not builder.card_detail.visible and builder.visible, "Android Back closes inspection before leaving the editor")
	builder.name_field.text = "Manada del Avatar"
	builder.name_field.text_changed.emit(builder.name_field.text)
	await _click(builder.save_button)
	check(app.deck_editor.active_name() == "Manada del Avatar" and repository.exists(DeckScript.SAVE_SLOT), "Actual save touch persists and activates the valid custom deck")
	var saved_ids: Array[String] = app.deck_editor.deck_for_battle()
	await _click(builder.find_child("ResetCollectionFilters", true, false))
	await _click(builder.in_deck_button)
	check(builder.visible_cards.size() == 11, "In-deck filter shows the ten starter definitions plus Avatar")
	await _capture("04_saved_custom_deck.png")
	await _click(builder.find_child("ResetCollectionFilters", true, false))
	check(not builder.in_deck_button.button_pressed and builder.visible_cards.size() == 20, "Clear also resets the in-deck-only filter")
	builder.card_scroll.scroll_vertical = int(builder.card_scroll.get_v_scroll_bar().max_value)
	await _settle()
	var scroll_before: int = builder.card_scroll.scroll_vertical
	check(scroll_before > 0, "The complete editable catalog scrolls to the final card")
	var last = builder.card_grid.get_child(19)
	await _click(last.get_node("Preview").card_view)
	check(builder.card_detail.visible and builder.card_detail.card_view.card.get("set_id") == "BS-020", "Final catalog entry remains inspectable with quantity controls present")
	builder.card_detail.hide_detail()
	await _settle()
	check(builder.card_scroll.scroll_vertical == scroll_before, "Inspection keeps the editable catalog scroll position")
	var totem = builder.card_grid.get_child(18)
	await _click(totem.get_node("QuantityControls/Remove"))
	check(builder.card_scroll.scroll_vertical == scroll_before and app.deck_editor.snapshot().get("count") == 19, "Quantity changes at the end of the catalog preserve scroll position")
	await _click(totem.get_node("QuantityControls/Add"))
	check(app.deck_editor.snapshot().get("count") == 20, "A removed copy can be restored without leaving the final row")
	root.size = Vector2i(864, 1968)
	await _settle()
	_check_bounds(builder)
	await _capture("05_deckbuilder_tall.png")
	app.queue_free()
	await _settle()
	root.size = Vector2i(864, 1536)
	app = MainScene.instantiate()
	app.deck_repository = RepositoryScript.new("user://tests_forest_deckbuilder_render")
	root.add_child(app)
	await _settle()
	check(app.deck_editor.deck_for_battle() == saved_ids, "A fresh production scene restores the exact persisted deck")
	await _click(app.find_child("MainPlayButton", true, false))
	var battle: Dictionary = app.battle_screen.current_snapshot()
	check(app.battle_screen.visible and battle.get("hand") == saved_ids.slice(0, 4), "Actual JUGAR uses the reloaded custom deck")
	check(battle.get("lane_count") == 5 and battle.get("draw_count") == 16 and battle.get("energy_current") == 1, "The constructed deck retains normal five-lane starting rules")
	await _click(app.battle_screen.find_child("EndTurnButton", true, false))
	check(app.battle_screen.current_snapshot().get("turn") == 2, "The existing CPU round runs from the constructed deck")
	await _capture("06_custom_deck_battle.png")
	app._return_to_menu()
	await _click(app.find_child("MainDeckbuilderButton", true, false))
	await _click(app.deckbuilder_screen.play_button)
	check(app.battle_screen.visible and app.battle_screen.current_snapshot().get("turn") == 1, "Save-and-play launches a fresh real match from the builder")
	app.queue_free()
	await process_frame
	repository.delete(DeckScript.SAVE_SLOT)
	print("Forest deckbuilder rendered checks: %d failures; captures in %s" % [failures, output_directory])
	quit(1 if failures else 0)

func _search(builder: Control, query: String) -> void:
	builder.search_field.text = query
	builder.search_field.text_changed.emit(query)
	await _settle()

func _check_bounds(builder: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(root.size)).grow(0.1)
	for node_name in ["CollectionContent", "CollectionSearch", "DeckSummary", "DeckName", "DeckCount", "DeckCostCurve", "SaveForestDeck", "PlayForestDeck", "CollectionScroll", "CollectionBack"]:
		var control := builder.find_child(node_name, true, false) as Control
		check(bounds.encloses(control.get_global_rect()), "%s fits the portrait viewport" % node_name)
	check(builder.card_scroll.size.y >= 300, "Builder retains a usable touch-scroll catalog")
	for tile in builder.card_grid.get_children():
		check(tile.size.x <= builder.card_scroll.size.x, "Card quantity controls do not force horizontal overflow")

func _settle() -> void:
	for frame in range(5):
		await process_frame

func _click(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	for state in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.pressed = state
		root.push_input(event)
	await _settle()

func _capture(filename: String) -> void:
	await _settle()
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture != null and not picture.is_empty(), "Real Godot framebuffer is available")
	if picture != null and not picture.is_empty():
		check(picture.save_png(output_directory.path_join(filename)) == OK, "Capture saved: %s" % filename)
