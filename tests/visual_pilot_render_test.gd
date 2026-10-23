extends SceneTree

## Real production scene + deterministic mid-battle fixture; requires GL/Xvfb.
## Captures are Godot renders, not evidence of execution on an Android device.
const ViewScript = preload("res://scripts/presentation/battle/vertical_battle_view_faithful.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const CardScript = preload("res://scripts/presentation/battle/vertical_battle_card_faithful.gd")
const PILOT: Array[String] = ["bs_001_brote_del_claro", "bs_006_lobo_de_manada", "bs_013_avatar_del_bosque"]

var view
var failures := 0
var output_directory := "res://build/visual_pilot"

func _initialize() -> void:
	root.size = Vector2i(864, 1536)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output_directory = argument.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_directory))
	view = ViewScript.new()
	root.add_child(view)
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run() -> void:
	await process_frame
	view.start_battle("forest")
	var deck: Array[String] = Catalog.starter_deck("forest")
	deck.erase(PILOT[0])
	deck.erase(PILOT[1])
	deck.pop_back()
	deck.push_front(PILOT[2])
	deck.push_front(PILOT[1])
	deck.push_front(PILOT[0])
	view._snapshot = view.session.start_vs_cpu("forest", deck)
	# Seed a round-six fixture; all subsequent summons use the real commands,
	# costs, on-summon effects and CPU turn, without changing production rules.
	view.session._engine.turn = 6
	view.session._engine.energy_capacity = 6
	view.session._engine.energy_current = 6
	view._snapshot = view.session.snapshot()
	view._render()
	await _capture("01_hand_three_cards.png")
	var viewport_bounds := Rect2(Vector2.ZERO, Vector2(root.size))
	for node_name in ["MockupComposition", "PlayerNexus", "EndTurnButton", "SettingsGear"]:
		var control: Control = view.find_child(node_name, true, false)
		check(viewport_bounds.grow(0.1).encloses(control.get_global_rect()), "%s stays fully inside 16:9 portrait" % node_name)
	var before_menu: Dictionary = view.current_snapshot()
	await _click_control(view.find_child("SettingsGear", true, false))
	check(view.battle_menu.visible, "Real gear click opens the battle menu")
	await _capture("04_battle_menu.png")
	await _click_control(view.find_child("ResumeBattle", true, false))
	check(not view.battle_menu.visible and view.current_snapshot() == before_menu, "Continuing preserves the exact battle snapshot")
	await _check_full_hand_gestures()
	check(view.player_lane_buttons.size() == 5 and view.enemy_lane_buttons.size() == 5, "Five real lanes per side")
	for index in range(3):
		var renderer = view.hand_strip.get_child(index)
		check(renderer._get_art_texture() != null, "Hand illustration is loaded: %s" % PILOT[index])
		# Exercise the production press-and-hold signal, including consumption
		# of the release so inspecting a card cannot accidentally play it.
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.position = renderer.get_global_rect().get_center()
		press.pressed = true
		root.push_input(press)
		await create_timer(0.60).timeout
		check(view.card_detail.visible, "Hand hold opens portrait detail")
		var release := InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.position = press.position
		release.pressed = false
		root.push_input(release)
		check(view.card_detail.card_view.card.get("id", "") == PILOT[index], "Detail uses the correct canonical ID")
		check(view.card_detail.card_view._get_art_texture() != null, "Detail illustration is loaded")
		await _capture("%s_detail.png" % PILOT[index].get_slice("_", 1))
		view.card_detail.hide_detail()
		await create_timer(0.12).timeout
		check(renderer.scale.x >= 0.999, "Inspected card restores its physical pose after closing")
		check(view.selected_hand_index == -1 and view.session.snapshot().get("energy_current") == 6, "Inspection leaves selection and combat untouched")

	view._on_hand_card_pressed(0)
	view._on_lane_pressed("player", 0)
	view._on_hand_card_pressed(0)
	view._on_lane_pressed("player", 1)
	check(view.session.snapshot().get("energy_current") == 2, "Real Brote and Lobo summons pay 1 + 3 Energy")
	var wolf: Dictionary = view.session.snapshot()["player_lanes"][1]
	check(wolf.get("attack") == 4 and wolf.get("hp") == 4, "Lobo's existing adjacency effect remains dynamic at 4/4")
	view._on_end_turn_pressed()
	check(view.session.snapshot().get("turn") == 7, "The real CPU round still advances")
	view._on_hand_card_pressed(0)
	view._on_lane_pressed("player", 4)
	check(view.session.snapshot().get("energy_current") == 0, "Avatar pays its actual six Energy")
	await _capture("02_board_three_cards.png")
	var lanes: Array = view.session.snapshot().get("player_lanes", [])
	for index in range(3):
		var lane: int = [0, 1, 4][index]
		check(lanes[lane] != null and lanes[lane].get("id", "") == PILOT[index], "Pilot creature is on the real board")
		var renderer = view.player_lane_buttons[lane].find_child("UnitCard%d" % lane, false, false)
		check(renderer != null and renderer._get_art_texture() != null, "Board illustration is loaded")
		view._on_lane_pressed("player", lane)
		check(view.card_detail.visible, "Tapping a played card opens portrait detail")
		check(view.card_detail.card_view.current_attack == int(lanes[lane].get("attack")), "Board detail uses current ATQ")
		check(view.card_detail.card_view.current_health == int(lanes[lane].get("hp")), "Board detail uses current SAL")
		await _capture("%s_board_detail.png" % PILOT[index].get_slice("_", 1))
		view.card_detail.hide_detail()

	# Short taps retain the existing select / cancel interaction.
	if view.hand_strip.get_child_count() > 0:
		view.hand_strip.get_child(0).pressed.emit()
		check(view.selected_hand_index == 0, "Short tap selects a hand card")
		view.hand_strip.get_child(0).pressed.emit()
		check(view.selected_hand_index == -1, "Second short tap cancels selection")
	# Inspect the same modal on a tall Redmi-like aspect ratio.
	root.size = Vector2i(864, 1968)
	view._on_lane_pressed("player", 4)
	await _capture("03_tall_portrait_detail.png")
	var bounds: Rect2 = view.card_detail.card_view.get_global_rect()
	check(Rect2(Vector2.ZERO, Vector2(root.size)).encloses(bounds), "Tall portrait detail remains inside the viewport")
	view.card_detail.hide_detail()
	await _capture("06_tall_portrait_board.png")
	for node_name in ["PlayerNexus", "EndTurnButton", "SettingsGear"]:
		var control: Control = view.find_child(node_name, true, false)
		check(Rect2(Vector2.ZERO, Vector2(root.size)).encloses(control.get_global_rect()), "%s stays fully inside tall portrait" % node_name)
	print("Visual pilot rendered checks: %d failures; captures in %s" % [failures, output_directory])
	view.queue_free()
	await process_frame
	quit(1 if failures else 0)

