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
	_test_tower_first_spell_trigger()
	_test_forge_replacements()
	_test_cpu_first_spell_parity()
	print("Foundation replace 1 checks: %d failures" % failures)
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

func _test_migration_count() -> void:
	check(Catalog.validate_catalog().is_empty(), "Replacement catalog validates")
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
		check(foundational_domain == 10, "%s reaches exactly 10 foundational cards" % domain)
		check(Catalog.validate_deck(Catalog.starter_deck(domain), domain).is_empty(), "%s starter deck remains legal" % domain)
	check(foundational_total == 40, "Migration reaches exactly 40 foundational + 40 legacy cards")
	for removed_id in ["cuervo_del_sendero","jabali_de_raiz","sepulturero","necrofago","buho_oculum","serpiente_de_mana","engranaje_vivo","torreta_runica"]:
		check(Catalog.find_by_id(removed_id).is_empty(), "Legacy card removed: %s" % removed_id)
	for added_id in [
		"bs_002_ardilla_runica","bs_008_jabali_de_corteza",
		"ch_003_guardia_esqueletico","ch_005_perro_de_la_fosa",
		"ta_001_aprendiz_de_sigilos","ta_005_teurgo_de_chispas",
		"fa_002_chispero_de_cobre","fa_006_soldado_remachado"
	]:
		check(not Catalog.find_by_id(added_id).is_empty(), "Foundational replacement exists: %s" % added_id)

func _test_forest_replacements() -> void:
	var squirrel := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	squirrel.player_integrity = 15
	squirrel.player_lanes[0] = squirrel.create_unit("bs_002_ardilla_runica", true)
	squirrel._kill_unit(true, 0, "damage", "test", "enemy")
	check(squirrel.player_integrity == 16, "Ardilla Rúnica heals own Nexus by 1 on death")
	var boar := Catalog.find_by_id("bs_008_jabali_de_corteza")
	check(int(boar.get("cost", 0)) == 3 and int(boar.get("attack", 0)) == 4 and int(boar.get("health", 0)) == 3, "Jabalí de Corteza keeps canonical 3/4/3 body")

func _test_crypt_replacements() -> void:
	var guard := Catalog.find_by_id("ch_003_guardia_esqueletico")
	check(int(guard.get("cost", 0)) == 2 and int(guard.get("attack", 0)) == 2 and int(guard.get("health", 0)) == 3, "Guardia Esquelético keeps canonical 2/2/3 body")
	var hound := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	var unit := hound.create_unit("ch_005_perro_de_la_fosa", false)
	check(bool(unit.get("ready", false)), "Perro de la Fosa enters ready through Embestida")

func _test_tower_first_spell_trigger() -> void:
	var battle := _battle(Catalog.DOMAIN_TOWER, Catalog.DOMAIN_CRYPT)
	battle.player_lanes[1] = battle.create_unit("ta_001_aprendiz_de_sigilos", true)
	battle.player_lanes[2] = battle.create_unit("ta_005_teurgo_de_chispas", true)
	battle.enemy_lanes[2] = battle.create_unit("guardian_oseo", true)
	var apprentice_base := int(battle.player_lanes[1].get("attack", 0))
	var enemy_hp := int(battle.enemy_lanes[2].get("hp", 0))
	battle.hand.append("ta_013_chispa_dirigida")
	check(battle.play_card(0, -1, 2), "First Tower spell resolves")
	check(int(battle.player_lanes[1].get("attack", 0)) == apprentice_base + 1, "Aprendiz gets +1 Attack from first spell")
	check(int(battle.enemy_lanes[2].get("hp", 0)) == enemy_hp - 2, "First spell deals its own damage plus Teúrgo ping")
	var after_first := int(battle.enemy_lanes[2].get("hp", 0))
	battle.hand.append("ta_013_chispa_dirigida")
	check(battle.play_card(0, -1, 2), "Second Tower spell resolves")
	check(int(battle.player_lanes[1].get("attack", 0)) == apprentice_base + 1, "Aprendiz does not trigger twice in same turn")
	check(int(battle.enemy_lanes[2].get("hp", 0)) == after_first - 1, "Teúrgo does not trigger on second spell")
	battle.reset_turn_gates("player")
	battle.hand.append("ta_013_chispa_dirigida")
	check(battle.play_card(0, -1, 2), "First spell of next gate window resolves")
	check(int(battle.player_lanes[1].get("attack", 0)) == apprentice_base + 2, "First-spell event can trigger again next turn")

func _test_forge_replacements() -> void:
	var sparker := _battle(Catalog.DOMAIN_FORGE, Catalog.DOMAIN_FOREST)
	sparker.player_lanes[2] = sparker.create_unit("fa_002_chispero_de_cobre", true)
	sparker.enemy_lanes[2] = sparker.create_unit("lobo_joven", true)
	var hp_before := int(sparker.enemy_lanes[2].get("hp", 0))
	sparker._kill_unit(true, 2, "damage", "test", "enemy")
	check(int(sparker.enemy_lanes[2].get("hp", 0)) == hp_before - 1, "Chispero de Cobre deals 1 to opposing enemy on death")
	var soldier := Catalog.find_by_id("fa_006_soldado_remachado")
	check(int(soldier.get("cost", 0)) == 3 and int(soldier.get("attack", 0)) == 3 and int(soldier.get("health", 0)) == 4, "Soldado Remachado keeps canonical 3/3/4 body")

func _test_cpu_first_spell_parity() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.enemy_lanes[1] = battle.create_unit("ta_001_aprendiz_de_sigilos", true)
	battle.enemy_lanes[2] = battle.create_unit("ta_005_teurgo_de_chispas", true)
	battle.player_lanes[2] = battle.create_unit("lobo_joven", true)
	var apprentice_base := int(battle.enemy_lanes[1].get("attack", 0))
	var player_hp := int(battle.player_lanes[2].get("hp", 0))
	battle.cpu_hand.append("ta_013_chispa_dirigida")
	check(battle.cpu_play_card(0, -1, 2), "CPU can play first spell")
	check(int(battle.enemy_lanes[1].get("attack", 0)) == apprentice_base + 1, "CPU Aprendiz uses same first-spell trigger")
	check(int(battle.player_lanes[2].get("hp", 0)) == player_hp - 2, "CPU Teúrgo uses same first-spell ping semantics")
