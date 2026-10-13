extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_catalog_migration_state()
	_test_forest_batch3()
	_test_crypt_batch3()
	_test_tower_batch3()
	_test_forge_batch3()
	_test_cpu_batch3_parity()
	print("Foundation batch 3 checks: %d failures" % failures)
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

func _is_foundational(card: Dictionary) -> bool:
	return Array(card.get("tags", [])).has("FUNDACIONAL")

func _test_catalog_migration_state() -> void:
	check(Catalog.validate_catalog().is_empty(), "Batch 3 transitional catalog validates")
	check(Catalog.all_card_ids().size() == 80, "Catalog reaches stable total of 80 cards")
	var foundational_total := 0
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		var domain_cards := Catalog.cards_for_domain(domain)
		check(domain_cards.size() == 20, "%s has 20 total cards" % domain)
		var foundational_domain := 0
		for card in domain_cards:
			if _is_foundational(card):
				foundational_domain += 1
				foundational_total += 1
		check(foundational_domain >= 8, "%s preserves at least 8 migrated foundational cards from Batch 3" % domain)
	check(foundational_total >= 32, "Catalog preserves at least 32 foundational cards reached in Batch 3")
	for card_id in [
		"bs_001_brote_del_claro","bs_017_raices_invasoras",
		"ch_001_rata_de_osario","ch_002_acolito_de_ceniza",
		"ta_007_centinela_runico","ta_013_chispa_dirigida",
		"fa_001_aprendiz_de_remachador","fa_003_guardia_de_placas"
	]:
		check(not Catalog.find_by_id(card_id).is_empty(), "Batch 3 card exists: %s" % card_id)

func _test_forest_batch3() -> void:
	var sprout := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	sprout.player_lanes[1] = sprout.create_unit("lobo_joven", true)
	sprout.hand = ["bs_001_brote_del_claro"]
	check(sprout.play_card(0, 2), "Brote del Claro can be summoned adjacent to ally")
	check(int(sprout.player_lanes[2].get("max_hp", 0)) == 3, "Brote del Claro gains permanent +0/+1 when adjacent")
	var isolated := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	isolated.hand = ["bs_001_brote_del_claro"]
	check(isolated.play_card(0, 4), "Isolated Brote can still be summoned")
	check(int(isolated.player_lanes[4].get("max_hp", 0)) == 2, "Isolated Brote does not gain adjacency bonus")

	var roots := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	roots.enemy_lanes[2] = roots.create_unit("guardian_oseo", true)
	roots.hand = ["bs_017_raices_invasoras"]
	check(roots.play_card(0, -1, 2), "Raíces Invasoras resolves on surviving enemy")
	check(int(roots.enemy_lanes[2].get("hp", 0)) == 2, "Raíces Invasoras deals 2 damage")
	check(not roots._move_unit("enemy", 2, 1, true, "test_push", "player"), "Survivor is Enraizado")
	roots._expire_statuses_for_turn("enemy")
	check(not roots._move_unit("enemy", 2, 1, true, "test_push", "player"), "Root persists through enemy turn start")
	roots._expire_statuses_for_turn("player")
	check(roots._move_unit("enemy", 2, 1, true, "test_push", "player"), "Root expires on source player's next turn")

	var lethal := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	lethal.enemy_lanes[2] = lethal.create_unit("esqueleto_roto", true)
	lethal.hand = ["bs_017_raices_invasoras"]
	check(lethal.play_card(0, -1, 2), "Raíces Invasoras resolves lethally")
	check(lethal.enemy_lanes[2] == null, "Destroyed target is not left with a ghost Root status")

func _test_crypt_batch3() -> void:
	var rat := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	rat.player_lanes[0] = rat.create_unit("ch_001_rata_de_osario", true)
	var enemy_before := rat.enemy_integrity
	rat._kill_unit(true, 0, "damage", "test", "enemy")
	check(rat.enemy_integrity == enemy_before - 1, "Rata de Osario damages enemy Nexus on death")

	var acolyte := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	acolyte.player_integrity = 15
	acolyte.player_lanes[0] = acolyte.create_unit("ch_002_acolito_de_ceniza", true)
	acolyte._kill_unit(true, 0, "damage", "test", "enemy")
	check(acolyte.player_integrity == 16, "Acólito de Ceniza heals own Nexus on death")

func _test_tower_batch3() -> void:
	var sentinel := Catalog.find_by_id("ta_007_centinela_runico")
	check(int(sentinel.get("cost", 0)) == 3 and int(sentinel.get("attack", 0)) == 3 and int(sentinel.get("health", 0)) == 4, "Centinela Rúnico is canonical vanilla 3/3/4")

	var spark := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	spark.enemy_lanes[4] = spark.create_unit("guardian_oseo", true)
	var hp_before := int(spark.enemy_lanes[4].get("hp", 0))
	spark.hand = ["ta_013_chispa_dirigida"]
	check(spark.play_card(0, -1, 4), "Chispa Dirigida resolves")
	check(int(spark.enemy_lanes[4].get("hp", 0)) == hp_before - 1, "Chispa Dirigida deals exactly 1 damage")

func _test_forge_batch3() -> void:
	var apprentice := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	apprentice.hand = ["fa_001_aprendiz_de_remachador"]
	check(apprentice.play_card(0, 2), "Aprendiz can be summoned without Relic")
	check(int(apprentice.player_lanes[2].get("max_hp", 0)) == 2, "Aprendiz stays 1/2 without Relic")

	var with_relic := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	with_relic.hand = ["fa_019_horno_runico"]
	check(with_relic.play_card(0), "A Relic can be established before Aprendiz")
	with_relic.hand = ["fa_001_aprendiz_de_remachador"]
	check(with_relic.play_card(0, 2), "Aprendiz can be summoned while controlling Relic")
	check(int(with_relic.player_lanes[2].get("max_hp", 0)) == 3, "Aprendiz gains permanent +0/+1 while controlling Relic")

	var guard := Catalog.find_by_id("fa_003_guardia_de_placas")
	check(int(guard.get("cost", 0)) == 2 and int(guard.get("attack", 0)) == 2 and int(guard.get("health", 0)) == 4, "Guardia de Placas is canonical vanilla 2/2/4")

func _test_cpu_batch3_parity() -> void:
	var rat := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	rat.enemy_lanes[0] = rat.create_unit("ch_001_rata_de_osario", true)
	var player_before := rat.player_integrity
	rat._kill_unit(false, 0, "damage", "test", "player")
	check(rat.player_integrity == player_before - 1, "Enemy Rata death uses same Nexus-damage semantics")

	var spark := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	spark.player_lanes[2] = spark.create_unit("lobo_joven", true)
	spark.cpu_hand = ["ta_013_chispa_dirigida"]
	var actions := spark.cpu_legal_actions_for_card(0)
	var can_target_lane_two := false
	for action in actions:
		if int(Dictionary(action).get("target_lane", -1)) == 2:
			can_target_lane_two = true
			break
	check(can_target_lane_two, "CPU generates legal target for Chispa Dirigida")
	var hp_before := int(spark.player_lanes[2].get("hp", 0))
	check(spark.cpu_play_card(0, -1, 2), "CPU can play Chispa Dirigida through shared resolver")
	check(int(spark.player_lanes[2].get("hp", 0)) == hp_before - 1, "CPU Chispa deals exactly 1 damage")
