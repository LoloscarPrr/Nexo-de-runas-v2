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
		"forest_call_pack",
		"forest_growth",
		"crypt_broken_skeleton",
		"crypt_gravedigger",
		"crypt_funeral_hound",
		"crypt_mourner",
		"crypt_ash_offering",
		"crypt_exhumation",
		"tower_familiar",
		"tower_rune_bolt",
		"tower_forbidden_vision",
		"forge_worker",
		"forge_spark",
		"forge_overload"
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

	var call_pack := Battle.new()
	call_pack.setup_starter(Catalog.DOMAIN_FOREST)
	call_pack.player_lanes = [null, null, null, null, null]
	call_pack.hand = ["llamado_de_la_manada"]
	call_pack.energy_current = 12
	call_pack.essence_current = 0
	check(call_pack.play_card(0), "Call of the Pack resolves without manual target")
	check(call_pack.player_lanes[0] != null and str(call_pack.player_lanes[0].get("id", "")) == "cria_del_bosque", "Call of the Pack summons into first free lane")
	check(call_pack.essence_current == 1, "Call of the Pack also grants Instinct")

	var growth := Battle.new()
	growth.setup_starter(Catalog.DOMAIN_FOREST)
	growth.player_lanes[4] = growth.create_unit("lobo_joven", true)
	growth.hand = ["crecimiento_violento"]
	growth.energy_current = 12
	check(growth.play_card(0, -1, 4), "Violent Growth targets lane five")
	var grown: Dictionary = growth.player_lanes[4]
	check(int(grown.get("attack", 0)) == 4, "Violent Growth adds two attack")
	check(int(grown.get("hp", 0)) == 5 and int(grown.get("temp_health", 0)) == 2, "Violent Growth adds temporary health")

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

	var gravedigger := Battle.new()
	gravedigger.setup_starter(Catalog.DOMAIN_CRYPT)
	gravedigger.hand = ["sepulturero"]
	gravedigger.energy_current = 12
	gravedigger.essence_current = 0
	check(gravedigger.play_card(0, 4), "Gravedigger can be summoned on lane five")
	check(gravedigger.essence_current == 1, "Gravedigger gains one Remains on summon")

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
	offering.draw_pile = ["esqueleto_roto", "sepulturero", "guardian_oseo"]
	offering.energy_current = 12
	check(offering.play_card(0, -1, 4), "Ash Offering sacrifices selected allied unit")
	check(offering.player_lanes[4] == null, "Ash Offering clears sacrificed lane")
	check(offering.hand.size() == 2, "Ash Offering draws two cards")
	check(offering.discard_pile.has("lobo_joven") and offering.discard_pile.has("ofrenda_de_ceniza"), "Ash Offering sends unit and rite to discard")

	var exhumation := Battle.new()
	exhumation.setup_starter(Catalog.DOMAIN_CRYPT)
	exhumation.hand = ["exhumacion"]
	exhumation.discard_pile = ["lobo_joven"]
	exhumation.energy_current = 12
	check(exhumation.play_card(0), "Exhumation resolves declaratively")
	check(exhumation.hand.size() == 1 and exhumation.hand[0] == "lobo_joven", "Exhumation returns eligible creature to hand")
	check(exhumation.discard_pile.has("exhumacion") and not exhumation.discard_pile.has("lobo_joven"), "Exhumation moves correct cards between zones")

func _test_tower_abilities() -> void:
	var familiar := Battle.new()
	familiar.setup_starter(Catalog.DOMAIN_TOWER)
	familiar.hand = ["familiar_arcano"]
	familiar.draw_pile = ["buho_oculum", "aprendiz_runico"]
	familiar.energy_current = 12
	check(familiar.play_card(0, 4), "Arcane Familiar summons on lane five")
	check(familiar.last_revealed.size() == 1 and familiar.last_revealed[0] == "buho_oculum", "Arcane Familiar reveals the top card")

	var bolt := Battle.new()
	bolt.setup_starter(Catalog.DOMAIN_TOWER)
	bolt.hand = ["proyectil_runico"]
	bolt.enemy_lanes[4] = bolt.create_unit("esqueleto_roto", true)
	bolt.energy_current = 12
	check(bolt.play_card(0, -1, 4), "Rune Bolt targets enemy lane five")
	check(bolt.enemy_lanes[4] == null, "Rune Bolt deals one damage through EffectResolver")

	var vision := Battle.new()
	vision.setup_starter(Catalog.DOMAIN_TOWER)
	vision.hand = ["vision_prohibida"]
	vision.draw_pile = ["familiar_arcano", "buho_oculum", "aprendiz_runico", "adepta_runica"]
	vision.energy_current = 12
	check(vision.play_card(0), "Forbidden Vision resolves without target")
	check(vision.last_revealed == ["familiar_arcano", "buho_oculum", "aprendiz_runico"], "Forbidden Vision reveals top three in order")
	check(vision.hand.size() == 1 and vision.hand[0] == "familiar_arcano", "Forbidden Vision draws the first revealed card")

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

	var overload := Battle.new()
	overload.setup_starter(Catalog.DOMAIN_FORGE)
	overload.player_lanes[4] = overload.create_unit("automata_obrero", true)
	overload.hand = ["sobrecarga"]
	overload.energy_current = 12
	overload.essence_current = 0
	check(overload.play_card(0, -1, 4), "Overload accepts a Construct target")
	check(int(overload.player_lanes[4].get("attack", 0)) == 4, "Overload adds three temporary attack")
	check(overload.essence_current == 2, "Overload gains two Heat")

	var invalid := Battle.new()
	invalid.setup_starter(Catalog.DOMAIN_FORGE)
	invalid.player_lanes[4] = invalid.create_unit("lobo_joven", true)
	invalid.hand = ["sobrecarga"]
	invalid.energy_current = 12
	check(not invalid.play_card(0, -1, 4), "Overload rejects a non-Construct target")
	check(invalid.energy_current == 12 and invalid.hand.size() == 1, "Rejected Overload spends nothing and stays in hand")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if event is Dictionary and str(event.get("type", "")) == event_type:
			return true
	return false
