extends SceneTree

const DeckScript = preload("res://scripts/application/decks/forest_deck_editor.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const RepositoryScript = preload("res://scripts/infrastructure/persistence/json_save_repository.gd")
const MainScene = preload("res://scenes/main.tscn")
const BROTE := "bs_001_brote_del_claro"
const AVATAR := "bs_013_avatar_del_bosque"

class MemoryRepository:
	extends "res://scripts/application/ports/save_repository_port.gd"
	var slots := {}
	var save_error: Error = OK
	func save(slot: String, payload: Dictionary) -> Error:
		if save_error != OK:
			return save_error
		slots[slot] = payload.duplicate(true)
		return OK
	func load(slot: String) -> Dictionary:
		return Dictionary(slots.get(slot, {})).duplicate(true)
	func exists(slot: String) -> bool:
		return slots.has(slot)

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	var canonical_before := Catalog.all_cards()
	var memory := MemoryRepository.new()
	var editor := DeckScript.new(memory)
	check(editor.snapshot().get("count") == 20 and editor.snapshot().get("can_save"), "Editor begins with the unchanged valid starter")
	check(editor.deck_for_battle().is_empty() and not editor.snapshot().get("has_saved"), "Opening the editor does not activate or save a deck")
	var before: Dictionary = editor.snapshot()
	check(not editor.add_card(AVATAR).get("ok") and editor.snapshot() == before, "A twenty-first card is rejected without mutating the draft")
	editor.remove_card(BROTE)
	check(not editor.add_card("bs_003_lobo_joven").get("ok"), "A third ordinary copy is rejected even when the deck has room")
	check(not editor.add_card("ch_001_rata_de_osario").get("ok"), "A different-domain card cannot enter the Forest draft")
	check(not editor.add_card("unknown_card").get("ok"), "Unknown card IDs are rejected")
	check(not editor.save_deck().get("ok") and memory.slots.is_empty(), "An incomplete draft cannot be persisted")
	editor.remove_card(BROTE)
	editor.add_card(AVATAR)
	check(not editor.add_card(AVATAR).get("ok") and editor.snapshot().get("count") == 19, "A second unique Avatar is rejected independently of deck capacity")
	editor.add_card(BROTE)
	editor.set_name("  Bosque de prueba  ")
	check(editor.save_deck().get("ok") and editor.active_name() == "Bosque de prueba", "A complete legal deck is saved and activated with a trimmed name")
	var active := editor.deck_for_battle()
	check(active.size() == 20 and active.count(AVATAR) == 1 and active.count(BROTE) == 1, "Saved deck retains exact custom quantities")
	active.clear()
	check(editor.deck_for_battle().size() == 20, "A caller cannot mutate the saved active deck")
	editor.remove_card(BROTE)
	check(editor.snapshot().get("dirty") and editor.deck_for_battle().size() == 20, "Unsaved changes are independent of the active battle deck")
	editor.set_name("")
	check(not editor.save_deck().get("ok"), "An empty deck name cannot be saved")
	editor.restore_starter()
	editor.set_name("No se debe activar")
	memory.save_error = ERR_CANT_CREATE
	var saved_before := memory.load(DeckScript.SAVE_SLOT)
	check(not editor.save_deck().get("ok") and editor.active_name() == "Bosque de prueba", "Storage failures do not falsely activate an unsaved deck")
	check(memory.load(DeckScript.SAVE_SLOT) == saved_before and editor.snapshot().get("dirty"), "Storage failure preserves the previous save and editable draft")
	memory.save_error = OK
	var future := MemoryRepository.new()
	future.slots[DeckScript.SAVE_SLOT] = {"format_version": 2, "domain": "forest", "card_ids": [], "name": "Futuro"}
	var future_editor := DeckScript.new(future)
	check(not future_editor.save_deck().get("ok") and future.load(DeckScript.SAVE_SLOT).get("format_version") == 2, "A newer deck format is not silently overwritten")
	for bad_value in [{}, {"format_version": 1, "domain": "forest", "name": "Malo", "card_ids": [{}]}, {"format_version": {}, "card_ids": []}]:
		var damaged := MemoryRepository.new()
		damaged.slots[DeckScript.SAVE_SLOT] = bad_value
		var recovered := DeckScript.new(damaged)
		check(recovered.deck_for_battle().is_empty() and recovered.snapshot().get("count") == 20, "Malformed data falls back safely without being used in battle")
	var repository := RepositoryScript.new("user://tests_forest_deck_editor")
	repository.delete(DeckScript.SAVE_SLOT)
	var old_campaign := {"turn": 7, "integrity": 13, "nested": {"node": "campfire"}}
	repository.save("existing_campaign", old_campaign)
	var campaign_path := "user://tests_forest_deck_editor/existing_campaign.json"
	var campaign_bytes := FileAccess.get_file_as_bytes(campaign_path)
	var persistent := DeckScript.new(repository)
	persistent.remove_card(BROTE)
	persistent.remove_card(BROTE)
	persistent.add_card(AVATAR)
	persistent.add_card(BROTE)
	persistent.set_name("Mi bosque persistente")
	check(persistent.save_deck().get("ok"), "The real JSON adapter persists the constructed deck")
	var restored := DeckScript.new(RepositoryScript.new("user://tests_forest_deck_editor"))
	check(restored.deck_for_battle() == persistent.deck_for_battle() and restored.active_name() == persistent.active_name(), "A fresh session restores exact card order, counts and name from disk")
	check(FileAccess.get_file_as_bytes(campaign_path) == campaign_bytes, "The new deck slot leaves an existing campaign file byte for byte unchanged")
	var app = MainScene.instantiate()
	app.deck_repository = repository
	root.add_child(app)
	await process_frame
	await process_frame
	app.find_child("MainPlayButton", true, false).pressed.emit()
	var opening: Dictionary = app.battle_screen.current_snapshot()
	check(opening.get("hand") == restored.deck_for_battle().slice(0, 4), "Main JUGAR uses the restored constructed deck")
	check(opening.get("draw_count") == 16 and opening.get("lane_count") == 5 and opening.get("energy_current") == 1, "Custom decks retain normal hand, five lanes and starting Energy")
	app.battle_screen._on_end_turn_pressed()
	check(app.battle_screen.current_snapshot().get("turn") == 2, "A real CPU round advances with the constructed deck")
	app._return_to_menu()
	app.find_child("MainDeckbuilderButton", true, false).pressed.emit()
	var builder = app.deckbuilder_screen
	check(builder.visible and not app.menu_screen.visible, "Constructor menu entry opens the real editor")
	builder._change_quantity(BROTE, false)
	check(builder.save_button.disabled and builder.play_button.disabled, "Incomplete drafts disable save and play in the UI")
	builder.play_button.pressed.emit()
	check(builder.visible and not app.battle_screen.visible, "Even an invoked invalid save/play action cannot start a match")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.menu_screen.visible and app.deck_editor.snapshot().get("count") == 19, "Android Back preserves the unsaved draft in the current session")
	app._open_deckbuilder()
	check(app.deck_editor.snapshot().get("count") == 19, "Reopening Constructor retains that draft")
	app._return_to_menu()
	app._start_canonical_battle()
	check(app.battle_screen.current_snapshot().get("hand") == restored.deck_for_battle().slice(0, 4), "JUGAR still uses the last valid save while a draft is incomplete")
	app._return_to_menu()
	app._start_visual_pilot_battle()
	check(Array(app.battle_screen.current_snapshot().get("hand")).slice(0, 3) == [BROTE, "bs_006_lobo_de_manada", AVATAR], "The independent three-art pilot deck remains unchanged")
	check(Catalog.all_cards() == canonical_before, "Editing and playing do not mutate any of the eighty definitions")
	app.queue_free()
	await process_frame
	repository.delete(DeckScript.SAVE_SLOT)
	repository.delete("existing_campaign")
	print("Forest deck editor checks: %d failures" % failures)
	quit(1 if failures else 0)
