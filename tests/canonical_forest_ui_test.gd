extends SceneTree

const ViewScript = preload("res://scripts/ui/canonical_battle_view.gd")
const CardScript = preload("res://scripts/ui/canonical_forest_card.gd")

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
	print("Canonical Forest UI checks: %d failures" % failures)
	quit(1 if failures else 0)
