extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_catalog_batch()
	_test_forest_cards()
	_test_crypt_cards()
	_test_tower_cards()
	_test_forge_cards()
	_test_cpu_foundational_parity()
	print("Foundation batch 1 checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle(player_domain: String, enemy_domain: String) -> CanonicalCpuBattle:
	var battle := Battle.new()
	battle.setup_cpu(player_domain, Catalog.starter_deck(player_domain), enemy_domain, Catalog.starter_deck(enemy_domain))
	battle.event_queue.clear()
	battle.hand.clear()
	battle.cpu_hand.clear()
	battle.energy_current = 12
	battle.cpu_energy_current = 12
	return battle

func _test_catalog_batch() -> void:
	check(Catalog.validate_catalog().is_empty(), "Transitional catalog validates")
	check(Catalog.all_card_ids().size() >= 60, "Catalog preserves at least the 60 cards reached in Batch 1")
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		check(Catalog.cards_for_domain(domain).size() >= 15, "%s preserves at least 15 cards from Batch 1" % domain)
	for card_id in [
		"bs_005_enredadera_vigilante","bs_011_anciano_de_raices","bs_014_savia_vital",
		"ch_007_nigromante_de_fosa","ch_012_abominacion_ensamblada","ch_016_pacto_de_sangre",
		"ta_016_descarga_runica","ta_017_geometria_imposible","ta_018_tormenta_de_glifos",
		"fa_005_ariete_de_bronce","fa_009_bastion_rodante","fa_014_reparacion_de_emergencia"
	]:
		check(not Catalog.find_by_id(card_id).is_empty(), "Foundational card exists: %s" % card_id)

func _test_forest_cards() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	var rooted := battle.create_unit("bs_005_enredadera_vigilante", true)
	battle.player_lanes[0] = rooted
	check(not battle._move_unit("player", 0, 1, false, "test", "player"), "Printed Enraizado blocks movement")

	battle.player_lanes = [null, battle.create_unit("lobo_joven", true), null, null, null]
	battle.hand = ["bs_011_anciano_de_raices"]
	check(battle.play_card(0, 2), "Anciano de Raíces can be summoned")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == 4, "Anciano aura grants +0/+1 to adjacent ally")

	battle.hand = ["bs_014_savia_vital"]
	check(battle.play_card(0, -1, 1), "Savia Vital resolves")
	check(int(battle.player_lanes[1].get("max_hp", 0)) == 6, "Savia Vital grants permanent +0/+2")

func _test_crypt_cards() -> void:
	var battle := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	battle.discard_pile = ["esqueleto_roto"]
	battle.hand = ["ch_007_nigromante_de_fosa"]
	check(battle.play_card(0, 2), "Nigromante de Fosa can be summoned")
	check(battle.hand.has("esqueleto_roto"), "Nigromante returns a cost-1 creature from discard")

	battle.player_lanes[0] = battle.create_unit("esqueleto_roto", true)
	battle.player_lanes[1] = battle.create_unit("ch_003_guardia_esqueletico", true)
	battle._kill_unit(true, 0, "damage", "test", "enemy")
	battle._kill_unit(true, 1, "damage", "test", "enemy")
	battle._roll_death_window("player")
	check(battle.effective_card_cost("ch_012_abominacion_ensamblada", "player") == 3, "Abominación reaches floor 3 after two allied deaths")

	battle.player_lanes[4] = battle.create_unit("guardian_oseo", true)
	battle.hand = ["ch_016_pacto_de_sangre"]
	battle.draw_pile = ["ch_003_guardia_esqueletico", "ch_004_recolector_de_huesos"]
	check(battle.play_card(0, -1, 4), "Pacto de Sangre resolves")
	check(battle.player_lanes[4] == null, "Pacto sacrifices allied unit")
	check(battle.hand.size() == 2, "Pacto draws two cards")

func _test_tower_cards() -> void:
	var battle := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	battle.enemy_lanes[0] = battle.create_unit("guardian_oseo", true)
	battle.hand = ["ta_016_descarga_runica"]
	check(battle.play_card(0, -1, 0), "Descarga Rúnica resolves")
	check(int(battle.enemy_lanes[0].get("hp", 0)) == 2, "Descarga Rúnica deals 2 damage")

	battle.player_lanes[0] = battle.create_unit("ta_004_custodio_de_pergaminos", true)
	battle.player_lanes[4] = battle.create_unit("ta_009_cronista_del_nexo", true)
	var left_id := str(battle.player_lanes[0].get("id", ""))
	var right_id := str(battle.player_lanes[4].get("id", ""))
	battle.hand = ["ta_017_geometria_imposible"]
	check(battle.play_card(0, -1, -1, -1, [4, 0]), "Geometría Imposible resolves with two allied targets")
	check(str(battle.player_lanes[0].get("id", "")) == right_id and str(battle.player_lanes[4].get("id", "")) == left_id, "Geometría swaps units atomically")

	battle.enemy_lanes[1] = battle.create_unit("lobo_joven", true)
	battle.enemy_lanes[3] = battle.create_unit("bs_004_cierva_guardabosques", true)
	var hp1 := int(battle.enemy_lanes[1].get("hp", 0))
	var hp3 := int(battle.enemy_lanes[3].get("hp", 0))
	battle.hand = ["ta_018_tormenta_de_glifos"]
	check(battle.play_card(0), "Tormenta de Glifos resolves without manual targets")
	check(int(battle.enemy_lanes[1].get("hp", 0)) == hp1 - 1 and int(battle.enemy_lanes[3].get("hp", 0)) == hp3 - 1, "Tormenta hits every enemy unit exactly once")

func _test_forge_cards() -> void:
	var battle := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	var ram := battle.create_unit("fa_005_ariete_de_bronce", false)
	check(bool(ram.get("ready", false)), "Embestida enters ready")
	battle.player_lanes[0] = battle.create_unit("fa_009_bastion_rodante", true)
	check(not battle._move_unit("player", 0, 1, true, "test", "enemy"), "Bastión Rodante Enraizado blocks forced movement")

	battle.player_lanes[2] = battle.create_unit("fa_010_automata_de_engranajes", true)
	battle._deal_damage_to_unit(true, 2, 2, "test", "enemy")
	var damaged := int(battle.player_lanes[2].get("hp", 0))
	battle.hand = ["fa_014_reparacion_de_emergencia"]
	check(battle.play_card(0, -1, 2), "Reparación de Emergencia resolves")
	check(int(battle.player_lanes[2].get("hp", 0)) > damaged, "Reparación restores unit health")

func _test_cpu_foundational_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.player_lanes[0] = battle.create_unit("lobo_joven", true)
	battle.player_lanes[1] = battle.create_unit("bs_004_cierva_guardabosques", true)
	battle.cpu_hand = ["ta_018_tormenta_de_glifos"]
	var hp0 := int(battle.player_lanes[0].get("hp", 0))
	var hp1 := int(battle.player_lanes[1].get("hp", 0))
	check(battle.cpu_play_card(0), "CPU resolves foundational all-enemy spell through shared engine")
	check(int(battle.player_lanes[0].get("hp", 0)) == hp0 - 1 and int(battle.player_lanes[1].get("hp", 0)) == hp1 - 1, "CPU and player share all-enemy targeting semantics")
