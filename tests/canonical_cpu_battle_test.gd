extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_cpu_round()
	_test_cpu_direct_damage()
	print("Canonical CPU battle checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_cpu_round() -> void:
	var battle := Battle.new()
	battle.setup_cpu_starter(Catalog.DOMAIN_FOREST)
	check(battle.cpu_hand.size() == 4, "CPU opens with four cards")
	check(battle.cpu_energy_capacity == 1, "CPU starts with one Energy capacity")
	battle.advance_round()
	var occupied := 0
	for unit in battle.enemy_lanes:
		if unit != null:
			occupied += 1
	check(occupied >= 1, "CPU plays an affordable creature on its first turn")
	check(battle.turn == 2, "A full round advances to player turn two")
	check(battle.energy_capacity == 2 and battle.energy_current == 2, "Player Energy advances after CPU turn")

func _test_cpu_direct_damage() -> void:
	var battle := Battle.new()
	battle.setup_cpu_starter(Catalog.DOMAIN_FOREST)
	battle.enemy_lanes = [battle.create_unit("zorro_acechante", true), null, null, null]
	battle.player_lanes = [null, null, null, null]
	battle.resolve_cpu_attacks()
	check(battle.player_integrity == 18, "CPU open lane deals direct Nexus damage")
