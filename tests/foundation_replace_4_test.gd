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
	_test_cpu_invocation_targeting()
	print("Foundation replace 4 checks: %d failures" % failures)
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
	check(Catalog.validate_catalog().is_empty(), "Replace 4 catalog validates")
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
		check(foundational_domain == 16, "%s reaches exactly 16 foundational cards" % domain)
		check(Catalog.validate_deck(Catalog.starter_deck(domain), domain).is_empty(), "%s starter deck remains legal" % domain)
	check(foundational_total == 64, "Migration reaches exactly 64 foundational + 16 legacy cards")
	for removed_id in ["cierva_lunar","oso_ancestral","lamentadora","ofrenda_de_ceniza","familiar_arcano","aprendiz_runico","reparador_mecanico","coloso_de_bronce"]:
		check(Catalog.find_by_id(removed_id).is_empty(), "Legacy card removed: %s" % removed_id)
	for added_id in [
		"bs_004_cierva_guardabosques","bs_018_rugido_del_claro",
		"ch_004_recolector_de_huesos","ch_011_bruja_de_medula",
		"ta_002_familiar_prismatico","ta_004_custodio_de_pergaminos",
		"fa_004_mecanica_de_campo","fa_007_forjador_de_nucleo"
	]:
		check(not Catalog.find_by_id(added_id).is_empty(), "Foundational replacement exists: %s" % added_id)

func _test_forest_replacements() -> void:
	var deer := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	deer.player_lanes[1] = deer.create_unit("bs_003_lobo_joven", true)
	deer.player_lanes[1]["hp"] = 1
	deer.hand.append("bs_004_cierva_guardabosques")
	check(deer.play_card(0, 2, 1), "BS-004 summons with another ally selected")
	check(int(deer.player_lanes[1].get("hp", 0)) == 2, "BS-004 heals another ally by one")
	check(int(deer.player_lanes[2].get("hp", 0)) == 4, "BS-004 does not heal itself")

	var roar := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	roar.player_lanes[0] = roar.create_unit("bs_003_lobo_joven", true)
	roar.player_lanes[3] = roar.create_unit("bs_010_oso_musgoso", true)
	var a0 := int(roar.player_lanes[0].get("attack", 0))
	var a3 := int(roar.player_lanes[3].get("attack", 0))
	roar.hand.append("bs_018_rugido_del_claro")
	check(roar.play_card(0), "BS-018 resolves without manual targets")
	check(int(roar.player_lanes[0].get("attack", 0)) == a0 + 1, "BS-018 buffs first allied unit")
	check(int(roar.player_lanes[3].get("attack", 0)) == a3 + 1, "BS-018 buffs all allied units")
	check(int(roar.player_lanes[0].get("temp_attack", 0)) == 1 and int(roar.player_lanes[3].get("temp_attack", 0)) == 1, "BS-018 bonus is temporary")

func _test_crypt_replacements() -> void:
	var collector := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	collector.player_lanes[0] = collector.create_unit("ch_004_recolector_de_huesos", true)
	collector.player_lanes[2] = collector.create_unit("ch_003_guardia_esqueletico", true)
	collector.player_lanes[3] = collector.create_unit("ch_003_guardia_esqueletico", true)
	var base_attack := int(collector.player_lanes[0].get("attack", 0))
	collector.cpu_turn_active = true
	collector._kill_unit(true, 2, "damage", "test", "enemy")
	check(int(collector.player_lanes[0].get("attack", 0)) == base_attack + 1, "CH-004 gains +1 Attack from first other ally death between turns")
	collector._kill_unit(true, 3, "damage", "test", "enemy")
	check(int(collector.player_lanes[0].get("attack", 0)) == base_attack + 1, "CH-004 triggers only on first allied death in the window")
	collector.cpu_turn_active = false

	var witch := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	witch.player_integrity = 15
	witch.player_lanes[0] = witch.create_unit("ch_011_bruja_de_medula", true)
	witch.player_lanes[4] = witch.create_unit("ch_003_guardia_esqueletico", true)
	witch.hand.append("ch_016_pacto_de_sangre")
	witch.draw_pile = ["ch_001_rata_de_osario","ch_003_guardia_esqueletico"]
	check(witch.play_card(0, -1, 4), "Pacto de Sangre sacrifices ally with CH-011 in play")
	check(witch.player_integrity == 16, "CH-011 heals Nexus by one whenever another ally is sacrificed")

