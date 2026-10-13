extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Effect = preload("res://scripts/domain/definitions/effect_definition.gd")
const EffectResolver = preload("res://scripts/domain/services/effect_resolver.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_dynamic_cost_floor_and_expiry()
	_test_death_window_rollover()
	_test_deck_bottom_move()
	_test_permanent_stats()
	_test_aura_recalculation_preserves_damage()
	print("P2 advanced state checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle():
	var battle := Battle.new()
	battle.setup_cpu(Catalog.DOMAIN_TOWER, Catalog.starter_deck(Catalog.DOMAIN_TOWER), Catalog.DOMAIN_CRYPT, Catalog.starter_deck(Catalog.DOMAIN_CRYPT))
	battle.event_queue.clear()
	return battle

func _first_card_of_type(domain: String, card_type: String) -> String:
	for card_id in Catalog.starter_deck(domain):
		var card := Catalog.find_by_id(card_id)
		if str(card.get("type", "")) == card_type:
			return str(card_id)
	return ""

func _first_creature(domain: String) -> String:
	return _first_card_of_type(domain, Catalog.TYPE_CREATURE)

func _test_dynamic_cost_floor_and_expiry() -> void:
	var battle = _battle()
	var rite_id := _first_card_of_type(Catalog.DOMAIN_TOWER, Catalog.TYPE_RITE)
	check(not rite_id.is_empty(), "Starter deck exposes a rite for cost test")
	var base_cost := int(Catalog.find_by_id(rite_id).get("cost", 0))
	battle.add_cost_modifier("player", "test_discount", -99, 1, "turn", Catalog.TYPE_RITE)
	var expected_cost: int = base_cost if base_cost < 1 else 1
	check(battle.effective_card_cost(rite_id, "player") == expected_cost, "Dynamic cost respects floor 1")
	battle._expire_cost_modifiers("player", "turn")
	check(battle.effective_card_cost(rite_id, "player") == base_cost, "Turn cost modifier expires cleanly")

func _test_death_window_rollover() -> void:
	var battle = _battle()
	var creature_id := _first_creature(Catalog.DOMAIN_TOWER)
	battle.player_lanes[0] = battle.create_unit(creature_id, true)
	battle._kill_unit(true, 0, "damage", "p2_test", "enemy")
	check(battle.deaths_since_last_turn("player") == 0, "Current deaths are not exposed before window rolls")
	battle._roll_death_window("player")
	check(battle.deaths_since_last_turn("player") == 1, "Death window exposes deaths from previous window")
	battle._roll_death_window("player")
	check(battle.deaths_since_last_turn("player") == 0, "Death window clears on next rollover")

func _test_deck_bottom_move() -> void:
	var battle = _battle()
	var creature_id := _first_creature(Catalog.DOMAIN_TOWER)
	battle.discard_pile.clear()
	battle.discard_pile.append(creature_id)
	battle.draw_pile.clear()
	battle.draw_pile.append("sentinela_runico")
	var before: int = int(battle.draw_pile.size())
	check(battle._move_discard_creature_to_deck_bottom("player", creature_id, 999, "p2_test"), "Creature moves from discard to deck bottom")
	check(battle.discard_pile.is_empty(), "Moved card leaves discard")
	check(battle.draw_pile.size() == before + 1 and str(battle.draw_pile.back()) == creature_id, "Moved card becomes bottom card deterministically")

func _test_permanent_stats() -> void:
	var battle = _battle()
	var creature_id := _first_creature(Catalog.DOMAIN_TOWER)
	battle.player_lanes[2] = battle.create_unit(creature_id, true)
	var before_attack := int(battle.player_lanes[2].get("attack", 0))
	var before_max := int(battle.player_lanes[2].get("max_hp", 0))
	var target := {"valid":true,"side":"player","lane":2,"unit":battle.player_lanes[2]}
	check(EffectResolver.apply(Effect.permanent_stats(1, 2), target, {"source_card_id":"p2_buff","source_side":"player"}, battle), "Permanent stats resolve through EffectResolver")
	check(int(battle.player_lanes[2].get("attack", 0)) == before_attack + 1, "Permanent attack persists")
	check(int(battle.player_lanes[2].get("max_hp", 0)) == before_max + 2, "Permanent max health persists")
	battle._expire_temporary_bonuses()
	check(int(battle.player_lanes[2].get("attack", 0)) == before_attack + 1 and int(battle.player_lanes[2].get("max_hp", 0)) == before_max + 2, "Temporary expiry does not remove permanent stats")

func _test_aura_recalculation_preserves_damage() -> void:
	var battle = _battle()
	var source_id := _first_creature(Catalog.DOMAIN_FOREST)
	var target_id := _first_creature(Catalog.DOMAIN_TOWER)
	battle.player_lanes[2] = battle.create_unit(source_id, true)
	battle.player_lanes[1] = battle.create_unit(target_id, true)
	var base_max := int(battle.player_lanes[1].get("max_hp", 0))
	check(battle._add_aura_to_unit("player", 2, "test_aura", 0, 1, 1), "Aura attaches to source")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == base_max + 1, "Adjacent unit receives aura health")
	battle._deal_damage_to_unit(true, 1, 1, "p2_damage", "enemy")
	var damaged_hp_with_aura := int(battle.player_lanes[1].get("hp", 0))
	check(battle._move_unit("player", 2, 3, false, "p2_move", "player"), "Aura source can move")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == base_max, "Aura is removed when source leaves range")
	check(int(battle.player_lanes[1].get("hp", 0)) == maxi(1, damaged_hp_with_aura - 1), "Aura recalculation preserves existing damage instead of healing")
	check(battle._move_unit("player", 3, 2, false, "p2_move", "player"), "Aura source can return")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == base_max + 1, "Aura reapplies after source returns")
	check(int(battle.player_lanes[1].get("hp", 0)) == damaged_hp_with_aura, "Reapplying aura restores capacity but not lost health beyond preserved damage")
	battle._kill_unit(true, 2, "damage", "p2_remove", "enemy")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == base_max, "Aura disappears when source dies")
