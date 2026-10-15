extends SceneTree

const Battle = preload("res://scripts/domain/canonical_battle_state.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const AbilityCatalog = preload("res://scripts/domain/definitions/ability_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_catalog_coverage()
	_test_forest_abilities()
	_test_crypt_abilities()
	_test_tower_abilities()
	_test_forge_abilities()
	print("Ability/effect engine checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_catalog_coverage() -> void:
	var effect_ids := [
		"crypt_pit_necromancer",
		"forest_rune_squirrel",
		"tower_sigils_apprentice",
		"tower_spark_theurge",
		"forge_copper_sparker",
		"forest_pack_wolf",
		"forest_sudden_growth",
		"crypt_exhume_foundational",
		"crypt_funeral_touch",
		"tower_five_strokes_master",
		"tower_five_runes_archmage",
		"forge_walking_hammer",
		"forge_hammer_blow",
		"forest_guard_deer",
		"forest_clearing_roar",
		"crypt_bone_collector",
		"crypt_marrow_witch",
		"tower_prismatic_familiar",
		"tower_scroll_keeper",
		"forge_field_mechanic",
		"forge_core_smith",
		"forest_oak_shaman",
		"forest_sap_totem",
		"crypt_remains_devourer",
		"crypt_march",
		"tower_nexus_chronicler",
		"tower_veil_observatory",
		"forge_master_armorer",
		"forge_tool_bench",
		"forest_canopy_stalker",
		"forest_green_moon_alpha",
		"crypt_ossuary_executioner",
		"crypt_vertebrae_throne",
		"tower_vector_impulse",
		"tower_resonance_lectern",
		"forge_slag_rain",
		"forge_first_fire_anvil"
	]
	for effect_id in effect_ids:
		var abilities := AbilityCatalog.abilities_for(effect_id)
		check(not abilities.is_empty(), "%s has a declarative ability" % effect_id)
		if abilities.is_empty():
			continue
		var ability: Dictionary = abilities[0]
		check(not str(ability.get("id", "")).is_empty(), "%s ability has id" % effect_id)
		check(not str(ability.get("trigger", "")).is_empty(), "%s ability has trigger" % effect_id)
		check(ability.get("target", null) is Dictionary, "%s ability has TargetSpec" % effect_id)
		check(not Array(ability.get("effects", [])).is_empty(), "%s ability has atomic effects" % effect_id)

func _test_forest_abilities() -> void:
	var pack := Battle.new()
	pack.setup_starter(Catalog.DOMAIN_FOREST)
	pack.player_lanes[1] = pack.create_unit("bs_003_lobo_joven", true)
	pack.hand = ["bs_006_lobo_de_manada"]
	pack.energy_current = 12
	check(pack.play_card(0, 2), "Lobo de Manada can enter adjacent to an ally")
	check(int(pack.player_lanes[2].get("attack", 0)) == 4 and int(pack.player_lanes[2].get("max_hp", 0)) == 4, "Lobo de Manada gains permanent +1/+1 from adjacency")

	var growth := Battle.new()
	growth.setup_starter(Catalog.DOMAIN_FOREST)
	growth.player_lanes[4] = growth.create_unit("bs_003_lobo_joven", true)
	growth.player_lanes[4]["hp"] = 1
	growth.hand = ["bs_015_crecimiento_repentino"]
	growth.energy_current = 12
	check(growth.play_card(0, -1, 4), "Crecimiento Repentino targets lane five")
	var grown: Dictionary = growth.player_lanes[4]
	check(int(grown.get("attack", 0)) == 3 and int(grown.get("max_hp", 0)) == 4, "Crecimiento Repentino grants permanent +1/+1")
	check(int(grown.get("hp", 0)) == 3, "Crecimiento Repentino also heals one when target was damaged")

func _test_crypt_abilities() -> void:
	var necromancer := Battle.new()
	necromancer.setup_starter(Catalog.DOMAIN_CRYPT)
	necromancer.hand = ["ch_007_nigromante_de_fosa"]
	necromancer.discard_pile.clear()
	necromancer.discard_pile.append("ch_001_rata_de_osario")
	necromancer.energy_current = 12
	check(necromancer.play_card(0, 4), "Pit Necromancer can be summoned on lane five")
	check(necromancer.hand.has("ch_001_rata_de_osario"), "Pit Necromancer returns an eligible cost-one creature")

	var offering := Battle.new()
	offering.setup_starter(Catalog.DOMAIN_CRYPT)
	offering.player_lanes[4] = offering.create_unit("bs_003_lobo_joven", true)
	offering.hand = ["ch_016_pacto_de_sangre"]
	offering.draw_pile = ["ch_001_rata_de_osario", "ch_003_guardia_esqueletico", "ch_003_guardia_esqueletico"]
	offering.energy_current = 12
	check(offering.play_card(0, -1, 4), "Pacto de Sangre sacrifices selected allied unit")
	check(offering.player_lanes[4] == null, "Pacto de Sangre clears sacrificed lane")
	check(offering.hand.size() == 2, "Pacto de Sangre draws two cards")
	check(offering.discard_pile.has("bs_003_lobo_joven") and offering.discard_pile.has("ch_016_pacto_de_sangre"), "Pacto de Sangre sends unit and rite to discard")

	var exhumation := Battle.new()
	exhumation.setup_starter(Catalog.DOMAIN_CRYPT)
	exhumation.hand = ["ch_014_exhumar"]
	exhumation.discard_pile = ["ch_001_rata_de_osario"]
	exhumation.energy_current = 12
	check(exhumation.play_card(0), "Exhumar resolves declaratively")
	check(exhumation.hand.size() == 1 and exhumation.hand[0] == "ch_001_rata_de_osario", "Exhumar returns an eligible cost-one creature")
	check(exhumation.discard_pile.has("ch_014_exhumar") and not exhumation.discard_pile.has("ch_001_rata_de_osario"), "Exhumar moves correct cards between zones")

func _test_tower_abilities() -> void:
	var familiar := Battle.new()
	familiar.setup_starter(Catalog.DOMAIN_TOWER)
	familiar.player_lanes[4] = familiar.create_unit("ta_002_familiar_prismatico", true)
	familiar.hand.clear()
	familiar.draw_pile = ["ta_001_aprendiz_de_sigilos"]
	familiar._deal_damage_to_unit(true, 4, 9)
	check(familiar.hand.size() == 1 and familiar.hand[0] == "ta_001_aprendiz_de_sigilos", "Familiar Prismático draws one on death")
	check(familiar.has_pending_discard("player"), "Familiar Prismático then requests one discard")

	var archmage := Battle.new()
	archmage.setup_starter(Catalog.DOMAIN_TOWER)
	archmage.hand = ["ta_012_archimaga_de_las_cinco_runas"]
	archmage.draw_pile = ["ta_013_chispa_dirigida", "ta_016_descarga_runica"]
	archmage.energy_current = 12
	check(archmage.play_card(0, 4), "Archimaga de las Cinco Runas resolves Invocation")
	check(archmage.hand.size() == 2, "Archimaga draws two before requiring one discard")
	check(archmage.has_pending_discard("player"), "Archimaga opens a discard choice")
	check(archmage.effective_card_cost("ta_016_descarga_runica", "player") == 1, "Archimaga reduces spell costs this turn with floor one")

func _test_forge_abilities() -> void:
	var hammer_blow := Battle.new()
	hammer_blow.setup_starter(Catalog.DOMAIN_FORGE)
	hammer_blow.enemy_lanes[4] = hammer_blow.create_unit("bs_010_oso_musgoso", true)
	hammer_blow.hand = ["fa_015_golpe_de_martillo"]
	hammer_blow.energy_current = 12
	var before_hp := int(hammer_blow.enemy_lanes[4].get("hp", 0))
	check(hammer_blow.play_card(0, -1, 4), "Golpe de Martillo accepts an enemy unit target")
	check(int(hammer_blow.enemy_lanes[4].get("hp", 0)) == before_hp - 2, "Golpe de Martillo deals exactly two damage")

	var invalid := Battle.new()
	invalid.setup_starter(Catalog.DOMAIN_FORGE)
	invalid.hand = ["fa_015_golpe_de_martillo"]
	invalid.energy_current = 12
	check(not invalid.play_card(0, -1, 4), "Golpe de Martillo rejects an empty enemy lane")
	check(invalid.energy_current == 12 and invalid.hand.size() == 1, "Rejected Golpe de Martillo spends nothing and stays in hand")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if event is Dictionary and str(event.get("type", "")) == event_type:
			return true
	return false
