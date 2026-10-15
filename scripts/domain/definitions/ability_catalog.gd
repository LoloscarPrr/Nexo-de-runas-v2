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
			return [Ability.create("crypt_unburied_king_adjacent_skeletons", Ability.ON_SUMMON, Target.empty_adjacent_ally_lanes(), [Effect.create(Effect.SUMMON_TOKEN, {"id":"esqueleto_token","name":"ESQUELETO","attack":1,"health":1,"tags":["TOKEN","NO_MUERTO","ESQUELETO"]})])]
		"crypt_call_fallen":
			return [Ability.create("crypt_call_fallen", Ability.ON_PLAY, Target.selected_empty_ally_lanes(2, 1), [Effect.create(Effect.SUMMON_TOKEN, {"id":"esqueleto_token","name":"ESQUELETO","attack":1,"health":1,"tags":["TOKEN","NO_MUERTO","ESQUELETO"]})])]
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
		"forest_clearing_sprout":
			return [Ability.create("forest_clearing_sprout_adjacent", Ability.ON_SUMMON, Target.source_unit(), [Effect.permanent_stats(0, 1)], [Condition.adjacent_ally_exists()])]
		"forest_invasive_roots":
			return [Ability.create("forest_invasive_roots_damage_root", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(2), Effect.rooted("until_next_turn", true)], [Condition.target_exists()])]
		"crypt_ossuary_rat":
			return [Ability.create("crypt_ossuary_rat_death", Ability.ON_DEATH, Target.none(), [Effect.damage_nexus(1)])]
		"crypt_ash_acolyte":
			return [Ability.create("crypt_ash_acolyte_death", Ability.ON_DEATH, Target.none(), [Effect.heal_nexus(1)])]
		"tower_directed_spark":
			return [Ability.create("tower_directed_spark", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"forge_riveter_apprentice":
			return [Ability.create("forge_riveter_apprentice_relic", Ability.ON_SUMMON, Target.source_unit(), [Effect.permanent_stats(0, 1)], [Condition.controls_relic()])]
		"forest_rune_squirrel":
			return [Ability.create("forest_rune_squirrel_death", Ability.ON_DEATH, Target.none(), [Effect.heal_nexus(1)])]
		"tower_sigils_apprentice":
			return [Ability.create("tower_sigils_apprentice_first_spell", Ability.FIRST_SPELL_PER_TURN, Target.source_unit(), [Effect.temp_stats(1, 0)])]
		"tower_spark_theurge":
			return [Ability.create("tower_spark_theurge_first_spell", Ability.FIRST_SPELL_PER_TURN, Target.opposing_enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"forge_copper_sparker":
			return [Ability.create("forge_copper_sparker_death", Ability.ON_DEATH, Target.opposing_enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"forest_young_wolf_foundational":
			return [Ability.create("forest_young_wolf_attack", Ability.ON_ATTACK, Target.source_unit(), [Effect.temp_stats(1, 0)])]
		"crypt_coffin_bearer":
			return [Ability.create("crypt_coffin_bearer_death", Ability.ON_DEATH, Target.empty_ally_lane(), [Effect.create(Effect.SUMMON_TOKEN, {"id":"esqueleto_token","name":"ESQUELETO","attack":1,"health":1,"tags":["TOKEN","NO_MUERTO","ESQUELETO"]})])]
		"tower_refraction_mage":
			return [Ability.create("tower_refraction_mage_sift", Ability.ON_SUMMON, Target.none(), [Effect.draw_then_discard(1, 1)])]
		"tower_reorder_foundational":
			return [Ability.create("tower_reorder_sift", Ability.ON_PLAY, Target.none(), [Effect.draw_then_discard(1, 1)])]
		"forge_workshop_flamethrower":
			return [Ability.create("forge_workshop_flamethrower_attack", Ability.ON_ATTACK, Target.opposing_enemy_lane(), [Effect.damage(1)], [Condition.target_exists()])]
		"forest_pack_wolf":
			return [Ability.create("forest_pack_wolf_adjacent", Ability.ON_SUMMON, Target.source_unit(), [Effect.permanent_stats(1, 1)], [Condition.adjacent_ally_exists()])]
		"forest_sudden_growth":
			return [
				Ability.create("forest_sudden_growth_base", Ability.ON_PLAY, Target.player_lane(), [Effect.permanent_stats(1, 1)], [Condition.target_exists()]),
				Ability.create("forest_sudden_growth_heal", Ability.ON_PLAY, Target.player_lane(), [Effect.heal(1)], [Condition.target_exists(), Condition.target_damaged()])
			]
		"crypt_exhume_foundational":
			return [Ability.create("crypt_exhume_cost_one", Ability.ON_PLAY, Target.none(), [Effect.create(Effect.RETURN_CREATURE_FROM_DISCARD, {"max_cost":1})])]
		"crypt_funeral_touch":
			return [Ability.create("crypt_funeral_touch_damage", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(2), Effect.heal_nexus_if_target_gone(1)], [Condition.target_exists()])]
		"tower_five_strokes_master":
			return [Ability.create("tower_five_strokes_first_spell", Ability.FIRST_SPELL_PER_TURN, Target.source_unit(), [Effect.heal(1), Effect.temp_stats(1, 0)])]
		"tower_five_runes_archmage":
			return [Ability.create("tower_five_runes_archmage_invocation", Ability.ON_SUMMON, Target.none(), [Effect.draw_then_discard(2, 1), Effect.cost_modifier("ta012_spell_discount", -1, 1, "turn", "rite")])]
		"forge_walking_hammer":
			return [Ability.create("forge_walking_hammer_attack", Ability.ON_ATTACK, Target.source_unit(), [Effect.temp_stats(1, 0)], [Condition.opposing_enemy_attack_lower_than_source()])]
		"forge_hammer_blow":
			return [Ability.create("forge_hammer_blow", Ability.ON_PLAY, Target.enemy_lane(), [Effect.damage(2)], [Condition.target_exists()])]
		"forest_guard_deer":
			return [Ability.create("forest_guard_deer_heal", Ability.ON_SUMMON, Target.player_lane(false), [Effect.heal(1)], [Condition.target_exists(), Condition.target_is_other_ally()])]
		"forest_clearing_roar":
			return [Ability.create("forest_clearing_roar_allies", Ability.ON_PLAY, Target.all_ally_units(), [Effect.temp_stats(1, 0)])]
		"crypt_bone_collector":
			return [Ability.create("crypt_bone_collector_first_death", Ability.FIRST_ALLY_DEATH_BETWEEN_TURNS, Target.source_unit(), [Effect.permanent_stats(1, 0)])]
		"crypt_marrow_witch":
			return [Ability.create("crypt_marrow_witch_sacrifice", Ability.ON_ALLY_SACRIFICED, Target.none(), [Effect.heal_nexus(1)])]
		"tower_prismatic_familiar":
			return [Ability.create("tower_prismatic_familiar_death", Ability.ON_DEATH, Target.none(), [Effect.draw_then_discard(1, 1)])]
		"tower_scroll_keeper":
			return [Ability.create("tower_scroll_keeper_first_discard", Ability.FIRST_DISCARD_PER_TURN, Target.source_unit(), [Effect.permanent_stats(0, 1)])]
		"forge_field_mechanic":
			return [Ability.create("forge_field_mechanic_heal", Ability.ON_SUMMON, Target.player_lane(false), [Effect.heal(2)], [Condition.target_exists(), Condition.target_is_other_ally()])]
		"forge_core_smith":
			return [Ability.create("forge_core_smith_first_relic", Ability.FIRST_RELIC_PER_TURN, Target.source_unit(), [Effect.permanent_stats(1, 1)])]
		"forest_oak_shaman":
			return [Ability.create("forest_oak_shaman_turn_start", Ability.TURN_START, Target.first_damaged_ally_unit(), [Effect.heal(1)])]
		"forest_sap_totem":
			return [Ability.create("forest_sap_totem_first_heal", Ability.FIRST_UNIT_HEAL_PER_TURN, Target.none(), [Effect.heal_nexus(1)])]
		"crypt_remains_devourer":
			return [Ability.create("crypt_remains_devourer_invocation", Ability.ON_SUMMON, Target.source_unit(), [Effect.move_discard_to_deck_bottom(), Effect.permanent_stats(2, 1)], [Condition.has_creature_in_discard()])]
		"crypt_march":
			return [
				Ability.create("crypt_march_all", Ability.ON_PLAY, Target.all_ally_units(), [Effect.temp_stats(1, 0)]),
				Ability.create("crypt_march_skeletons", Ability.ON_PLAY, Target.all_ally_units(), [Effect.temp_stats_for_tag("ESQUELETO", 1, 0)])
			]
		"tower_nexus_chronicler":
			return [Ability.create("tower_nexus_chronicler_turn_start", Ability.TURN_START, Target.none(), [Effect.draw_then_discard(1, 1)], [Condition.previous_turn_played_card_type("rite")])]
		"tower_veil_observatory":
			return [Ability.create("tower_veil_observatory_outside_draw", Ability.FIRST_DRAW_OUTSIDE_DRAW_PHASE_PER_TURN, Target.first_ally_unit(), [Effect.temp_stats(1, 0)])]
		"forge_master_armorer":
			return [Ability.create("forge_master_armorer_invocation", Ability.ON_SUMMON, Target.player_lane(false), [Effect.permanent_stats(1, 1)], [Condition.target_exists()])]
		"forge_tool_bench":
			return [Ability.create("forge_tool_bench_first_heal", Ability.FIRST_UNIT_HEAL_PER_TURN, Target.player_lane(false), [Effect.temp_stats(1, 0)], [Condition.target_exists()])]
	return []

static func target_spec_for(effect_id: String, trigger: String) -> Dictionary:
	for ability in abilities_for(effect_id):
		if str(ability.get("trigger", "")) == trigger:
			return Dictionary(ability.get("target", {})).duplicate(true)
	return Target.none()
