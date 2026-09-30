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
	check(view.player_lanes.size() == 5, "Forest adapter exposes exactly five player lanes")
	check(view.enemy_lanes.size() == 5, "Forest adapter exposes exactly five enemy lanes")
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
	check(view.battle.player_lanes.size() == 5, "Visual adapter and battle core agree on five lanes")

	# Asset Pack v1.2 regression: las cartas jugadas deben tener presencia real.
	# Se permite un pequeño bleed vertical controlado, pero nunca horizontal.
	var lane := LaneScript.new()
	root.add_child(lane)
	lane.size = Vector2(220, 150)
	lane.set_lane(0, true)
	lane.set_unit({"id":"zorro_acechante","attack":2,"hp":2,"ready":true})
	await process_frame
	var played_card = lane.get_child(0) if lane.get_child_count() > 0 else null
	check(played_card != null, "Played card renderer exists inside a lane")
	if played_card != null:
		check(played_card.size.y >= 160.0, "Played card gains vertical presence beyond the old compact size")
		check(played_card.size.x >= 145.0, "Played card is substantially wider and readable on table")
		check(played_card.position.x >= 0.0, "Played card remains horizontally inside its lane")
		check(played_card.position.x + played_card.size.x <= lane.size.x + 0.1, "Played card never invades neighboring lane width")
		check(played_card.position.y >= -9.0, "Played card vertical bleed is tightly controlled")
		check(played_card.position.y + played_card.size.y <= lane.size.y + 9.0, "Played card vertical bleed remains bounded")
	lane.queue_free()

	print("Canonical Forest UI checks: %d failures" % failures)
	quit(1 if failures else 0)
