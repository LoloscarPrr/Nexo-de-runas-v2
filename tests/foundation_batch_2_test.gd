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
	_test_forest_batch()
	_test_crypt_batch()
	_test_tower_batch()
	_test_forge_batch()
	_test_cpu_batch2_actions()
	print("Foundation batch 2 checks: %d failures" % failures)
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
	check(Catalog.validate_catalog().is_empty(), "Batch 2 catalog validates")
	check(Catalog.all_card_ids().size() >= 72, "Catalog preserves at least the 72 cards reached in Batch 2")
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		check(Catalog.cards_for_domain(domain).size() >= 18, "%s preserves at least 18 cards from Batch 2" % domain)
	for card_id in [
		"bs_013_avatar_del_bosque","bs_016_llamado_de_la_manada","bs_020_santuario_de_la_manada",
		"ch_013_rey_sin_sepulcro","ch_017_llamado_de_los_caidos","ch_019_osario_ritual",
		"ta_003_adepta_del_vector","ta_008_manipulador_cinetico","ta_010_golem_de_eter",
		"fa_013_coloso_de_bronce","fa_016_sobrecarga","fa_019_horno_runico"
	]:
		check(not Catalog.find_by_id(card_id).is_empty(), "Batch 2 card exists: %s" % card_id)

func _test_forest_batch() -> void:
	var avatar := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	avatar.player_integrity = 15
	avatar.player_lanes[0] = avatar.create_unit("bs_003_lobo_joven", true)
	avatar.player_lanes[0]["hp"] = 1
	avatar.hand = ["bs_013_avatar_del_bosque"]
	check(avatar.play_card(0, 2), "Avatar del Bosque can be summoned")
	check(int(avatar.player_lanes[0].get("hp", 0)) == 3, "Avatar heals allied units by 2")
	check(avatar.player_integrity == 17, "Avatar heals own Nexus by 2")

	var call := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	call.player_lanes[1] = call.create_unit("bs_003_lobo_joven", true)
	call.hand = ["bs_016_llamado_de_la_manada"]
	check(call.play_card(0, -1, 2), "Llamado de la Manada chooses an empty allied lane")
	check(call.player_lanes[2] != null and str(call.player_lanes[2].get("id", "")) == "brote", "Llamado summons Brote")
	check(int(call.player_lanes[2].get("attack", 0)) == 2, "Brote gets +1 Attack this turn when summoned adjacent to ally")

	var sanctuary := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	sanctuary.hand = ["bs_020_santuario_de_la_manada"]
	check(sanctuary.play_card(0), "Santuario de la Manada enters play")
	sanctuary.player_lanes[1] = sanctuary.create_unit("bs_003_lobo_joven", true)
	sanctuary.hand = ["bs_005_enredadera_vigilante"]
	check(sanctuary.play_card(0, 2), "First summon after Santuario succeeds")
	check(int(sanctuary.player_lanes[2].get("attack", 0)) == 2 and int(sanctuary.player_lanes[2].get("max_hp", 0)) == 6, "Santuario permanently grants +1/+1 to first adjacent summon")
	sanctuary.hand = ["bs_005_enredadera_vigilante"]
	check(sanctuary.play_card(0, 3), "Second summon succeeds")
	check(int(sanctuary.player_lanes[3].get("attack", 0)) == 1, "Santuario triggers only once per turn")

func _test_crypt_batch() -> void:
	var king := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	king.hand = ["ch_013_rey_sin_sepulcro"]
	check(king.play_card(0, 2), "Rey Sin Sepulcro can be summoned")
	check(king.player_lanes[1] != null and str(king.player_lanes[1].get("id", "")) == "esqueleto_token", "King summons left adjacent Skeleton")
	check(king.player_lanes[3] != null and str(king.player_lanes[3].get("id", "")) == "esqueleto_token", "King summons right adjacent Skeleton")

	var fallen := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	fallen.hand = ["ch_017_llamado_de_los_caidos"]
	check(fallen.play_card(0, -1, -1, -1, [0, 4]), "Llamado de los Caídos accepts two chosen empty lanes")
	check(str(fallen.player_lanes[0].get("id", "")) == "esqueleto_token" and str(fallen.player_lanes[4].get("id", "")) == "esqueleto_token", "Llamado summons two Skeletons in selected lanes")

	var ossuary := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	ossuary.player_integrity = 15
	ossuary.hand = ["ch_019_osario_ritual"]
	check(ossuary.play_card(0), "Osario Ritual enters play")
	ossuary.player_lanes[0] = ossuary.create_unit("ch_003_guardia_esqueletico", true)
	ossuary.player_lanes[1] = ossuary.create_unit("ch_003_guardia_esqueletico", true)
	ossuary.cpu_turn_active = true
	ossuary._kill_unit(true, 0, "damage", "test", "enemy")
	check(ossuary.player_integrity == 16, "Osario heals Nexus on first allied death between turns")
	ossuary._kill_unit(true, 1, "damage", "test", "enemy")
	check(ossuary.player_integrity == 16, "Osario triggers only once between turns")
	ossuary.cpu_turn_active = false

