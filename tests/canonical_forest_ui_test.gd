extends SceneTree

const ViewScript = preload("res://scripts/ui/canonical_battle_view.gd")
const CardScript = preload("res://scripts/ui/canonical_forest_card.gd")
const LaneScript = preload("res://scripts/ui/canonical_forest_lane.gd")

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
	check(view != null, "Canonical Forest view instantiates")
	check(view.player_lanes.size() == 4, "Forest view has exactly four player lanes")
	check(view.enemy_lanes.size() == 4, "Forest view has exactly four enemy lanes")
	check(view.hand_area != null, "Forest view exposes a physical hand area")
	check(view.hand_area.get_child_count() == 4, "Opening hand renders four physical cards")
	if view.hand_area.get_child_count() > 0:
		check(view.hand_area.get_child(0).get_script() == CardScript, "Hand uses canonical physical card renderer")
	check(view.player_nexus != null and view.enemy_nexus != null, "Both Nexus orbs exist")
	check(view.deck_button != null and view.discard_button != null, "Deck and discard are visible controls")
	check(view.end_turn_button != null, "End-turn control exists")
	check(view.battle != null and view.battle.player_integrity == 20 and view.battle.enemy_integrity == 20, "Battle state is connected to 20/20 Nexus Integrity")
	check(view.battle.energy_capacity == 1, "Canonical Energy starts at capacity one")
	check(view.battle.essence_name() == "Instinto", "Forest view is connected to Instinto")

	# V4.1 regression: a played card must fill most of its lane while staying
	# completely inside it. This protects readability without returning to overflow.
	var lane := LaneScript.new()
	root.add_child(lane)
	lane.size = Vector2(220, 150)
	lane.set_lane(0, true)
	lane.set_unit({"id":"zorro_acechante","attack":2,"hp":2,"ready":true})
	await process_frame
	var played_card = lane.get_child(0) if lane.get_child_count() > 0 else null
	check(played_card != null, "Played card renderer exists inside a lane")
	if played_card != null:
		check(played_card.size.y >= 144.0, "Played card uses at least 96% of a 150px lane height")
		check(played_card.size.x >= 110.0, "Played card is wide enough to read combat information")
		check(played_card.position.x >= 0.0 and played_card.position.y >= 0.0, "Played card starts inside its lane")
		check(played_card.position.x + played_card.size.x <= lane.size.x + 0.1, "Played card remains inside lane width")
		check(played_card.position.y + played_card.size.y <= lane.size.y + 0.1, "Played card remains inside lane height")
	lane.queue_free()

	print("Canonical Forest UI checks: %d failures" % failures)
	quit(1 if failures else 0)
