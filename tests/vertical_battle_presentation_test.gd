extends SceneTree

const ViewScript = preload("res://scripts/presentation/battle/vertical_battle_view.gd")

var failures := 0
var view

func _initialize() -> void:
	view = ViewScript.new()
	root.add_child(view)
	call_deferred("_run_checks")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _run_checks() -> void:
	await process_frame
	await process_frame
	view.start_battle("forest")
	await process_frame

	var opening := view.current_snapshot()
	check(opening.get("lane_count", 0) == 5, "Vertical Presentation consumes five canonical lanes")
	check(view.player_lane_buttons.size() == 5, "Vertical Presentation renders five player lane controls")
	check(view.enemy_lane_buttons.size() == 5, "Vertical Presentation renders five enemy lane controls")
	check(view.hand_strip.get_child_count() == 4, "Vertical Presentation renders the four-card opening hand")
	check(opening.get("player_integrity", 0) == 20 and opening.get("enemy_integrity", 0) == 20, "Vertical Presentation starts at 20/20 Integrity")
	check(str(opening.get("essence_name", "")) == "Instinto", "Forest vertical HUD consumes the canonical essence name")
	check(view.end_turn_button != null, "Vertical Presentation exposes the canonical end-turn action")

	# The first Forest starter card costs one Energy and is a creature. Playing it
	# through the view proves Presentation -> Application -> Domain wiring.
	view._on_hand_card_pressed(0)
	await process_frame
	check(view.selected_hand_index == 0, "Selecting a creature keeps it pending for lane targeting")
	check(view.session.can_target_player_lane(0, 4), "Application marks the fifth player lane as a legal target")
	view._on_lane_pressed("player", 4)
	await process_frame
	var after_play := view.current_snapshot()
	check(after_play.get("player_lanes", [])[4] != null, "Vertical Presentation can play a real card into lane five")
	check(after_play.get("hand", []).size() == 3, "Successful vertical play removes the card from hand")
	check(after_play.get("energy_current", -1) == 0, "Successful vertical play pays canonical Energy")

	view._on_end_turn_pressed()
	await process_frame
	var after_round := view.current_snapshot()
	check(after_round.get("turn", 0) == 2, "Vertical end-turn action advances a complete player/CPU round")
	check(view.hand_strip.get_child_count() == after_round.get("hand", []).size(), "Scrollable hand stays synchronized after the round")

	print("Vertical battle Presentation checks: %d failures" % failures)
	quit(1 if failures else 0)
