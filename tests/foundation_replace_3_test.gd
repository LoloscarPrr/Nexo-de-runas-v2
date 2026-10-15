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
	_test_cpu_archmage_parity()
	print("Foundation replace 3 checks: %d failures" % failures)
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
	check(Catalog.validate_catalog().is_empty(), "Replace 3 catalog validates")
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
		check(foundational_domain >= 14, "%s preserves at least 14 foundational cards from Replace 3" % domain)
		check(Catalog.validate_deck(Catalog.starter_deck(domain), domain).is_empty(), "%s starter deck remains legal" % domain)
	check(foundational_total >= 56, "Migration preserves at least 56 foundational cards reached in Replace 3")
	for removed_id in ["llamado_de_la_manada","crecimiento_violento","exhumacion","urna_de_restos","proyectil_runico","vision_prohibida","sobrecarga","horno_runico"]:
		check(Catalog.find_by_id(removed_id).is_empty(), "Legacy card removed: %s" % removed_id)
	for added_id in [
		"bs_006_lobo_de_manada","bs_015_crecimiento_repentino",
		"ch_014_exhumar","ch_015_toque_funebre",
		"ta_011_maestro_de_cinco_trazos","ta_012_archimaga_de_las_cinco_runas",
		"fa_012_martillo_ambulante","fa_015_golpe_de_martillo"
	]:
		check(not Catalog.find_by_id(added_id).is_empty(), "Foundational replacement exists: %s" % added_id)

func _test_forest_replacements() -> void:
	var pack := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	pack.player_lanes[1] = pack.create_unit("bs_003_lobo_joven", true)
	pack.hand.append("bs_006_lobo_de_manada")
	check(pack.play_card(0, 2), "BS-006 can be summoned adjacent to ally")
	check(int(pack.player_lanes[2].get("attack", 0)) == 4, "BS-006 gains +1 Attack permanently")
	check(int(pack.player_lanes[2].get("max_hp", 0)) == 4, "BS-006 gains +1 Health permanently")

	var growth := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	growth.player_lanes[4] = growth.create_unit("bs_003_lobo_joven", true)
	growth.player_lanes[4]["hp"] = 1
	growth.hand.append("bs_015_crecimiento_repentino")
	check(growth.play_card(0, -1, 4), "BS-015 resolves on damaged ally")
	check(int(growth.player_lanes[4].get("attack", 0)) == 3, "BS-015 grants permanent +1 Attack")
	check(int(growth.player_lanes[4].get("max_hp", 0)) == 4, "BS-015 grants permanent +1 max Health")
	check(int(growth.player_lanes[4].get("hp", 0)) == 3, "BS-015 heals one extra when target was damaged")

func _test_crypt_replacements() -> void:
	var exhume := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	exhume.discard_pile.append("ch_001_rata_de_osario")
	exhume.hand.append("ch_014_exhumar")
	check(exhume.play_card(0), "CH-014 resolves")
	check(exhume.hand.has("ch_001_rata_de_osario"), "CH-014 returns cost-one creature to hand")
	check(not exhume.discard_pile.has("ch_001_rata_de_osario"), "Returned creature leaves discard")

	var lethal := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	lethal.player_integrity = 15
	lethal.enemy_lanes[2] = lethal.create_unit("ch_001_rata_de_osario", true)
	lethal.hand.append("ch_015_toque_funebre")
	check(lethal.play_card(0, -1, 2), "CH-015 resolves lethally")
	check(lethal.enemy_lanes[2] == null, "CH-015 kills a one-health target")
	check(lethal.player_integrity == 16, "CH-015 heals own Nexus by one when its damage kills")

	var nonlethal := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	nonlethal.player_integrity = 15
	nonlethal.enemy_lanes[2] = nonlethal.create_unit("bs_010_oso_musgoso", true)
	nonlethal.hand.append("ch_015_toque_funebre")
	check(nonlethal.play_card(0, -1, 2), "CH-015 resolves nonlethally")
	check(nonlethal.player_integrity == 15, "CH-015 does not heal when target survives")

