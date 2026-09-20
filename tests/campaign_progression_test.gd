extends SceneTree

const Campaign = preload("res://scripts/domain/campaign_state.gd")
const Battle = preload("res://scripts/domain/battle_state.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_old_save_continues()
	_test_campfire_persists()
	_test_second_route_and_encounter()
	print("Campaign progression checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_old_save_continues() -> void:
	var old_save := {
		"version": 2,
		"run_seed": 123,
		"current_node": "gate_1",
		"resolved_nodes": ["start", "choice_left", "battle_1", "campfire_1", "gate_1"],
		"claimed_rewards": [],
		"deck_ids": ["armino", "lobo", "rana_toro"],
		"victories": 1,
		"defeats": 0,
		"started_at_unix": 1
	}
	var state := Campaign.new()
	check(state.load_from_dict(old_save), "Previous version-2 save still loads")
	check(state.can_enter("choice_2_left"), "Old save at gate can enter second left choice")
	check(state.can_enter("choice_2_right"), "Old save at gate can enter second right choice")

func _test_campfire_persists() -> void:
	var state := Campaign.new()
	check(state.upgrade_card("lobo", "atk"), "Campfire can add attack")
	check(state.upgrade_card("lobo", "hp"), "Campfire can add health")
	var buff := state.get_card_buff("lobo")
	check(int(buff.atk) == 1, "Attack buff stored")
	check(int(buff.hp) == 2, "Health buff stored")

	var reloaded := Campaign.new()
	check(reloaded.load_from_dict(state.to_dict()), "Save with campfire buffs reloads")
	var reloaded_buff := reloaded.get_card_buff("lobo")
	check(int(reloaded_buff.atk) == 1 and int(reloaded_buff.hp) == 2, "Campfire buffs persist through save")

	var battle := Battle.new()
	battle.setup(reloaded.deck_ids, reloaded.card_buffs, "battle_2")
	var player_wolf := battle._new_unit("lobo", true)
	var enemy_wolf := battle._new_unit("lobo", false)
	check(int(player_wolf.hp) == 4, "Campfire +2 health applies to player Wolf")
	check(int(player_wolf.attack_bonus) == 1, "Campfire +1 attack applies to player Wolf")
	check(int(enemy_wolf.hp) == 2 and int(enemy_wolf.attack_bonus) == 0, "Player campfire buffs do not buff enemy copies")

func _test_second_route_and_encounter() -> void:
	var state := Campaign.new()
	check(state.resolve_node("choice_left"), "Enter first choice")
	check(state.resolve_node("battle_1"), "Reach first battle")
	check(state.resolve_node("campfire_1"), "Reach first campfire")
	check(state.resolve_node("gate_1"), "Reach forest gate")
	check(state.resolve_node("choice_2_left"), "Enter second route")
	check(state.resolve_node("battle_2"), "Reach second battle")
	check(state.resolve_node("campfire_2"), "Reach second campfire")
	check(state.resolve_node("boss_1"), "Reach first boss")
	check(state.can_enter("region_complete"), "Boss victory exposes next-sender marker")

	var battle := Battle.new()
	battle.setup(state.deck_ids, state.card_buffs, "battle_2")
	check(battle.enemy_queue.size() >= 6, "Second battle has its own encounter queue")
	check(battle.enemy_queue.has("oso_grizzly"), "Second battle contains stronger enemies")

	var boss := Battle.new()
	boss.setup(state.deck_ids, state.card_buffs, "boss_1")
	check(boss.enemy_queue.has("mula_de_carga"), "Boss encounter includes Pack Mule")
	check(boss.enemy_queue.has("alce_macho"), "Boss encounter escalates to Moose Buck")
