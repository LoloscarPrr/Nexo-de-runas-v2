extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Session = preload("res://scripts/application/battle/canonical_battle_session.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_migration_count()
	_test_forest_replacements()
	_test_crypt_replacements()
	_test_tower_pending_discard()
	_test_forge_replacements()
	_test_cpu_discard_parity()
	print("Foundation replace 2 checks: %d failures" % failures)
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
	check(Catalog.validate_catalog().is_empty(), "Replace 2 catalog validates")
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
		check(foundational_domain >= 12, "%s preserves at least 12 foundational cards from Replace 2" % domain)
		check(Catalog.validate_deck(Catalog.starter_deck(domain), domain).is_empty(), "%s starter deck remains legal" % domain)
	check(foundational_total >= 48, "Migration preserves at least 48 foundational cards reached in Replace 2")
	for removed_id in ["lobo_alfa","totem_de_manada","caballero_vacio","revenante","espectro_del_tomo","cartografo_astral","caldera_andante","sello_de_presion"]:
		check(Catalog.find_by_id(removed_id).is_empty(), "Legacy card removed: %s" % removed_id)
	for added_id in [
		"bs_003_lobo_joven","bs_010_oso_musgoso",
		"ch_008_caballero_desollado","ch_009_portador_del_ataud",
		"ta_006_maga_de_refraccion","ta_014_reordenar",
		"fa_008_lanzallamas_de_taller","fa_010_automata_de_engranajes"
	]:
		check(not Catalog.find_by_id(added_id).is_empty(), "Foundational replacement exists: %s" % added_id)

func _test_forest_replacements() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	battle.player_lanes[2] = battle.create_unit("bs_003_lobo_joven", true)
	var enemy_before := battle.enemy_integrity
	battle.resolve_player_attacks()
	check(battle.enemy_integrity == enemy_before - 3, "BS-003 gets +1 Attack for its combat")
	var bear := Catalog.find_by_id("bs_010_oso_musgoso")
	check(int(bear.get("cost",0)) == 4 and int(bear.get("attack",0)) == 4 and int(bear.get("health",0)) == 6, "BS-010 keeps canonical 4/4/6 body")

func _test_crypt_replacements() -> void:
	var knight := Catalog.find_by_id("ch_008_caballero_desollado")
	check(int(knight.get("cost",0)) == 3 and int(knight.get("attack",0)) == 4 and int(knight.get("health",0)) == 3, "CH-008 keeps canonical 3/4/3 body")
	var bearer := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	bearer.player_lanes[3] = bearer.create_unit("ch_009_portador_del_ataud", true)
	bearer._kill_unit(true, 3, "damage", "test", "enemy")
	check(bearer.player_lanes[3] != null and str(bearer.player_lanes[3].get("id","")) == "esqueleto_token", "CH-009 summons Skeleton into its vacated lane")

func _test_tower_pending_discard() -> void:
	var battle := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	battle.hand.append("ta_014_reordenar")
	battle.hand.append("ta_007_centinela_runico")
	battle.draw_pile.append("ta_013_chispa_dirigida")
	check(battle.play_card(0), "TA-014 resolves draw-then-discard")
	check(battle.has_pending_discard("player"), "TA-014 opens a pending discard choice")
	check(battle.pending_discard_remaining("player") == 1, "Exactly one discard is pending")
	check(battle.hand.has("ta_013_chispa_dirigida"), "Draw happens before discard choice")
	check(not battle.play_card(0), "Player cannot play another card while discard is pending")
	var discard_index := battle.hand.find("ta_007_centinela_runico")
	check(battle.resolve_pending_discard("player", discard_index), "Player can choose which hand card to discard")
	check(not battle.has_pending_discard("player"), "Pending discard clears after chosen discard")
	check(battle.discard_pile.has("ta_007_centinela_runico"), "Chosen card moves to discard")

	var mage := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	mage.hand.append("ta_006_maga_de_refraccion")
	mage.draw_pile.append("ta_013_chispa_dirigida")
	check(mage.play_card(0, 2), "TA-006 summons")
	check(mage.has_pending_discard("player"), "TA-006 also opens draw-discard choice after Invocation")
	check(mage.hand.has("ta_013_chispa_dirigida"), "TA-006 drew before asking for discard")

	var session := Session.new()
	var deck: Array[String] = ["ta_014_reordenar","ta_007_centinela_runico","ta_013_chispa_dirigida","ta_016_descarga_runica"]
	session.start_vs_cpu(Session.DOMAIN_TOWER, deck)
	session._engine.energy_current = 12
	session._engine.hand.clear()
	session._engine.hand.append("ta_014_reordenar")
	session._engine.hand.append("ta_007_centinela_runico")
	session._engine.draw_pile.clear()
	session._engine.draw_pile.append("ta_013_chispa_dirigida")
	var play_result := session.play_hand_card(0)
	check(bool(play_result.get("ok", false)), "Application can play TA-014")
	var snap: Dictionary = play_result.get("snapshot", {})
	check(int(snap.get("pending_discard_count", 0)) == 1, "Application snapshot exposes pending discard")
	var discard_result := session.discard_hand_card(0)
	check(bool(discard_result.get("ok", false)), "Application resolves selected discard")
	check(int(Dictionary(discard_result.get("snapshot", {})).get("pending_discard_count", 0)) == 0, "Application clears pending choice")

func _test_forge_replacements() -> void:
	var flame := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	flame.player_lanes[2] = flame.create_unit("fa_008_lanzallamas_de_taller", true)
	flame.enemy_lanes[2] = flame.create_unit("bs_010_oso_musgoso", true)
	var hp_before := int(flame.enemy_lanes[2].get("hp",0))
	flame.resolve_player_attacks()
	check(flame.enemy_lanes[2] != null and int(flame.enemy_lanes[2].get("hp",0)) == hp_before - 4, "FA-008 deals 1 pre-combat plus 3 combat damage")
	var automaton := Catalog.find_by_id("fa_010_automata_de_engranajes")
	check(int(automaton.get("cost",0)) == 4 and int(automaton.get("attack",0)) == 4 and int(automaton.get("health",0)) == 5, "FA-010 keeps canonical 4/4/5 body")

func _test_cpu_discard_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.cpu_hand.append("ta_014_reordenar")
	battle.cpu_hand.append("ta_007_centinela_runico")
	battle.cpu_draw_pile.append("ta_013_chispa_dirigida")
	check(battle.cpu_play_card(0), "CPU can resolve TA-014")
	check(not battle.has_pending_discard("enemy"), "CPU auto-resolves its pending discard")
	check(battle.enemy_discard.has("ta_014_reordenar"), "CPU played Rite enters enemy discard")
	check(battle.enemy_discard.size() == 2, "CPU also discards exactly one hand card")