func _test_tower_replacements() -> void:
	var master := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	master.player_lanes[1] = master.create_unit("ta_011_maestro_de_cinco_trazos", true)
	master.player_lanes[1]["hp"] = 4
	master.enemy_lanes[4] = master.create_unit("bs_010_oso_musgoso", true)
	var base_attack := int(master.player_lanes[1].get("attack", 0))
	master.hand.append("ta_013_chispa_dirigida")
	check(master.play_card(0, -1, 4), "First spell can trigger TA-011")
	check(int(master.player_lanes[1].get("hp", 0)) == 5, "TA-011 heals itself by one on first spell")
	check(int(master.player_lanes[1].get("attack", 0)) == base_attack + 1, "TA-011 gains +1 Attack this turn on first spell")
	master.hand.append("ta_013_chispa_dirigida")
	check(master.play_card(0, -1, 4), "Second spell still resolves")
	check(int(master.player_lanes[1].get("hp", 0)) == 5, "TA-011 does not heal twice in same turn")
	check(int(master.player_lanes[1].get("attack", 0)) == base_attack + 1, "TA-011 does not gain Attack twice in same turn")

	var archmage := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	archmage.hand.append("ta_012_archimaga_de_las_cinco_runas")
	archmage.draw_pile.append("ta_013_chispa_dirigida")
	archmage.draw_pile.append("ta_016_descarga_runica")
	check(archmage.play_card(0, 2), "TA-012 resolves Invocation")
	check(archmage.has_pending_discard("player"), "TA-012 requests one discard after drawing two")
	check(archmage.hand.size() == 2, "TA-012 leaves both drawn cards available for discard choice")
	check(archmage.effective_card_cost("ta_016_descarga_runica", "player") == 1, "TA-012 reduces cost-two spell to one")
	check(archmage.effective_card_cost("ta_013_chispa_dirigida", "player") == 1, "TA-012 respects minimum cost one")
	check(archmage.resolve_pending_discard("player", 0), "Player can resolve TA-012 discard choice")
	archmage._expire_cost_modifiers("player", "turn")
	check(archmage.effective_card_cost("ta_016_descarga_runica", "player") == 2, "TA-012 discount expires with turn")

func _test_forge_replacements() -> void:
	var hammer := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	hammer.player_lanes[2] = hammer.create_unit("fa_012_martillo_ambulante", true)
	hammer.enemy_lanes[2] = hammer.create_unit("bs_011_anciano_de_raices", true)
	hammer.resolve_player_attacks()
	check(hammer.enemy_lanes[2] == null, "FA-012 gains enough Attack to destroy lower-Attack blocker")
	check(hammer.player_lanes[2] != null and int(hammer.player_lanes[2].get("hp", 0)) == 1, "FA-012 still takes simultaneous retaliation")

	var blow := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	blow.enemy_lanes[4] = blow.create_unit("bs_010_oso_musgoso", true)
	var before_hp := int(blow.enemy_lanes[4].get("hp", 0))
	blow.hand.append("fa_015_golpe_de_martillo")
	check(blow.play_card(0, -1, 4), "FA-015 resolves")
	check(int(blow.enemy_lanes[4].get("hp", 0)) == before_hp - 2, "FA-015 deals exactly two damage")

func _test_cpu_archmage_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.cpu_hand.append("ta_012_archimaga_de_las_cinco_runas")
	battle.cpu_draw_pile.append("ta_013_chispa_dirigida")
	battle.cpu_draw_pile.append("ta_016_descarga_runica")
	check(battle.cpu_play_card(0, 2), "CPU can summon TA-012")
	check(not battle.has_pending_discard("enemy"), "CPU auto-resolves TA-012 discard choice")
	check(battle.effective_card_cost("ta_016_descarga_runica", "enemy") == 1, "CPU receives same spell discount")
