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
			return [Ability.create("ash_offering", Ability.ON_PLAY, Target.player_lane(), [Effect.create(Effect.KILL_UNIT), Effect.draw(2)], [Condition.target_exists()])]
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
	return []

static func target_spec_for(effect_id: String, trigger: String) -> Dictionary:
	for ability in abilities_for(effect_id):
		if str(ability.get("trigger", "")) == trigger:
			return Dictionary(ability.get("target", {})).duplicate(true)
	return Target.none()
