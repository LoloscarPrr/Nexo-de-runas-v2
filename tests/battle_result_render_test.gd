extends SceneTree

## Production scene and real lethal commands from near-terminal fixtures.
## These captures are desktop Godot renders, not Android device evidence.
const MainScene = preload("res://scenes/main.tscn")
const RepositoryScript = preload("res://scripts/infrastructure/persistence/json_save_repository.gd")
const DeckScript = preload("res://scripts/application/decks/forest_deck_editor.gd")
const BROTE := "bs_001_brote_del_claro"
const AVATAR := "bs_013_avatar_del_bosque"
var app
var repository
var failures := 0
var output_directory := "res://build/battle_result"

func _initialize() -> void:
	root.size = Vector2i(864, 1536)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_directory = argument.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	repository = RepositoryScript.new("user://tests_battle_result_render")
	repository.delete(DeckScript.SAVE_SLOT)
	var editor := DeckScript.new(repository)
	editor.remove_card(BROTE)
	editor.add_card(AVATAR)
	editor.set_name("Manada del resultado")
	editor.save_deck()
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
	await _click(app.find_child("MainPlayButton", true, false))
	var view = app.battle_screen
	var opening: Dictionary = view.current_snapshot()
	view.session._engine.turn = 6
	view.session._engine.energy_capacity = 6
	view.session._engine.energy_current = 6
	view.session._engine.player_integrity = 14
	view.session._engine.enemy_integrity = 1
	view.session._engine.player_lanes[0] = view.session._engine.create_unit(BROTE, true)
	view._snapshot = view.session.snapshot()
	view._render()
	await _click(view.find_child("EndTurnButton", true, false))
	check(view.result_screen.visible and view.result_screen.title_label.text == "VICTORIA", "Actual lethal end-turn touch opens victory")
	await _capture("01_victory.png")
	_check_bounds(view.result_screen)
	var ended: Dictionary = view.current_snapshot()
	await _click_point(Vector2(8, 8))
	check(view.result_screen.visible and view.current_snapshot() == ended, "Outside taps cannot dismiss the result or leak into combat")
	await _click(view.result_screen.find_child("ResultReviewBoard", true, false))
	check(not view.result_screen.visible, "Actual review action reveals the finished board")
	await _capture("02_finished_board.png")
	await _click(view.player_lane_buttons[0])
	check(view.card_detail.visible and view.card_detail.card_view.current_health == 2, "Final-board taps still inspect resolved card stats")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not view.card_detail.visible, "Android Back closes final-card inspection first")
	await _click(view.end_turn_button)
	check(view.result_screen.visible and view.current_snapshot() == ended, "Result footer reopens summary without advancing the ended game")
	await _click(view.result_screen.find_child("ResultRematch", true, false))
	check(view.current_snapshot() == opening and not view.result_screen.visible, "Actual rematch touch resets the exact original constructed-deck opening")
	check(view.event_label.text.is_empty(), "Rematch drops the previous terminal event label")
	await _capture("03_rematch.png")
	view.session._engine.turn = 8
	view.session._engine.player_integrity = 1
	view.session._engine.enemy_integrity = 12
	view.session._engine.enemy_lanes[4] = view.session._engine.create_unit(BROTE, true)
	view.session._engine.cpu_hand.clear()
	view._snapshot = view.session.snapshot()
	view._render()
	await _click(view.end_turn_button)
	check(view.current_snapshot().get("result") == "defeat" and view.result_screen.title_label.text == "DERROTA", "Existing CPU combat triggers the actual defeat screen")
	await _capture("04_defeat.png")
	_check_bounds(view.result_screen)
	root.size = Vector2i(864, 1968)
	await _capture("05_tall_defeat.png")
	_check_bounds(view.result_screen)
	await _click(view.result_screen.find_child("ResultReturnToMenu", true, false))
	check(app.menu_screen.visible and not view.visible, "Actual result return reaches the main menu")
	await _click(app.find_child("MainDeckbuilderButton", true, false))
	check(app.deck_editor.active_name() == "Manada del resultado" and app.deck_editor.deck_for_battle().count(AVATAR) == 1, "Completed games preserve the saved constructed deck")
	app._return_to_menu()
	await _click(app.find_child("MainVisualPilotButton", true, false))
	check(Array(view.current_snapshot().get("hand")).slice(0, 3) == [BROTE, "bs_006_lobo_de_manada", AVATAR], "Results navigation keeps the illustrated pilot accessible")
	app.queue_free()
	await process_frame
	repository.delete(DeckScript.SAVE_SLOT)
	print("Battle result rendered checks: %d failures; captures in %s" % [failures, output_directory])
	quit(1 if failures else 0)

func _check_bounds(result: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(root.size)).grow(0.1)
	for node_name in ["BattleResultFrame", "BattleResultTitle", "BattleResultSummary", "BattleResultNexus", "ResultRematch", "ResultReviewBoard", "ResultReturnToMenu"]:
		var control := result.find_child(node_name, true, false) as Control
		check(bounds.encloses(control.get_global_rect()), "%s fits inside portrait" % node_name)

func _settle() -> void:
	for frame in range(5):
		await process_frame

func _click(control: Control) -> void:
	await _click_point(control.get_global_rect().get_center())

func _click_point(point: Vector2) -> void:
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
