extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Effect = preload("res://scripts/domain/definitions/effect_definition.gd")
const EffectResolver = preload("res://scripts/domain/services/effect_resolver.gd")
const Target = preload("res://scripts/domain/value_objects/target_spec.gd")
const TargetResolver = preload("res://scripts/domain/services/target_resolver.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_move_and_forced_move()
	_test_rooted_blocks_and_expires()
	_test_atomic_swap()
	_test_multi_target_damage()
	print("P1 spatial engine checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle():
	var battle := Battle.new()
	battle.setup_cpu(Catalog.DOMAIN_TOWER, Catalog.starter_deck(Catalog.DOMAIN_TOWER), Catalog.DOMAIN_FOREST, Catalog.starter_deck(Catalog.DOMAIN_FOREST))
	battle.event_queue.clear()
	return battle

func _test_move_and_forced_move() -> void:
	var battle = _battle()
	battle.player_lanes[1] = battle.create_unit("aprendiz_runico", true)
	check(battle._move_unit("player", 1, 2, false, "p1_move", "player"), "Normal move succeeds into empty lane")
	check(battle.player_lanes[1] == null and battle.player_lanes[2] != null, "Move mutates exactly source and destination")
	check(_has_event(battle.drain_events(), "UNIT_MOVED"), "Move emits UNIT_MOVED")
	battle.enemy_lanes[3] = battle.create_unit("lobo_joven", true)
	check(battle._move_unit("enemy", 3, 4, true, "p1_push", "player"), "Forced move uses same spatial engine")
	check(battle.enemy_lanes[4] != null and battle.enemy_lanes[3] == null, "Forced move changes enemy lane")

func _test_rooted_blocks_and_expires() -> void:
	var battle = _battle()
	battle.enemy_lanes[2] = battle.create_unit("lobo_joven", true)
	var target := {"valid":true,"side":"enemy","lane":2,"unit":battle.enemy_lanes[2]}
	check(EffectResolver.apply(Effect.rooted(), target, {"source_card_id":"p1_root","source_side":"player"}, battle), "ROOTED applies through EffectResolver")
	check(not battle._move_unit("enemy", 2, 1, true, "p1_push", "player"), "ROOTED blocks forced movement")
	check(battle.enemy_lanes[2] != null and battle.enemy_lanes[1] == null, "Blocked forced movement leaves board untouched")
	battle._expire_statuses_for_turn("enemy")
	check(not battle._move_unit("enemy", 2, 1, true, "p1_push", "player"), "ROOTED persists through the target turn")
	battle._expire_statuses_for_turn("player")
	check(battle._move_unit("enemy", 2, 1, true, "p1_push", "player"), "Movement succeeds when the source player reaches its next turn")

func _test_atomic_swap() -> void:
	var battle = _battle()
	battle.player_lanes[0] = battle.create_unit("aprendiz_runico", true)
	battle.player_lanes[4] = battle.create_unit("adepta_runica", true)
	var a := str(battle.player_lanes[0].get("id", ""))
	var b := str(battle.player_lanes[4].get("id", ""))
	check(battle._swap_units("player", 0, 4, "p1_swap", "player"), "Swap succeeds with two movable units")
	check(str(battle.player_lanes[0].get("id", "")) == b and str(battle.player_lanes[4].get("id", "")) == a, "Swap is atomic and exchanges both units")
	battle._apply_status_to_unit("player", 0, "ROOTED")
	var before0 := str(battle.player_lanes[0].get("id", ""))
	var before4 := str(battle.player_lanes[4].get("id", ""))
	check(not battle._swap_units("player", 0, 4, "p1_swap", "player"), "ROOTED blocks swap")
	check(str(battle.player_lanes[0].get("id", "")) == before0 and str(battle.player_lanes[4].get("id", "")) == before4, "Failed swap changes neither lane")

func _test_multi_target_damage() -> void:
	var battle = _battle()
	battle.enemy_lanes[1] = battle.create_unit("lobo_joven", true)
	battle.enemy_lanes[3] = battle.create_unit("cierva_lunar", true)
	var spec := Target.enemy_lanes(2, 1)
	var target := TargetResolver.resolve(spec, {"source_side":"player","target_lanes":[3,1]}, battle)
	check(bool(target.get("valid", false)), "Multi-target selector accepts two distinct occupied enemy lanes")
	var targets: Array = Array(target.get("targets", []))
	check(targets.size() == 2 and int(Dictionary(targets[0]).get("lane", -1)) == 1 and int(Dictionary(targets[1]).get("lane", -1)) == 3, "Multi-target selector normalizes deterministic lane order")
	check(EffectResolver.apply(Effect.damage(1), target, {"source_card_id":"p1_multi","source_side":"player"}, battle), "Existing damage opcode resolves over target batch")
	check(int(battle.enemy_lanes[1].get("hp", 0)) == 2 and int(battle.enemy_lanes[3].get("hp", 0)) == 3, "Batch damage hits each selected unit exactly once")
	var invalid := TargetResolver.resolve(spec, {"source_side":"player","target_lanes":[1,1]}, battle)
	check(not bool(invalid.get("valid", false)), "Multi-target rejects duplicate lanes")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if str(Dictionary(event).get("type", "")) == event_type:
			return true
	return false