func _test_tower_replacements() -> void:
	var familiar := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	familiar.player_lanes[2] = familiar.create_unit("ta_002_familiar_prismatico", true)
	familiar.draw_pile.append("ta_013_chispa_dirigida")
	familiar._kill_unit(true, 2, "damage", "test", "enemy")
	check(familiar.hand.has("ta_013_chispa_dirigida"), "TA-002 draws one on death")
	check(familiar.has_pending_discard("player") and familiar.pending_discard_remaining("player") == 1, "TA-002 then requests exactly one discard")

	var keeper := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	keeper.player_lanes[1] = keeper.create_unit("ta_004_custodio_de_pergaminos", true)
	keeper.hand = ["ta_013_chispa_dirigida","ta_016_descarga_runica"]
	var base_hp := int(keeper.player_lanes[1].get("max_hp", 0))
	keeper.queue_pending_discard("player", 2, "test")
	check(keeper.resolve_pending_discard("player", 0), "First discard resolves")
	check(int(keeper.player_lanes[1].get("max_hp", 0)) == base_hp + 1, "TA-004 gains +0/+1 from first discard")
	check(keeper.resolve_pending_discard("player", 0), "Second discard resolves")
	check(int(keeper.player_lanes[1].get("max_hp", 0)) == base_hp + 1, "TA-004 does not trigger twice in same turn")

func _test_forge_replacements() -> void:
	var mechanic := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	mechanic.player_lanes[1] = mechanic.create_unit("fa_010_automata_de_engranajes", true)
	mechanic.player_lanes[1]["hp"] = 1
	mechanic.hand.append("fa_004_mecanica_de_campo")
	check(mechanic.play_card(0, 2, 1), "FA-004 summons with another ally selected")
	check(int(mechanic.player_lanes[1].get("hp", 0)) == 3, "FA-004 heals another ally by two")

	var smith := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	smith.player_lanes[2] = smith.create_unit("fa_007_forjador_de_nucleo", true)
	smith.hand = ["fa_019_horno_runico","fa_019_horno_runico"]
	var base_attack := int(smith.player_lanes[2].get("attack", 0))
	var base_hp := int(smith.player_lanes[2].get("max_hp", 0))
	check(smith.play_card(0), "First Relic can be played with FA-007 in play")
	check(int(smith.player_lanes[2].get("attack", 0)) == base_attack + 1 and int(smith.player_lanes[2].get("max_hp", 0)) == base_hp + 1, "FA-007 gains permanent +1/+1 from first Relic")
	check(smith.play_card(0), "Second Relic can be played")
	check(int(smith.player_lanes[2].get("attack", 0)) == base_attack + 1 and int(smith.player_lanes[2].get("max_hp", 0)) == base_hp + 1, "FA-007 triggers only once per turn")

func _test_cpu_invocation_targeting() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_FORGE)
	battle.enemy_lanes[1] = battle.create_unit("fa_010_automata_de_engranajes", true)
	battle.enemy_lanes[1]["hp"] = 1
	battle.cpu_hand.append("fa_004_mecanica_de_campo")
	var actions := battle.cpu_legal_actions_for_card(0)
	var found_target := false
	for raw in actions:
		var action: Dictionary = Dictionary(raw)
		if int(action.get("target_lane", -1)) == 1:
			found_target = true
			check(battle.cpu_play_card(0, int(action.get("lane", -1)), 1), "CPU can execute allied Invocation target")
			break
	check(found_target, "CPU policy exposes another allied unit as Invocation target")
	check(int(battle.enemy_lanes[1].get("hp", 0)) == 3, "CPU FA-004 heals its own ally through shared resolver")
