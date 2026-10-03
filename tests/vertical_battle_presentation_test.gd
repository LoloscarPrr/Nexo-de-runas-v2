extends SceneTree

const ViewScript = preload("res://scripts/presentation/battle/vertical_battle_view_polished.gd")
const CardScript = preload("res://scripts/presentation/battle/vertical_battle_card.gd")

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

	check(int(ProjectSettings.get_setting("display/window/size/viewport_width", 0)) == 864, "Canonical battle viewport uses the approved 864 width")
	check(int(ProjectSettings.get_setting("display/window/size/viewport_height", 0)) == 1536, "Canonical battle viewport uses the approved 1536 height")
	check(int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) == 1, "Android is locked to portrait orientation")
	check(view.find_child("MockupLogo", true, false) != null, "Mockup-faithful Presentation exposes the marked Nexo logo")
	check(view.find_child("SettingsGear", true, false) != null, "Mockup-faithful Presentation exposes the marked settings gear")
	check(view.find_child("RivalPanel", true, false) != null, "Mockup-faithful Presentation exposes the centered rival panel")
	check(view.find_child("BoardFrame", true, false) != null, "Mockup-faithful Presentation exposes the framed two-row board")
	check(view.find_child("HudStrip", true, false) != null, "Mockup-faithful Presentation exposes the four marked HUD modules")
	check(view.find_child("HandFrame", true, false) != null, "Mockup-faithful Presentation exposes the marked hand area")
	check(view.find_child("PlayerNexus", true, false) != null, "Mockup-faithful Presentation exposes the marked player Nexus")
	check(view.find_child("EndTurnButton", true, false) != null, "Mockup-faithful Presentation exposes the marked large end-turn button")

	var opening: Dictionary = view.current_snapshot()
	check(opening.get("lane_count", 0) == 5, "Vertical Presentation consumes five canonical lanes")
	check(view.player_lane_buttons.size() == 5, "Vertical Presentation renders five player lane controls")
	check(view.enemy_lane_buttons.size() == 5, "Vertical Presentation renders five enemy lane controls")
	check(view.hand_strip.get_child_count() == 4, "Vertical Presentation renders the four-card opening hand")
	check(opening.get("player_integrity", 0) == 20 and opening.get("enemy_integrity", 0) == 20, "Vertical Presentation starts at 20/20 Integrity")
	check(str(opening.get("essence_name", "")) == "Instinto", "Forest vertical HUD consumes the canonical essence name")
	check(view.end_turn_button != null, "Vertical Presentation exposes the canonical end-turn action")
	check(view.rival_integrity_bar != null, "Polished Presentation exposes the rival integrity bar")
	check(view.hand_strip.get_child(0).get_script() == CardScript, "Opening hand uses the physical Presentation card renderer")
	check(view.hand_strip.get_child(0).size == CardScript.HAND_CARD_SIZE, "Hand cards use the large mockup card size")
	check(opening.has("impulse_available"), "Application snapshot exposes Impulse availability to Presentation")

	# The first Forest starter card costs one Energy and is a creature. Playing it
	# through the view proves Presentation -> Application -> Domain wiring.
	view._on_hand_card_pressed(0)
	await process_frame
	check(view.selected_hand_index == 0, "Selecting a creature keeps it pending for lane targeting")
	check(view.session.can_target_player_lane(0, 4), "Application marks the fifth player lane as a legal target")
	view._on_lane_pressed("player", 4)
	await process_frame
	await process_frame
	var after_play: Dictionary = view.current_snapshot()
	var player_lanes: Array = after_play.get("player_lanes", [])
	check(player_lanes.size() == 5 and player_lanes[4] != null, "Vertical Presentation can play a real card into lane five")
	check(Array(after_play.get("hand", [])).size() == 3, "Successful vertical play removes the card from hand")
	check(after_play.get("energy_current", -1) == 0, "Successful vertical play pays canonical Energy")
	check(not view.event_label.text.is_empty(), "Vertical Presentation consumes battle events for visual feedback")
	var lane_card = null
	for child in view.player_lane_buttons[4].get_children():
		if child.get_script() == CardScript:
			lane_card = child
	check(lane_card != null, "Played units use the same physical card renderer on the board")
	if lane_card != null:
		check(lane_card.size == CardScript.COMPACT_CARD_SIZE, "Board cards use the large compact size from the mockup")
		var ratio: float = float(lane_card.size.x) / float(lane_card.size.y)
		var expected_ratio: float = float(CardScript.COMPACT_CARD_SIZE.x) / float(CardScript.COMPACT_CARD_SIZE.y)
		check(absf(ratio - expected_ratio) < 0.01, "Board cards keep a physical card aspect ratio")
		check(lane_card.size.y < view.player_lane_buttons[4].size.y, "Board card stays centered inside its touch lane")

	view._on_end_turn_pressed()
	await process_frame
	var after_round: Dictionary = view.current_snapshot()
	check(after_round.get("turn", 0) == 2, "Vertical end-turn action advances a complete player/CPU round")
	check(view.hand_strip.get_child_count() == Array(after_round.get("hand", [])).size(), "Scrollable hand stays synchronized after the round")

	print("Vertical battle Presentation checks: %d failures" % failures)
	quit(1 if failures else 0)
