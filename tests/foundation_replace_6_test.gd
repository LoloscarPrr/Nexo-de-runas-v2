extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_final_catalog()
	_test_forest_final_pair()
	_test_crypt_final_pair()
	_test_tower_final_pair()
	_test_forge_final_pair()
	_test_cpu_vector_impulse_parity()
	print("Foundation replace 6 checks: %d failures" % failures)
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

func _test_final_catalog() -> void:
	check(Catalog.validate_catalog().is_empty(), "Final foundational catalog validates")
	check(Catalog.all_card_ids().size() == 80, "Final catalog has exactly 80 cards")
	var foundational_total := 0
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		var cards := Catalog.cards_for_domain(domain)
		check(cards.size() == 20, "%s has exactly 20 cards" % domain)
		var foundational_domain := 0
		for card in cards:
			if _is_foundational(card):
				foundational_domain += 1
				foundational_total += 1
		check(foundational_domain == 20, "%s is 20/20 foundational" % domain)
		var starter := Catalog.starter_deck(domain)
		check(starter.size() == 20, "%s starter has 20 cards" % domain)
		check(Catalog.validate_deck(starter, domain).is_empty(), "%s starter deck is legal" % domain)
		for card_id in starter:
			check(_is_foundational(Catalog.find_by_id(card_id)), "%s starter contains only foundational cards" % domain)
	check(foundational_total == 80, "Catalog is exactly 80/80 foundational")
	for legacy_id in ["lobo_joven","zorro_acechante","esqueleto_roto","guardian_oseo","golem_sigilado","sello_del_circulo","centinela_de_cobre","golem_de_hierro"]:
		check(Catalog.find_by_id(legacy_id).is_empty(), "Final legacy id removed: %s" % legacy_id)

func _test_forest_final_pair() -> void:
	var stalker := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	stalker.player_lanes[1] = stalker.create_unit("bs_003_lobo_joven", true)
	stalker.hand = ["bs_009_acechador_del_dosel"]
	check(stalker.play_card(0, 2, 1, -1, [], 0), "BS-009 can move an adjacent ally on Invocation")
	check(stalker.player_lanes[0] != null and str(stalker.player_lanes[0].get("id", "")) == "bs_003_lobo_joven", "BS-009 moves chosen ally one lane")
	check(stalker.player_lanes[1] == null, "BS-009 vacates original allied lane")

	var alpha := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	alpha.player_lanes[2] = alpha.create_unit("bs_012_alfa_de_la_luna_verde", true)
	alpha.player_lanes[1] = alpha.create_unit("bs_003_lobo_joven", false)
	alpha.player_lanes[3] = alpha.create_unit("bs_004_cierva_guardabosques", false)
	var left_before := int(alpha.player_lanes[1].get("attack", 0))
	var right_before := int(alpha.player_lanes[3].get("attack", 0))
	alpha.resolve_player_attacks()
	check(int(alpha.player_lanes[1].get("attack", 0)) == left_before + 1, "BS-012 buffs left adjacent ally during combat")
	check(int(alpha.player_lanes[3].get("attack", 0)) == right_before + 1, "BS-012 buffs right adjacent ally during combat")

func _test_crypt_final_pair() -> void:
	var executioner := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	executioner.player_lanes[1] = executioner.create_unit("ch_003_guardia_esqueletico", true)
	executioner.hand = ["ch_006_verdugo_del_osario"]
	check(executioner.play_card(0, 2, 1), "CH-006 can sacrifice another ally on Invocation")
	check(executioner.player_lanes[1] == null, "CH-006 sacrifices selected ally")
	check(int(executioner.player_lanes[2].get("attack", 0)) == 5, "CH-006 gains permanent +2 Attack")
	check(int(executioner.player_lanes[2].get("max_hp", 0)) == 5, "CH-006 gains permanent +2 Health")

	var throne := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	throne.hand = ["ch_020_trono_de_vertebras"]
	check(throne.play_card(0), "CH-020 enters play")
	throne.player_lanes[0] = throne.create_unit("ch_003_guardia_esqueletico", true)
	throne.cpu_turn_active = true
	throne._kill_unit(true, 0, "damage", "test", "enemy")
	throne.cpu_turn_active = false
	check(bool(throne.profanation_ready.get("player", false)), "First allied death between turns grants Profanation")
	check(throne.effective_card_cost("ch_003_guardia_esqueletico", "player") == 1, "Profanation discounts next Unit by one")
	throne.hand = ["ch_003_guardia_esqueletico"]
	var energy_before := throne.energy_current
	check(throne.play_card(0, 2), "Discounted Unit can be played")
	check(throne.energy_current == energy_before - 1, "Profanation discount is actually paid at reduced cost")
	check(not bool(throne.profanation_ready.get("player", false)), "Profanation is consumed by next Unit")
	check(int(throne.player_lanes[2].get("attack", 0)) == 3 and int(throne.player_lanes[2].get("max_hp", 0)) == 4, "CH-020 gives Unit played after Profanation +1/+1")

