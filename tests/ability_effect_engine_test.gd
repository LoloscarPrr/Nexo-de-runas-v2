extends SceneTree

const Battle = preload("res://scripts/domain/canonical_battle_state.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const AbilityCatalog = preload("res://scripts/domain/canonical_ability_catalog.gd")
const AbilityResolver = preload("res://scripts/domain/services/ability_resolver.gd")
const TargetSpec = preload("res://scripts/domain/value_objects/target_spec.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_ability_catalog()
	_test_enter_play_condition()
	_test_rite_targeting_and_effects()
	_test_last_breath_events()
	_test_exhumation()
	_test_overload_condition()
	print("Ability/effect engine checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_ability_catalog() -> void:
	check(AbilityCatalog.validate_catalog().is_empty(), "Ability catalog validates")
	check(AbilityCatalog.all_ids().size() == 15, "Fifteen canonical abilities are declarative")
	var growth = AbilityCatalog.find_by_id("forest_growth")
	check(growth != null, "Violent Growth ability exists")
	if growth != null:
		check(str(growth.trigger) == "on_play", "Violent Growth uses ON_PLAY")
		check(str(growth.target_spec.kind) == TargetSpec.PLAYER_UNIT, "Violent Growth targets an allied unit")
		check(growth.effects.size() == 1, "Violent Growth is composed from one atomic effect")

func _test_enter_play_condition() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_FOREST)
	battle.player_lanes[0] = battle.create_unit("lobo_joven", true)
	battle.hand = ["ardilla_vigilante"]
	battle.energy_current = 12
	battle.essence_current = 0
	check(battle.play_card(0, 1), "Watchful Squirrel can enter beside another Beast")
	check(battle.essence_current == 1, "Watchful Squirrel condition grants Instinct through AbilityResolver")
	var events := battle.drain_events()
	check(_has_event(events, "ABILITY_TRIGGERED"), "ON_PLAY emits ABILITY_TRIGGERED")
	check(_has_event(events, "EFFECT_RESOLVED"), "ON_PLAY emits EFFECT_RESOLVED")

	var no_pack := Battle.new()
	no_pack.setup_starter(Catalog.DOMAIN_FOREST)
	no_pack.player_lanes = [null, null, null, null, null]
	no_pack.hand = ["ardilla_vigilante"]
	no_pack.energy_current = 12
	no_pack.essence_current = 0
	check(no_pack.play_card(0, 0), "Watchful Squirrel remains playable when its condition is false")
	check(no_pack.essence_current == 0, "False ability condition does not grant Instinct")

func _test_rite_targeting_and_effects() -> void:
	var growth := Battle.new()
	growth.setup_starter(Catalog.DOMAIN_FOREST)
	growth.player_lanes[4] = growth.create_unit("lobo_joven", true)
	growth.hand = ["crecimiento_violento"]
	growth.energy_current = 12
	check(growth.play_card(0, -1, 4), "Violent Growth resolves on lane five")
	var grown: Dictionary = growth.player_lanes[4]
	check(int(grown.get("attack", 0)) == 4, "Violent Growth adds two attack")
	check(int(grown.get("hp", 0)) == 5 and int(grown.get("max_hp", 0)) == 5, "Violent Growth adds two health")
	check(int(grown.get("temp_attack", 0)) == 2 and int(grown.get("temp_health", 0)) == 2, "Violent Growth records temporary modifiers")

	var call_pack := Battle.new()
	call_pack.setup_starter(Catalog.DOMAIN_FOREST)
	call_pack.player_lanes = [null, null, null, null, null]
	call_pack.hand = ["llamado_de_la_manada"]
	call_pack.energy_current = 12
	call_pack.essence_current = 0
	check(call_pack.play_card(0), "Call of the Pack resolves without manual lane selection")
	check(call_pack.player_lanes[0] != null and str(call_pack.player_lanes[0].get("id", "")) == "cria_del_bosque", "Call of the Pack summons into first free lane")
	check(call_pack.essence_current == 1, "Call of the Pack gains Instinct through a second atomic effect")

	var bolt := Battle.new()
	bolt.setup_starter(Catalog.DOMAIN_TOWER)
	bolt.enemy_lanes[4] = bolt.create_unit("esqueleto_roto", true)
	bolt.hand = ["proyectil_runico"]
	bolt.energy_current = 12
	check(AbilityResolver.can_target_card_lane(bolt, Catalog.find_by_id("proyectil_runico"), 4, "enemy"), "Rune Bolt recognizes an occupied enemy lane")
	check(bolt.play_card(0, -1, 4), "Rune Bolt resolves against lane five")
	check(bolt.enemy_lanes[4] == null, "Rune Bolt damage is executed by EffectResolver")

func _test_last_breath_events() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_CRYPT)
	battle.player_lanes[0] = battle.create_unit("esqueleto_roto", true)
	battle.essence_current = 0
	battle.drain_events()
	battle._deal_damage_to_unit(true, 0, 5)
	check(battle.player_lanes[0] == null, "Broken Skeleton dies normally")
	check(battle.essence_current == 2, "Broken Skeleton produces base Remains plus declarative Last Breath")
	var events := battle.drain_events()
	var death_index := _event_index(events, "UNIT_DIED")
	var ability_index := _event_index(events, "ABILITY_TRIGGERED")
	check(death_index >= 0 and ability_index > death_index, "UNIT_DIED precedes Last Breath ability resolution")
	check(_has_event(events, "EFFECT_RESOLVED"), "Last Breath emits EFFECT_RESOLVED")

func _test_exhumation() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_CRYPT)
	battle.hand = ["exhumacion"]
	battle.discard_pile = ["lobo_joven"]
	battle.energy_current = 12
	check(battle.play_card(0), "Exhumation resolves through the generic ability engine")
	check(battle.hand.size() == 1 and battle.hand[0] == "lobo_joven", "Exhumation returns an eligible creature to hand")
	check(battle.discard_pile.has("exhumacion") and not battle.discard_pile.has("lobo_joven"), "Exhumation moves the correct cards between zones")

func _test_overload_condition() -> void:
	var invalid := Battle.new()
	invalid.setup_starter(Catalog.DOMAIN_FORGE)
	invalid.player_lanes[0] = invalid.create_unit("lobo_joven", true)
	invalid.hand = ["sobrecarga"]
	invalid.energy_current = 12
	check(not invalid.play_card(0, -1, 0), "Overload rejects a non-Construct target")
	check(invalid.energy_current == 12 and invalid.hand.size() == 1, "Invalid Overload spends nothing and remains in hand")

	var valid := Battle.new()
	valid.setup_starter(Catalog.DOMAIN_FORGE)
	valid.player_lanes[0] = valid.create_unit("automata_obrero", true)
	valid.hand = ["sobrecarga"]
	valid.energy_current = 12
	valid.essence_current = 0
	check(valid.play_card(0, -1, 0), "Overload accepts a Construct target")
	var worker: Dictionary = valid.player_lanes[0]
	check(int(worker.get("attack", 0)) == 4, "Overload adds three attack through EffectResolver")
	check(valid.essence_current == 2, "Overload gains two Heat through the same ability definition")

func _has_event(events: Array, event_type: String) -> bool:
	return _event_index(events, event_type) >= 0

func _event_index(events: Array, event_type: String) -> int:
	for i in range(events.size()):
		var event = events[i]
		if event is Dictionary and str(event.get("type", "")) == event_type:
			return i
	return -1