func _click_control(control: Control) -> void:
	var point := control.get_global_rect().get_center()
	_pointer_button(point, true)
	_pointer_button(point, false)
	await process_frame
	await process_frame

func _pointer_button(point: Vector2, pressed_state: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = point
	event.pressed = pressed_state
	root.push_input(event)

func _check_full_hand_gestures() -> void:
	var saved_hand: Array[String] = view.session._engine.hand.duplicate()
	var saved_draw: Array[String] = view.session._engine.draw_pile.duplicate()
	while view.session._engine.hand.size() < 8:
		view.session._engine.draw_card()
	view._snapshot = view.session.snapshot()
	view._render()
	await process_frame
	await process_frame
	var scroll: ScrollContainer = view.hand_strip.get_parent()
	scroll.scroll_horizontal = int(scroll.get_h_scroll_bar().max_value)
	await process_frame
	var saved_scroll := scroll.scroll_horizontal
	check(saved_scroll > 0, "Eight-card hand can scroll to its final card")
	await _click_control(view.hand_strip.get_child(7))
	check(view.selected_hand_index == 7, "Final card remains reachable in a full hand")
	check(absi(scroll.scroll_horizontal - saved_scroll) <= 1, "Selection keeps the hand at the same scroll position")
	await _capture("05_full_hand_selected.png")
	await _click_control(view.hand_strip.get_child(7))
	check(view.selected_hand_index == -1, "Second short tap still cancels the last card")
	var point: Vector2 = view.hand_strip.get_child(7).get_global_rect().get_center()
	_pointer_button(point, true)
	var motion := InputEventMouseMotion.new()
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion.position = point + Vector2(-60, 0)
	motion.relative = Vector2(-60, 0)
	root.push_input(motion)
	await create_timer(0.60).timeout
	check(not view.card_detail.visible, "Dragging a card does not trigger long-press inspection")
	_pointer_button(motion.position, false)
	await process_frame
	check(view.selected_hand_index == -1, "Dragging does not accidentally select a card")
	_pointer_button(point, true)
	scroll.scroll_started.emit()
	await create_timer(0.60).timeout
	check(not view.card_detail.visible, "Native touch-scroll signal cancels pending inspection")
	_pointer_button(point, false)
	await process_frame
	check(view.selected_hand_index == -1, "Touch-scroll release does not select a card")
	view.session._engine.hand = saved_hand
	view.session._engine.draw_pile = saved_draw
	scroll.scroll_horizontal = 0
	view._snapshot = view.session.snapshot()
	view._render()
	await process_frame
	await process_frame

func _capture(filename: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	check(picture != null and not picture.is_empty(), "Real framebuffer is available")
	if picture != null and not picture.is_empty():
		check(picture.save_png(output_directory.path_join(filename)) == OK, "Screenshot saved: %s" % filename)