func _test_tower_final_pair() -> void:
	var impulse := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	impulse.enemy_lanes[2] = impulse.create_unit("ch_003_guardia_esqueletico", true)
	impulse.hand = ["ta_015_impulso_vectorial"]
	check(impulse.play_card(0, -1, 2, -1, [], 3, "enemy"), "TA-015 can target enemy Unit")
	check(impulse.enemy_lanes[2] == null and impulse.enemy_lanes[3] != null, "TA-015 pushes target exactly one lane")

	var lectern := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	lectern.active_relics = ["ta_019_atril_de_resonancia"]
	lectern.player_lanes[1] = lectern.create_unit("ta_007_centinela_runico", true)
	lectern.enemy_lanes[4] = lectern.create_unit("ch_003_guardia_esqueletico", true)
	lectern.hand = ["ta_013_chispa_dirigida"]
	lectern.draw_pile = ["ta_001_aprendiz_de_sigilos"]
	lectern._record_card_played("player", Catalog.TYPE_CREATURE)
	check(lectern.play_card(0, -1, 4), "Sequenced spell resolves with TA-019 active")
	check(lectern.hand.has("ta_001_aprendiz_de_sigilos"), "TA-019 draws one after sequenced spell")
	check(lectern.has_pending_discard("player"), "TA-019 then requests one discard")

func _test_forge_final_pair() -> void:
	var slag := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	slag.enemy_lanes[0] = slag.create_unit("bs_010_oso_musgoso", true)
	slag.enemy_lanes[4] = slag.create_unit("bs_010_oso_musgoso", true)
	slag.hand = ["fa_017_lluvia_de_escoria"]
	var hp0 := int(slag.enemy_lanes[0].get("hp", 0))
	var hp4 := int(slag.enemy_lanes[4].get("hp", 0))
	check(slag.play_card(0), "FA-017 resolves without Relic")
	check(int(slag.enemy_lanes[0].get("hp", 0)) == hp0 - 1 and int(slag.enemy_lanes[4].get("hp", 0)) == hp4 - 1, "FA-017 deals one to all enemies without infrastructure")

	var invested := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	invested.active_relics = ["fa_018_banco_de_herramientas"]
	invested.enemy_lanes[0] = invested.create_unit("bs_010_oso_musgoso", true)
	invested.enemy_lanes[4] = invested.create_unit("bs_010_oso_musgoso", true)
	invested.hand = ["fa_017_lluvia_de_escoria"]
	var invested_hp := int(invested.enemy_lanes[0].get("hp", 0))
	check(invested.play_card(0), "FA-017 resolves with Relic")
	check(int(invested.enemy_lanes[0].get("hp", 0)) == invested_hp - 2 and int(invested.enemy_lanes[4].get("hp", 0)) == invested_hp - 2, "FA-017 deals two to all enemies when invested")

	var anvil := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	anvil.active_relics = ["fa_020_yunque_del_primer_fuego"]
	anvil.player_lanes[1] = anvil.create_unit("fa_010_automata_de_engranajes", false)
	anvil.player_lanes[3] = anvil.create_unit("fa_010_automata_de_engranajes", false)
	anvil.player_lanes[1]["hp"] = 2
	anvil.player_lanes[3]["hp"] = 2
	anvil.end_player_turn(3)
	check(int(anvil.player_lanes[1].get("hp", 0)) == 2, "FA-020 leaves unselected damaged ally unchanged")
	check(int(anvil.player_lanes[3].get("hp", 0)) == 3, "FA-020 heals selected damaged ally by one at end of action phase")

func _test_cpu_vector_impulse_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.player_lanes[2] = battle.create_unit("bs_003_lobo_joven", true)
	battle.cpu_hand = ["ta_015_impulso_vectorial"]
	var actions := battle.cpu_legal_actions_for_card(0)
	var chosen := {}
	for raw in actions:
		var action: Dictionary = Dictionary(raw)
		if int(action.get("target_lane", -1)) == 2 and int(action.get("destination_lane", -1)) in [1, 3]:
			chosen = action
			break
	check(not chosen.is_empty(), "CPU generates legal TA-015 push action")
	if not chosen.is_empty():
		var destination := int(chosen.get("destination_lane", -1))
		check(battle.cpu_play_card(0, -1, 2, -1, [], destination, "player"), "CPU executes TA-015 through shared engine")
		check(battle.player_lanes[2] == null and battle.player_lanes[destination] != null, "CPU TA-015 moves player Unit exactly one lane")
