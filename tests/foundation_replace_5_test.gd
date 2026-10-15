extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_migration_count()
	_test_forest_replacements()
	_test_crypt_replacements()
	_test_tower_replacements()
	_test_forge_replacements()
	_test_cpu_parity()
	print("Foundation replace 5 checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle(player_domain: String, enemy_domain: String) -> CanonicalCpuBattle:
	var battle := Battle.new()
	battle.setup_cpu(player_domain, Catalog.starter_deck(player_domain), enemy_domain, Catalog.starter_deck(enemy_domain))
	battle.event_queue.clear()
	battle.hand.clear()
	battle.cpu_hand.clear()
	battle.draw_pile.clear()
	battle.cpu_draw_pile.clear()
	battle.energy_current = 12
	battle.cpu_energy_current = 12
	return battle

func _is_foundational(card: Dictionary) -> bool:
	return Array(card.get("tags", [])).has("FUNDACIONAL")

func _test_migration_count() -> void:
	check(Catalog.validate_catalog().is_empty(), "Replace 5 catalog validates")
	check(Catalog.all_card_ids().size() == 80, "Catalog remains fixed at 80 cards")
	var foundational_total := 0
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		var cards := Catalog.cards_for_domain(domain)
		check(cards.size() == 20, "%s remains at 20 cards" % domain)
		var foundational_domain := 0
		for card in cards:
			if _is_foundational(card):
				foundational_domain += 1
				foundational_total += 1
		check(foundational_domain >= 18, "%s preserves at least 18 foundational cards from Replace 5" % domain)
		check(Catalog.validate_deck(Catalog.starter_deck(domain), domain).is_empty(), "%s starter deck remains legal" % domain)
	check(foundational_total >= 72, "Migration preserves at least 72 foundational cards reached in Replace 5")
	for removed_id in ["ardilla_vigilante","sello_del_rastro","perro_funebre","sello_del_funeral","adepta_runica","astrolabio","automata_obrero","chispa_mecanica"]:
		check(Catalog.find_by_id(removed_id).is_empty(), "Legacy card removed: %s" % removed_id)
	for added_id in [
		"bs_007_chaman_del_roble","bs_019_totem_de_savia",
		"ch_010_devorador_de_restos","ch_018_marcha_de_la_cripta",
		"ta_009_cronista_del_nexo","ta_020_observatorio_del_velo",
		"fa_011_maestra_armera","fa_018_banco_de_herramientas"
	]:
		check(not Catalog.find_by_id(added_id).is_empty(), "Foundational replacement exists: %s" % added_id)

func _test_forest_replacements() -> void:
	var shaman := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	shaman.player_lanes[2] = shaman.create_unit("bs_007_chaman_del_roble", true)
	shaman.player_lanes[0] = shaman.create_unit("bs_010_oso_musgoso", true)
	shaman.player_lanes[0]["hp"] = 2
	shaman.draw_pile = ["bs_001_brote_del_claro"]
	shaman.begin_new_turn()
	check(int(shaman.player_lanes[0].get("hp", 0)) == 3, "BS-007 heals one damaged ally at turn start")

	var totem := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	totem.player_integrity = 15
	totem.hand = ["bs_019_totem_de_savia"]
	check(totem.play_card(0), "BS-019 enters play")
	totem.player_lanes[0] = totem.create_unit("bs_010_oso_musgoso", true)
	totem.player_lanes[1] = totem.create_unit("bs_004_cierva_guardabosques", true)
	totem.player_lanes[0]["hp"] = 2
	totem.player_lanes[1]["hp"] = 2
	totem._heal_unit(true, 0, 1, "test", "player")
	check(totem.player_integrity == 16, "BS-019 heals Nexus on first unit heal of turn")
	totem._heal_unit(true, 1, 1, "test", "player")
	check(totem.player_integrity == 16, "BS-019 triggers only once per turn")

func _test_crypt_replacements() -> void:
	var devourer := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	devourer.discard_pile = ["ch_003_guardia_esqueletico"]
	devourer.hand = ["ch_010_devorador_de_restos"]
	check(devourer.play_card(0, 2), "CH-010 can be summoned with a creature in discard")
	check(devourer.discard_pile.is_empty(), "CH-010 moves a discarded unit out of graveyard")
	check(devourer.draw_pile.size() == 1 and devourer.draw_pile.back() == "ch_003_guardia_esqueletico", "CH-010 sends that unit to deck bottom")
	check(int(devourer.player_lanes[2].get("attack", 0)) == 6 and int(devourer.player_lanes[2].get("max_hp", 0)) == 6, "CH-010 gains permanent +2/+1")

	var march := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	march.hand = ["ch_017_llamado_de_los_caidos"]
	check(march.play_card(0, -1, -1, -1, [0]), "Skeleton token can be created for CH-018 test")
	march.player_lanes[2] = march.create_unit("ch_003_guardia_esqueletico", true)
	march.hand = ["ch_018_marcha_de_la_cripta"]
	check(march.play_card(0), "CH-018 resolves over allied board")
	check(int(march.player_lanes[0].get("attack", 0)) == 3, "CH-018 gives Skeleton token +2 Attack this combat")
	check(int(march.player_lanes[2].get("attack", 0)) == 3, "CH-018 gives other allied units +1 Attack this combat")

func _test_tower_replacements() -> void:
	var chronicler := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	chronicler.player_lanes[2] = chronicler.create_unit("ta_009_cronista_del_nexo", true)
	chronicler.enemy_lanes[4] = chronicler.create_unit("ch_003_guardia_esqueletico", true)
	chronicler.hand = ["ta_013_chispa_dirigida"]
	check(chronicler.play_card(0, -1, 4), "Spell records into current turn history")
	chronicler.draw_pile = ["ta_001_aprendiz_de_sigilos","ta_004_custodio_de_pergaminos"]
	chronicler.begin_new_turn()
	check(chronicler.hand.size() == 2, "TA-009 draws one after normal Draw Phase when a spell was played previous turn")
	check(chronicler.has_pending_discard("player"), "TA-009 then requests one discard")

	var observatory := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	observatory.player_lanes[1] = observatory.create_unit("ta_007_centinela_runico", true)
	observatory.hand = ["ta_020_observatorio_del_velo"]
	check(observatory.play_card(0), "TA-020 enters play")
	var base_attack := int(observatory.player_lanes[1].get("attack", 0))
	observatory.draw_pile = ["ta_001_aprendiz_de_sigilos","ta_004_custodio_de_pergaminos","ta_013_chispa_dirigida"]
	check(observatory.draw_card(true), "Normal Draw Phase draw succeeds")
	check(int(observatory.player_lanes[1].get("attack", 0)) == base_attack, "TA-020 ignores normal Draw Phase")
	check(observatory.draw_card(), "First outside-phase draw succeeds")
	check(int(observatory.player_lanes[1].get("attack", 0)) == base_attack + 1, "TA-020 buffs an allied unit on first outside-phase draw")
	check(observatory.draw_card(), "Second outside-phase draw succeeds")
	check(int(observatory.player_lanes[1].get("attack", 0)) == base_attack + 1, "TA-020 triggers only once per turn")

func _test_forge_replacements() -> void:
	var armorer := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	armorer.player_lanes[1] = armorer.create_unit("fa_010_automata_de_engranajes", true)
	var base_attack := int(armorer.player_lanes[1].get("attack", 0))
	var base_hp := int(armorer.player_lanes[1].get("max_hp", 0))
	armorer.hand = ["fa_011_maestra_armera"]
	check(armorer.play_card(0, 2, 1), "FA-011 summons with allied target")
	check(int(armorer.player_lanes[1].get("attack", 0)) == base_attack + 1 and int(armorer.player_lanes[1].get("max_hp", 0)) == base_hp + 1, "FA-011 grants permanent +1/+1")

	var bench := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	bench.player_lanes[3] = bench.create_unit("fa_010_automata_de_engranajes", true)
	bench.hand = ["fa_018_banco_de_herramientas"]
	check(bench.play_card(0), "FA-018 enters play")
	bench.player_lanes[3]["hp"] = 2
	var bench_attack := int(bench.player_lanes[3].get("attack", 0))
	bench._heal_unit(true, 3, 1, "test", "player")
	check(int(bench.player_lanes[3].get("attack", 0)) == bench_attack + 1, "FA-018 gives healed unit +1 Attack on first heal")
	bench._heal_unit(true, 3, 1, "test", "player")
	check(int(bench.player_lanes[3].get("attack", 0)) == bench_attack + 1, "FA-018 triggers only once per turn")

func _test_cpu_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_FORGE)
	battle.enemy_lanes[1] = battle.create_unit("fa_010_automata_de_engranajes", true)
	battle.cpu_hand = ["fa_011_maestra_armera"]
	var actions := battle.cpu_legal_actions_for_card(0)
	var chosen := {}
	for raw in actions:
		var action: Dictionary = Dictionary(raw)
		if int(action.get("target_lane", -1)) == 1:
			chosen = action
			break
	check(not chosen.is_empty(), "CPU exposes allied target for FA-011 Invocation")
	if not chosen.is_empty():
		var before := int(battle.enemy_lanes[1].get("attack", 0))
		check(battle.cpu_play_card(0, int(chosen.get("lane", -1)), 1), "CPU executes FA-011 through shared engine")
		check(int(battle.enemy_lanes[1].get("attack", 0)) == before + 1, "CPU receives same permanent +1/+1 semantics")
