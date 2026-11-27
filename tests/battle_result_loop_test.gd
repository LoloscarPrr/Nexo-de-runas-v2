extends SceneTree

## Fixtures seed a near-terminal position; the actual Application round
## resolves the result. Production rules and save formats remain unchanged.
const SessionScript = preload("res://scripts/application/battle/canonical_battle_session.gd")
const ViewScript = preload("res://scripts/presentation/battle/vertical_battle_view_faithful.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const MainScene = preload("res://scenes/main.tscn")
const RepositoryScript = preload("res://scripts/infrastructure/persistence/json_save_repository.gd")
const DeckScript = preload("res://scripts/application/decks/forest_deck_editor.gd")
const BROTE := "bs_001_brote_del_claro"
const AVATAR := "bs_013_avatar_del_bosque"
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	var session := SessionScript.new()
	check(session.restart_vs_cpu().is_empty(), "Rematch does not create a game before setup")
	var custom: Array[String] = Catalog.starter_deck("forest")
	custom.erase(BROTE)
	custom.push_front(AVATAR)
	var opponent: Array[String] = Catalog.starter_deck("crypt")
	var opening := session.start_vs_cpu("forest", custom, "crypt", opponent)
	var expected_hand := custom.slice(0, 4)
	var expected_cpu := opponent.slice(0, 4)
	custom.clear()
	opponent.clear()
	check(session.restart_vs_cpu() == opening, "Rematch cannot reset an ongoing match")
	_seed_win(session)
	var ended := session.end_round()
	check(ended.get("snapshot", {}).get("result") == "victory", "Real lethal combat produces the victory snapshot")
	var end_events := 0
	for event in Array(ended.get("events", [])):
		if event.get("type") == "BATTLE_ENDED":
			end_events += 1
	check(end_events == 1, "Lethal combat emits one terminal event")
	var rematch := session.restart_vs_cpu()
	check(rematch.get("hand") == expected_hand and session._engine.cpu_hand == expected_cpu, "Rematch preserves independent copies of both actual decks")
	check(rematch.get("enemy_domain") == "crypt", "Rematch retains the opponent domain")
	check(rematch.get("player_integrity") == 20 and rematch.get("enemy_integrity") == 20 and rematch.get("energy_current") == 1 and rematch.get("turn") == 1, "Rematch resets to ordinary starting resources")
	check(rematch.get("player_lanes") == [null, null, null, null, null] and rematch.get("enemy_lanes") == [null, null, null, null, null], "Rematch clears all five lanes on both sides")
	var view = ViewScript.new()
	root.add_child(view)
	await process_frame
	view.start_visual_pilot_battle()
	_seed_win(view.session)
	view._snapshot = view.session.snapshot()
	view._on_end_turn_pressed()
	check(view.result_screen.visible and view.result_screen.title_label.text == "VICTORIA", "A real terminal action opens the production victory screen")
	check(view.selected_hand_index == -1, "Victory clears stale card targeting")
	var terminal: Dictionary = view.current_snapshot()
	view.result_screen.find_child("ResultReviewBoard", true, false).pressed.emit()
	check(not view.result_screen.visible and view.end_turn_button.text == "VER\nRESULTADO", "Review exposes the final board with a result action")
	view._on_hand_card_pressed(0)
	check(view.card_detail.visible and view.selected_hand_index == -1, "Final hand taps inspect instead of selecting a card to play")
	view.handle_back()
	view._on_lane_pressed("player", 0)
	check(view.card_detail.visible, "Final board cards retain live-stat inspection")
	view.handle_back()
	view._on_impulse_pressed()
	view._on_end_turn_pressed()
	check(view.current_snapshot() == terminal and view.result_screen.visible, "Final controls cannot advance or mutate the ended match")
	view.result_screen.find_child("ResultRematch", true, false).pressed.emit()
	check(not view.result_screen.visible and view.current_snapshot().get("result") == "ongoing", "Rematch closes the result and starts a fresh game")
	check(view.event_label.text.is_empty(), "Rematch clears event text from the previous battle")
	check(Array(view.current_snapshot().get("hand")).slice(0, 3) == [BROTE, "bs_006_lobo_de_manada", AVATAR], "The independent pilot deck survives rematch")
	_seed_loss(view.session)
	view._snapshot = view.session.snapshot()
	view._on_end_turn_pressed()
	check(view.current_snapshot().get("result") == "defeat" and view.result_screen.title_label.text == "DERROTA", "A real enemy lethal attack opens the defeat screen")
	view.queue_free()
	await process_frame
	var repository := RepositoryScript.new("user://tests_battle_result_loop")
	repository.delete(DeckScript.SAVE_SLOT)
	var editor := DeckScript.new(repository)
	editor.remove_card(BROTE)
	editor.add_card(AVATAR)
	editor.set_name("Manada del cierre")
	check(editor.save_deck().get("ok"), "Constructed deck fixture uses the real save adapter")
	var before_bytes := FileAccess.get_file_as_bytes("user://tests_battle_result_loop/constructed_forest_deck_v1.json")
	var app = MainScene.instantiate()
	app.deck_repository = repository
	root.add_child(app)
	await process_frame
	app._start_canonical_battle()
	var saved_hand: Array = app.battle_screen.current_snapshot().get("hand")
	_seed_win(app.battle_screen.session)
	app.battle_screen._snapshot = app.battle_screen.session.snapshot()
	app.battle_screen._on_end_turn_pressed()
	app.battle_screen.result_screen.find_child("ResultRematch", true, false).pressed.emit()
	check(app.battle_screen.current_snapshot().get("hand") == saved_hand, "Constructed-deck rematch uses the active match's cards")
	_seed_loss(app.battle_screen.session)
	app.battle_screen._snapshot = app.battle_screen.session.snapshot()
	app.battle_screen._on_end_turn_pressed()
	app.battle_screen.result_screen.find_child("ResultReturnToMenu", true, false).pressed.emit()
	check(app.menu_screen.visible and not app.battle_screen.visible, "Result return goes to the real main menu")
	check(FileAccess.get_file_as_bytes("user://tests_battle_result_loop/constructed_forest_deck_v1.json") == before_bytes, "Victory, defeat, rematch and menu leave the saved deck byte for byte intact")
	app._start_canonical_battle()
	check(app.battle_screen.current_snapshot().get("hand") == saved_hand and not app.battle_screen.result_screen.visible, "JUGAR after a result starts cleanly from the saved deck")
	app.queue_free()
	await process_frame
	repository.delete(DeckScript.SAVE_SLOT)
	print("Battle result loop checks: %d failures" % failures)
	quit(1 if failures else 0)

func _seed_win(session: RefCounted) -> void:
	session._engine.enemy_integrity = 1
	session._engine.player_lanes[0] = session._engine.create_unit(BROTE, true)
	session._engine.enemy_lanes[0] = null

func _seed_loss(session: RefCounted) -> void:
	session._engine.player_integrity = 1
	session._engine.enemy_integrity = 20
	session._engine.enemy_lanes[4] = session._engine.create_unit(BROTE, true)
	session._engine.player_lanes[4] = null
	session._engine.cpu_hand.clear()
