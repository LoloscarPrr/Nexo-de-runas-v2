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
		"forest_watchful_squirrel",
		"crypt_broken_skeleton",
		"crypt_pit_necromancer",
		"crypt_funeral_hound",
		"crypt_mourner",
		"crypt_ash_offering",
		"tower_familiar",
		"forge_worker",
		"forge_spark",
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
		"forge_hammer_blow"
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
	var squirrel := Battle.new()
	squirrel.setup_starter(Catalog.DOMAIN_FOREST)
	squirrel.player_lanes[0] = squirrel.create_unit("lobo_joven", true)
	squirrel.hand = ["ardilla_vigilante"]
	squirrel.energy_current = 12
	squirrel.essence_current = 0
	check(squirrel.play_card(0, 4), "Watchful Squirrel can enter lane five")
	check(squirrel.essence_current == 1, "Watchful Squirrel grants Instinct when another Beast exists")
	check(_has_event(squirrel.drain_events(), "ABILITY_TRIGGERED"), "Watchful Squirrel emits ability event")

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
	var skeleton := Battle.new()
	skeleton.setup_starter(Catalog.DOMAIN_CRYPT)
	skeleton.player_lanes[0] = skeleton.create_unit("esqueleto_roto", true)
	skeleton.essence_current = 0
	skeleton._deal_damage_to_unit(true, 0, 9)
	check(skeleton.player_lanes[0] == null, "Broken Skeleton dies normally")
	check(skeleton.essence_current == 2, "Broken Skeleton grants base Remains plus Last Breath Remains")
	var skeleton_events := skeleton.drain_events()
	check(_has_event(skeleton_events, "ABILITY_TRIGGERED"), "Broken Skeleton Last Breath emits ability event")
	check(_has_event(skeleton_events, "EFFECT_APPLIED"), "Broken Skeleton Last Breath emits effect event")

	var necromancer := Battle.new()
	necromancer.setup_starter(Catalog.DOMAIN_CRYPT)
	necromancer.hand = ["ch_007_nigromante_de_fosa"]
	necromancer.discard_pile.clear()
	necromancer.discard_pile.append("ch_001_rata_de_osario")
	necromancer.energy_current = 12
	check(necromancer.play_card(0, 4), "Pit Necromancer can be summoned on lane five")
	check(necromancer.hand.has("ch_001_rata_de_osario"), "Pit Necromancer returns an eligible cost-one creature")

	var hound := Battle.new()
	hound.setup_starter(Catalog.DOMAIN_CRYPT)
	hound.player_lanes[4] = hound.create_unit("perro_funebre", true)
	hound.enemy_lanes[4] = hound.create_unit("lobo_joven", true)
	hound.essence_current = 0
	hound._deal_damage_to_unit(true, 4, 9)
	check(hound.enemy_lanes[4] != null and int(hound.enemy_lanes[4].get("hp", 0)) == 2, "Funeral Hound damages opposing enemy on death")
	check(hound.essence_current == 1, "Funeral Hound death grants base Remains")

	var mourner := Battle.new()
	mourner.setup_starter(Catalog.DOMAIN_CRYPT)
	mourner.player_lanes[0] = mourner.create_unit("lamentadora", true)
	mourner.hand.clear()
	mourner.draw_pile = ["esqueleto_roto"]
	mourner._deal_damage_to_unit(true, 0, 9)
	check(mourner.hand.size() == 1 and mourner.hand[0] == "esqueleto_roto", "Mourner draws a card on death")

	var offering := Battle.new()
	offering.setup_starter(Catalog.DOMAIN_CRYPT)
	offering.player_lanes[4] = offering.create_unit("lobo_joven", true)
	offering.hand = ["ofrenda_de_ceniza"]
	offering.draw_pile = ["esqueleto_roto", "ch_003_guardia_esqueletico", "guardian_oseo"]
	offering.energy_current = 12
	check(offering.play_card(0, -1, 4), "Ash Offering sacrifices selected allied unit")
	check(offering.player_lanes[4] == null, "Ash Offering clears sacrificed lane")
	check(offering.hand.size() == 2, "Ash Offering draws two cards")
	check(offering.discard_pile.has("lobo_joven") and offering.discard_pile.has("ofrenda_de_ceniza"), "Ash Offering sends unit and rite to discard")

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
	familiar.hand = ["familiar_arcano"]
	familiar.draw_pile = ["ta_001_aprendiz_de_sigilos", "aprendiz_runico"]
	familiar.energy_current = 12
	check(familiar.play_card(0, 4), "Arcane Familiar summons on lane five")
	check(familiar.last_revealed.size() == 1 and familiar.last_revealed[0] == "ta_001_aprendiz_de_sigilos", "Arcane Familiar reveals the top card")

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
	var worker := Battle.new()
	worker.setup_starter(Catalog.DOMAIN_FORGE)
	worker.hand = ["automata_obrero"]
	worker.energy_current = 12
	worker.essence_current = 0
	check(worker.play_card(0, 4), "Worker Automaton summons on lane five")
	check(worker.essence_current == 1, "Worker Automaton gains one Heat")

	var spark := Battle.new()
	spark.setup_starter(Catalog.DOMAIN_FORGE)
	spark.hand = ["chispa_mecanica"]
	spark.enemy_lanes[4] = spark.create_unit("lobo_joven", true)
	spark.energy_current = 12
	spark.essence_current = 0
	check(spark.play_card(0, -1, 4), "Mechanical Spark targets enemy lane five")
	check(int(spark.enemy_lanes[4].get("hp", 0)) == 2, "Mechanical Spark deals one damage")
	check(spark.essence_current == 1, "Mechanical Spark gains one Heat")

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