func _test_tower_batch() -> void:
	var adept := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	adept.player_lanes[1] = adept.create_unit("ta_004_custodio_de_pergaminos", true)
	adept.hand = ["ta_003_adepta_del_vector"]
	check(adept.play_card(0, 2, 1, -1, [], 0), "Adepta del Vector can move adjacent ally by one lane")
	check(adept.player_lanes[0] != null and str(adept.player_lanes[0].get("id", "")) == "ta_004_custodio_de_pergaminos" and adept.player_lanes[1] == null, "Adepta moves the selected adjacent ally")

	var kinetic := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	kinetic.enemy_lanes[2] = kinetic.create_unit("ch_003_guardia_esqueletico", true)
	kinetic.hand = ["ta_008_manipulador_cinetico"]
	check(kinetic.play_card(0, 2, -1, -1, [], 3), "Manipulador Cinético can push opposing enemy one lane")
	check(kinetic.enemy_lanes[3] != null and kinetic.enemy_lanes[2] == null, "Manipulador performs bounded forced movement")
	check(not kinetic._move_unit("enemy", 3, 0, true, "test", "player", 1), "Bounded Push cannot move more than one lane")

	var golem := Catalog.find_by_id("ta_010_golem_de_eter")
	check(int(golem.get("cost", 0)) == 4 and int(golem.get("attack", 0)) == 4 and int(golem.get("health", 0)) == 5, "Gólem de Éter keeps canonical 4/4/5 body")

func _test_forge_batch() -> void:
	var colossus := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	colossus.player_lanes[2] = colossus.create_unit("fa_013_coloso_de_bronce", true)
	colossus.enemy_lanes[2] = colossus.create_unit("bs_010_oso_musgoso", true)
	colossus.resolve_player_attacks()
	check(colossus.enemy_integrity == 19, "Blocked Coloso deals 1 additional Nexus damage")

	var overload := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	overload.player_lanes[2] = overload.create_unit("fa_010_automata_de_engranajes", true)
	var base_attack := int(overload.player_lanes[2].get("attack", 0))
	overload.hand = ["fa_016_sobrecarga"]
	check(overload.play_card(0, -1, 2), "Sobrecarga resolves without Relic")
	check(int(overload.player_lanes[2].get("attack", 0)) == base_attack + 2, "Sobrecarga gives +2 Attack without Relic")

	var overload_relic := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	overload_relic.hand = ["fa_019_horno_runico"]
	check(overload_relic.play_card(0), "Horno Rúnico enters play")
	overload_relic.player_lanes[2] = overload_relic.create_unit("fa_010_automata_de_engranajes", true)
	var relic_base := int(overload_relic.player_lanes[2].get("attack", 0))
	overload_relic.hand = ["fa_016_sobrecarga"]
	check(overload_relic.play_card(0, -1, 2), "Sobrecarga resolves with Relic")
	check(int(overload_relic.player_lanes[2].get("attack", 0)) == relic_base + 3, "Sobrecarga gives +3 Attack while controlling Relic")

	var furnace := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	furnace.hand = ["fa_019_horno_runico"]
	check(furnace.play_card(0), "Horno Rúnico can be played for trigger test")
	furnace.hand = ["fa_010_automata_de_engranajes"]
	check(furnace.play_card(0, 1), "First cost-4 unit can be summoned")
	check(int(furnace.player_lanes[1].get("max_hp", 0)) == 6, "Horno gives first cost-4+ unit +0/+1 permanently")
	furnace.hand = ["fa_010_automata_de_engranajes"]
	check(furnace.play_card(0, 3), "Second cost-4 unit can be summoned")
	check(int(furnace.player_lanes[3].get("max_hp", 0)) == 5, "Horno triggers only once per turn")

func _test_cpu_batch2_actions() -> void:
	var call := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	call.cpu_hand = ["ch_017_llamado_de_los_caidos"]
	var call_actions := call.cpu_legal_actions_for_card(0)
	var found_two_lane := false
	for action in call_actions:
		if Array(Dictionary(action).get("target_lanes", [])).size() == 2:
			found_two_lane = true
			break
	check(found_two_lane, "CPU generates two-lane choices for Llamado de los Caídos")

	var push := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	push.cpu_hand = ["ta_008_manipulador_cinetico"]
	push.player_lanes[2] = push.create_unit("bs_003_lobo_joven", true)
	var push_actions := push.cpu_legal_actions_for_card(0)
	var found_push := false
	for action in push_actions:
		var data := Dictionary(action)
		if int(data.get("lane", -1)) == 2 and int(data.get("destination_lane", -1)) in [1, 3]:
			found_push = true
			break
	check(found_push, "CPU generates a legal one-lane Push when summoning Manipulador Cinético")
