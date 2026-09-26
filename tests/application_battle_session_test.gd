extends SceneTree

const SessionScript = preload("res://scripts/application/battle/canonical_battle_session.gd")

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
	check(Array(state.player_lanes).size() == 4 and Array(state.enemy_lanes).size() == 4, "Session exposes four lanes per side")
	check(Array(state.hand).size() == 4, "Session exposes opening hand")
	check(int(state.energy_capacity) == 1 and int(state.energy_current) == 1, "Session exposes canonical Energy")
	check(str(state.essence_name) == "Instinto", "Session exposes domain Essence")

	var first_card := session.hand_card_definition(0)
	check(not first_card.is_empty(), "Application layer can resolve card definitions")
	check(session.can_target_player_lane(0, 0), "Application layer decides legal target lanes")
	var play_result := session.play_hand_card(0, 0)
	check(bool(play_result.get("ok", false)), "Application layer executes play-card use case")
	state = play_result.get("snapshot", {})
	check(Array(state.player_lanes)[0] != null, "Play-card use case updates board state")
	check(int(state.energy_current) == 0, "Play-card use case spends Energy")

	var inspect := session.inspect_unit("player", 0)
	check(not inspect.is_empty() and not Dictionary(inspect.card).is_empty(), "Application layer exposes inspectable unit DTO")

	var round_result := session.end_round()
	check(bool(round_result.get("ok", false)), "Application layer executes end-round use case")
	state = round_result.get("snapshot", {})
	check(int(state.turn) == 2, "End-round use case advances turn")
	check(int(state.energy_capacity) == 2, "Next turn increases Energy capacity")

	check(session.deck_summary().begins_with("Mazo:"), "Application layer provides deck summary")
	check(not session.discard_summary().is_empty(), "Application layer provides discard summary")

	print("Application battle session checks: %d failures" % failures)
	quit(1 if failures else 0)
