class_name AbilityCatalog
extends RefCounted

const Ability = preload("res://scripts/domain/definitions/ability_definition.gd")
const Effect = preload("res://scripts/domain/definitions/effect_definition.gd")
const Condition = preload("res://scripts/domain/definitions/condition_definition.gd")
const Target = preload("res://scripts/domain/value_objects/target_spec.gd")

static func abilities_for(effect_id: String) -> Array:
	match effect_id:
		"forest_watchful_squirrel":
			return [Ability.create("watchful_instinct", Ability.ON_SUMMON, Target.none(), [Effect.gain_resource("essence", 1)], [Condition.other_ally_has_tag("BESTIA")])]
		"crypt_gravedigger":
			return [Ability.create("gravedigger_remains", Ability.ON_SUMMON, Target.none(), [Effect.gain_resource("essence", 1)])]
		"tower_familiar":
			return [Ability.create("familiar_reveal", Ability.ON_SUMMON, Target.none(), [Effect.create(Effect.REVEAL_TOP, {"amount": 1, "draw_first": false})])]
		"forge_worker":
			return [Ability.create("worker_heat", Ability.ON_SUMMON, Target.none(), [Effect.gain_resource("essence", 1)])]
		"crypt_broken_skeleton":
			return [Ability.create("broken_skeleton_last_breath", Ability.ON_DEATH, Target.none(), [Effect.gain_resource("essence", 1)])]
		"crypt_funeral_hound":
			return [Ability.create("funeral_hound_last_breath", Ability.ON_DEATH, Target.opposing_enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"crypt_mourner":
			return [Ability.create("mourner_last_breath", Ability.ON_DEATH, Target.none(), [Effect.draw(1)])]
		"forest_call_pack":
			return [Ability.create("call_pack", Ability.ON_PLAY, Target.first_free_player_lane(), [Effect.create(Effect.SUMMON_TOKEN, {"id":"cria_del_bosque","name":"CRÍA DEL BOSQUE","attack":1,"health":1,"tags":["BESTIA"]}), Effect.gain_resource("essence", 1)])]
		"forest_growth":
			return [Ability.create("violent_growth", Ability.ON_PLAY, Target.player_lane(), [Effect.temp_stats(2, 2)], [Condition.target_exists()])]
		"crypt_ash_offering":
			return [Ability.create("ash_offering", Ability.ON_PLAY, Target.player_lane(), [Effect.create(Effect.KILL_UNIT, {"reason":"sacrifice"}), Effect.draw(2)], [Condition.target_exists()])]
		"crypt_exhumation":
			return [Ability.create("exhumation", Ability.ON_PLAY, Target.none(), [Effect.create(Effect.RETURN_CREATURE_FROM_DISCARD, {"max_cost": 3})])]
		"tower_rune_bolt":
			return [Ability.create("rune_bolt", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"tower_forbidden_vision":
			return [Ability.create("forbidden_vision", Ability.ON_PLAY, Target.none(), [Effect.create(Effect.REVEAL_TOP, {"amount": 3, "draw_first": true})])]
		"forge_spark":
			return [Ability.create("mechanical_spark", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(1), Effect.gain_resource("essence", 1)], [Condition.target_exists()])]
		"forge_overload":
			return [Ability.create("overload_construct", Ability.ON_PLAY, Target.player_lane(), [Effect.temp_stats(3, 0), Effect.gain_resource("essence", 2)], [Condition.target_exists(), Condition.target_has_tag("CONSTRUCTO")])]
		"forest_ancient_roots":
			return [Ability.create("ancient_roots_aura", Ability.ON_SUMMON, Target.source_unit(), [Effect.aura("bs011_adjacent_health", 0, 1, 1)])]
		"forest_vital_sap":
			return [Ability.create("vital_sap", Ability.ON_PLAY, Target.player_lane(), [Effect.permanent_stats(0, 2)], [Condition.target_exists()])]
		"crypt_pit_necromancer":
			return [Ability.create("pit_necromancer_return", Ability.ON_SUMMON, Target.none(), [Effect.create(Effect.RETURN_CREATURE_FROM_DISCARD, {"max_cost": 1})])]
		"crypt_blood_pact":
			return [Ability.create("blood_pact", Ability.ON_PLAY, Target.player_lane(), [Effect.create(Effect.KILL_UNIT, {"reason":"sacrifice"}), Effect.draw(2)], [Condition.target_exists()])]
		"tower_rune_discharge":
			return [Ability.create("rune_discharge", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(2)], [Condition.target_exists()])]
		"tower_impossible_geometry":
			return [Ability.create("impossible_geometry", Ability.ON_PLAY, Target.two_ally_lanes(), [Effect.swap_units()])]
		"tower_glyph_storm":
			return [Ability.create("glyph_storm", Ability.ON_PLAY, Target.all_enemy_units(), [Effect.damage(1)])]
		"forge_emergency_repair":
			return [Ability.create("emergency_repair", Ability.ON_PLAY, Target.player_lane(), [Effect.heal(3)], [Condition.target_exists()])]
		"forest_avatar":
			return [Ability.create("forest_avatar_restore", Ability.ON_SUMMON, Target.all_ally_units(), [Effect.heal(2), Effect.heal_nexus(2)])]
		"forest_call_foundational":
			return [Ability.create("forest_call_foundational", Ability.ON_PLAY, Target.empty_ally_lane(), [Effect.create(Effect.SUMMON_TOKEN, {"id":"brote","name":"BROTE","attack":1,"health":1,"tags":["TOKEN","BROTE"],"attack_if_adjacent":1})])]
		"forest_pack_sanctuary":
			return [Ability.create("forest_pack_sanctuary_first_summon", Ability.FIRST_SUMMON_PER_TURN, Target.player_lane(), [Effect.permanent_stats(1, 1)], [Condition.adjacent_ally_exists()])]
		"crypt_unburied_king":
			return [Ability.create("crypt_unburied_king_adjacent_skeletons", Ability.ON_SUMMON, Target.empty_adjacent_ally_lanes(), [Effect.create(Effect.SUMMON_TOKEN, {"id":"esqueleto_token","name":"ESQUELETO","attack":1,"health":1,"tags":["TOKEN","NO_MUERTO"]})])]
		"crypt_call_fallen":
			return [Ability.create("crypt_call_fallen", Ability.ON_PLAY, Target.selected_empty_ally_lanes(2, 1), [Effect.create(Effect.SUMMON_TOKEN, {"id":"esqueleto_token","name":"ESQUELETO","attack":1,"health":1,"tags":["TOKEN","NO_MUERTO"]})])]
		"crypt_ritual_ossuary":
			return [Ability.create("crypt_ritual_ossuary_death", Ability.FIRST_ALLY_DEATH_BETWEEN_TURNS, Target.none(), [Effect.heal_nexus(1)])]
		"tower_vector_adept":
			return [Ability.create("tower_vector_adept_move", Ability.ON_SUMMON, Target.adjacent_ally_lane(), [Effect.move(false, 1)])]
		"tower_kinetic_manipulator":
			return [Ability.create("tower_kinetic_manipulator_push", Ability.ON_SUMMON, Target.opposing_enemy_lane(), [Effect.move(true, 1)], [Condition.target_exists()])]
		"forge_bronze_colossus_foundational":
			return [Ability.create("forge_bronze_colossus_blocked", Ability.ON_ATTACK, Target.none(), [Effect.damage_nexus(1)], [Condition.attack_blocked()])]
		"forge_overload_foundational":
			return [
				Ability.create("forge_overload_base", Ability.ON_PLAY, Target.player_lane(), [Effect.temp_stats(2, 0)], [Condition.target_exists()]),
				Ability.create("forge_overload_relic_bonus", Ability.ON_PLAY, Target.player_lane(), [Effect.temp_stats(1, 0)], [Condition.target_exists(), Condition.controls_relic()])
			]
		"forge_rune_furnace_foundational":
			return [Ability.create("forge_rune_furnace_first_large_unit", Ability.FIRST_HIGH_COST_UNIT_PER_TURN, Target.player_lane(), [Effect.permanent_stats(0, 1)], [Condition.target_exists()])]
	return []

static func target_spec_for(effect_id: String, trigger: String) -> Dictionary:
	for ability in abilities_for(effect_id):
		if str(ability.get("trigger", "")) == trigger:
			return Dictionary(ability.get("target", {})).duplicate(true)
	return Target.none()
