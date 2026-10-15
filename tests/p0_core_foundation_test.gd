extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Effect = preload("res://scripts/domain/definitions/effect_definition.gd")
const EffectResolver = preload("res://scripts/domain/services/effect_resolver.gd")
const Target = preload("res://scripts/domain/value_objects/target_spec.gd")
const TargetResolver = preload("res://scripts/domain/services/target_resolver.gd")
const Condition = preload("res://scripts/domain/definitions/condition_definition.gd")
const ConditionResolver = preload("res://scripts/domain/services/condition_resolver.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_heal_and_event()
	_test_adjacency()
	_test_sacrifice_reason()
	_test_turn_gates()
	_test_structured_draw_and_summon_events()
	print("P0 core foundation checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle():
	var battle := Battle.new()
	battle.setup_cpu(Catalog.DOMAIN_FOREST, Catalog.starter_deck(Catalog.DOMAIN_FOREST), Catalog.DOMAIN_CRYPT, Catalog.starter_deck(Catalog.DOMAIN_CRYPT))
	battle.event_queue.clear()
	return battle

func _test_heal_and_event() -> void:
	var battle = _battle()
	battle.player_lanes[2] = battle.create_unit("bs_003_lobo_joven", true)
	battle.player_lanes[2]["hp"] = 1
	var target := {"valid":true,"side":"player","lane":2,"unit":battle.player_lanes[2]}
	check(EffectResolver.apply(Effect.heal(2), target, {"source_card_id":"p0_heal","source_side":"player"}, battle), "HEAL resolves")
	check(int(battle.player_lanes[2]["hp"]) == 3, "HEAL restores without exceeding max")
	var events := battle.drain_events()
	check(_has_event(events, "HEAL_APPLIED"), "HEAL emits HEAL_APPLIED")

func _test_adjacency() -> void:
	var battle = _battle()
	battle.player_lanes[2] = battle.create_unit("bs_003_lobo_joven", true)
	battle.player_lanes[1] = battle.create_unit("bs_001_brote_del_claro", true)
	var adjacent := TargetResolver.resolve(Target.adjacent_ally_lane(), {"source_side":"player","source_lane":2,"target_lane":1}, battle)
	check(bool(adjacent.get("valid", false)) and int(adjacent.get("lane", -1)) == 1, "Adjacent ally target resolves")
	var empty_adjacent := TargetResolver.resolve(Target.empty_adjacent_ally_lane(), {"source_side":"player","source_lane":2,"target_lane":3}, battle)
	check(bool(empty_adjacent.get("valid", false)) and int(empty_adjacent.get("lane", -1)) == 3, "Empty adjacent lane resolves")
	check(ConditionResolver.is_met(Condition.adjacent_ally_exists(), {}, {"source_side":"player","source_lane":2}, battle), "Adjacent ally condition resolves")

func _test_sacrifice_reason() -> void:
	var battle = _battle()
	battle.player_domain = Catalog.DOMAIN_CRYPT
	battle.player_lanes[0] = battle.create_unit("ch_001_rata_de_osario", true)
	battle.hand.clear()
	battle.hand.append("ch_016_pacto_de_sangre")
	battle.draw_pile.clear()
	battle.draw_pile.append("ch_003_guardia_esqueletico")
	battle.draw_pile.append("ch_003_guardia_esqueletico")
	battle.energy_current = 12
	check(battle.play_card(0, -1, 0), "Pacto de Sangre resolves")
	var events := battle.drain_events()
	check(_has_event(events, "UNIT_SACRIFICED"), "Sacrifice emits UNIT_SACRIFICED")
	check(_has_death_reason(events, "sacrifice"), "UNIT_DIED carries death_reason=sacrifice")

func _test_turn_gates() -> void:
	var battle = _battle()
	check(battle.consume_first_turn_gate("player", "first_spell"), "First gate consumption succeeds")
	check(not battle.consume_first_turn_gate("player", "first_spell"), "Second gate consumption is blocked")
	battle.reset_turn_gates("player")
	check(battle.consume_first_turn_gate("player", "first_spell"), "Gate resets for new turn")
	check(battle.consume_first_turn_gate("enemy", "first_spell"), "Enemy uses independent gate namespace")

func _test_structured_draw_and_summon_events() -> void:
	var battle = _battle()
	battle.hand.clear()
	battle.draw_pile.clear()
	battle.draw_pile.append("bs_003_lobo_joven")
	check(battle.draw_card(), "Player draws card")
	check(_has_event(battle.drain_events(), "CARD_DRAWN"), "Draw emits CARD_DRAWN")
	battle.hand.clear()
	battle.hand.append("bs_001_brote_del_claro")
	battle.energy_current = 12
	check(battle.play_card(0, 4), "Creature can be summoned")
	check(_has_event(battle.drain_events(), "UNIT_SUMMONED"), "Creature summon emits UNIT_SUMMONED")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if str(Dictionary(event).get("type", "")) == event_type:
			return true
	return false

func _has_death_reason(events: Array, reason: String) -> bool:
	for event in events:
		var data := Dictionary(event)
		if str(data.get("type", "")) != "UNIT_DIED":
			continue
		if str(Dictionary(data.get("payload", {})).get("death_reason", "")) == reason:
			return true
	return false
