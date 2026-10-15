extends SceneTree

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const Battle = preload("res://scripts/domain/canonical_battle_state.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_catalog_and_decks()
	_test_setup_and_energy()
	_test_combat_rules()
	_test_fatigue_and_slots()
	_test_domain_resources()
	_test_ability_system()
	print("Canonical battle checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_catalog_and_decks() -> void:
	check(Catalog.validate_catalog().is_empty(), "Canonical catalog validates")
	check(Catalog.all_card_ids().size() == 80, "Foundational catalog has exactly 80 cards")
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		check(Catalog.cards_for_domain(domain).size() == 20, "%s has exactly 20 foundational cards" % domain)
		var deck := Catalog.starter_deck(domain)
		check(deck.size() == 20, "%s starter deck has 20 cards" % domain)
		check(Catalog.validate_deck(deck, domain).is_empty(), "%s starter deck is legal" % domain)

func _test_setup_and_energy() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_FOREST)
	check(battle.player_lanes.size() == 5 and battle.enemy_lanes.size() == 5, "Battle has exactly five lanes per side")
	check(battle.player_integrity == 20 and battle.enemy_integrity == 20, "Both Nexuses start at 20 Integrity")
	check(battle.hand.size() == 4, "Opening hand contains four cards")
	check(battle.energy_capacity == 1 and battle.energy_current == 1, "Energy starts at 1/1")
	battle.recharge_energy_for_new_turn()
	check(battle.energy_capacity == 2 and battle.energy_current == 2, "Energy grows and refills")
	for i in range(10):
		battle.recharge_energy_for_new_turn()
	check(battle.energy_capacity == 6 and battle.energy_current == 6, "Standard Energy cap is six")
	battle.grant_temporary_energy(20)
	check(battle.energy_current == 12, "Extraordinary Energy never exceeds twelve")

	var second := Battle.new()
	second.setup_starter(Catalog.DOMAIN_FOREST, true)
	check(second.use_impulse(), "Second player can use Rune of Impulse once")
	check(second.energy_current == 2 and second.energy_capacity == 1, "Impulse grants temporary Energy without raising capacity")
	check(not second.use_impulse(), "Rune of Impulse cannot be reused")

func _test_combat_rules() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_FOREST)
	battle.player_lanes = [battle.create_unit("bs_003_lobo_joven", true), null, null, null, null]
	battle.enemy_lanes = [battle.create_unit("bs_003_lobo_joven", true), null, null, null, null]
	battle.resolve_player_attacks()
	check(battle.enemy_lanes[0] == null, "Simultaneous combat can kill defender")
	check(battle.player_lanes[0] != null and int(battle.player_lanes[0].hp) == 1, "Defender retaliates simultaneously")

	var direct := Battle.new()
	direct.setup_starter(Catalog.DOMAIN_FOREST)
	direct.player_lanes = [direct.create_unit("bs_003_lobo_joven", true), null, null, null, null]
	direct.enemy_lanes = [null, null, null, null, null]
	direct.resolve_player_attacks()
	check(direct.enemy_integrity == 17, "Open lane uses the attacker current Attack for direct Nexus damage")
	check(direct.essence_current == 1, "Forest gains Instinct from direct damage")

func _test_fatigue_and_slots() -> void:
	var fatigue := Battle.new()
	fatigue.setup_starter(Catalog.DOMAIN_FOREST)
	fatigue.draw_pile.clear()
	fatigue.hand.clear()
	fatigue.draw_card()
	check(fatigue.player_integrity == 19, "First failed draw deals one Instability damage")
	fatigue.draw_card()
	check(fatigue.player_integrity == 17, "Second failed draw deals two Instability damage")

func _test_domain_resources() -> void:
	var crypt := Battle.new()
	crypt.setup_starter(Catalog.DOMAIN_CRYPT)
	crypt.player_lanes[0] = crypt.create_unit("ch_001_rata_de_osario", true)
	crypt._deal_damage_to_unit(true, 0, 5)
	check(crypt.essence_current == 1, "Crypt allied death produces base Remains")

	var forge := Battle.new()
	forge.setup_starter(Catalog.DOMAIN_FORGE)
	forge.essence_current = 6
	forge.end_player_turn()
	check(forge.player_integrity == 19 and forge.essence_current == 3, "Forge overload damages Nexus and drops Heat to three")

func _test_ability_system() -> void:
	var forest := Battle.new()
	forest.setup_starter(Catalog.DOMAIN_FOREST)
	forest.energy_current = 12
	forest.player_lanes[0] = forest.create_unit("bs_003_lobo_joven", true)
	forest.hand = ["bs_006_lobo_de_manada"]
	check(forest.play_card(0, 1), "Summon ability resolves through generic system")
	check(int(forest.player_lanes[1].get("attack", 0)) == 4, "Conditional summon ability sees adjacent ally and grants permanent Attack")

	forest.energy_current = 12
	forest.hand = ["bs_015_crecimiento_repentino"]
	check(forest.play_card(0, -1, 0), "Targeted rite resolves declaratively")
	check(int(forest.player_lanes[0].attack) == 3 and int(forest.player_lanes[0].hp) == 4, "EffectResolver applies permanent attack and health")
	var forest_events := forest.drain_events()
	check(_has_event(forest_events, "ABILITY_TRIGGERED"), "Ability resolution emits ABILITY_TRIGGERED")
	check(_has_event(forest_events, "EFFECT_APPLIED"), "Ability effects emit EFFECT_APPLIED")

	var tower := Battle.new()
	tower.setup_starter(Catalog.DOMAIN_TOWER)
	tower.energy_current = 12
	tower.hand = ["ta_013_chispa_dirigida"]
	tower.enemy_lanes[4] = tower.create_unit("fa_002_chispero_de_cobre", true)
	check(tower.play_card(0, -1, 4), "Enemy-targeted rite can target lane five")
	check(tower.enemy_lanes[4] == null, "Generic damage effect kills its target")

	var forge := Battle.new()
	forge.setup_starter(Catalog.DOMAIN_FORGE)
	forge.energy_current = 12
	forge.enemy_lanes[4] = forge.create_unit("bs_010_oso_musgoso", true)
	forge.hand = ["fa_015_golpe_de_martillo"]
	check(forge.play_card(0, -1, 4), "Target-conditioned hammer spell resolves on enemy unit")
	check(int(forge.enemy_lanes[4].hp) == 4, "Golpe de Martillo deals two damage through generic effects")

	var invalid := Battle.new()
	invalid.setup_starter(Catalog.DOMAIN_FORGE)
	invalid.energy_current = 12
	invalid.hand = ["fa_015_golpe_de_martillo"]
	check(not invalid.play_card(0, -1, 4), "Ability condition rejects empty enemy lane")
	check(invalid.energy_current == 12, "Rejected ability does not spend Energy")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if str(event.get("type", "")) == event_type:
			return true
	return false
