extends SceneTree

const SessionScript = preload("res://scripts/application/battle/canonical_battle_session.gd")
const CommandScript = preload("res://scripts/application/battle/battle_command.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	var session := SessionScript.new()
	var state := session.start_vs_cpu(SessionScript.DOMAIN_FOREST)
	check(not state.is_empty(), "Battle session starts")
	check(state.player_integrity == 20 and state.enemy_integrity == 20, "Session exposes 20/20 Nexus Integrity")
	check(int(state.lane_count) == 5, "Session exposes canonical lane count")
	check(Array(state.player_lanes).size() == 5 and Array(state.enemy_lanes).size() == 5, "Session exposes five lanes per side")
	check(Array(state.hand).size() == 4, "Session exposes opening hand")
	check(int(state.energy_capacity) == 1 and int(state.energy_current) == 1, "Session exposes canonical Energy")
	check(str(state.essence_name) == "Instinto", "Session exposes domain Essence")

	var first_card := session.hand_card_definition(0)
	check(not first_card.is_empty(), "Application layer can resolve card definitions")
	check(session.can_target_player_lane(0, 4), "Application layer recognizes fifth lane as legal")
	var play_command := CommandScript.play_card(0, 4)
	check(str(play_command.to_dict().type) == CommandScript.PLAY_CARD, "BattleCommand is serializable")
	var play_result := session.execute(play_command)
	check(bool(play_result.get("ok", false)), "Application layer executes play-card command")
	state = play_result.get("snapshot", {})
	check(Array(state.player_lanes)[4] != null, "Play-card command updates the fifth lane")
	check(int(state.energy_current) == 0, "Play-card command spends Energy")
	var play_events: Array = play_result.get("events", [])
	check(not play_events.is_empty(), "Play-card command exposes domain events")
	var event_types: Array[String] = []
	for event in play_events:
		event_types.append(str(Dictionary(event).get("type", "")))
	check(event_types.has("RESOURCE_SPENT"), "Application exposes resource-spent event")
	check(event_types.has("CARD_PLAYED"), "Application exposes card-played event")

	var inspect := session.inspect_unit("player", 4)
	check(not inspect.is_empty() and not Dictionary(inspect.card).is_empty(), "Application layer exposes fifth-lane unit DTO")

	var round_result := session.execute(CommandScript.end_round())
	check(bool(round_result.get("ok", false)), "Application layer executes end-round command")
	state = round_result.get("snapshot", {})
	check(int(state.turn) == 2, "End-round command advances turn")
	check(int(state.energy_capacity) == 2, "Next turn increases Energy capacity")
	var round_events: Array = round_result.get("events", [])
	var has_turn_started := false
	for event in round_events:
		if str(Dictionary(event).get("type", "")) == "TURN_STARTED":
			has_turn_started = true
	check(has_turn_started, "End-round result exposes turn-started event")

	check(session.deck_summary().begins_with("Mazo:"), "Application layer provides deck summary")
	check(not session.discard_summary().is_empty(), "Application layer provides discard summary")

	print("Application battle session checks: %d failures" % failures)
	quit(1 if failures else 0)
