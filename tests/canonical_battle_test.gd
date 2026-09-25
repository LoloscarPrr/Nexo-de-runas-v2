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
	print("Canonical battle checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_catalog_and_decks() -> void:
	check(Catalog.validate_catalog().is_empty(), "Canonical catalog validates")
	check(Catalog.all_card_ids().size() == 48, "Canonical catalog has exactly 48 cards")
	for domain in [Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_TOWER, Catalog.DOMAIN_FORGE]:
		check(Catalog.cards_for_domain(domain).size() == 12, "%s has 12 cards" % domain)
		var deck := Catalog.starter_deck(domain)
		check(deck.size() == 20, "%s starter deck has 20 cards" % domain)
		check(Catalog.validate_deck(deck, domain).is_empty(), "%s starter deck is legal" % domain)

func _test_setup_and_energy() -> void:
	var battle := Battle.new()
	battle.setup_starter(Catalog.DOMAIN_FOREST)
	check(battle.player_lanes.size() == 4 and battle.enemy_lanes.size() == 4, "Battle has exactly four lanes per side")
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
	battle.player_lanes = [battle.create_unit("lobo_joven", true), null, null, null]
	battle.enemy_lanes = [battle.create_unit("perro_funebre", true), null, null, null]
	battle.resolve_player_attacks()
	check(battle.enemy_lanes[0] == null, "Simultaneous combat can kill defender")
	check(battle.player_lanes[0] != null and int(battle.player_lanes[0].hp) == 1, "Defender retaliates simultaneously")

	var direct := Battle.new()
	direct.setup_starter(Catalog.DOMAIN_FOREST)
	direct.player_lanes = [direct.create_unit("lobo_joven", true), null, null, null]
	direct.enemy_lanes = [null, null, null, null]
	direct.resolve_player_attacks()
	check(direct.enemy_integrity == 18, "Open lane deals direct Nexus damage")
	check(direct.essence_current == 1, "Forest gains Instinct from direct damage")

	var ambush := Battle.new()
	ambush.setup_starter(Catalog.DOMAIN_FOREST)
	ambush.player_lanes = [ambush.create_unit("zorro_acechante", true), null, null, null]
	ambush.enemy_lanes = [ambush.create_unit("esqueleto_roto", true), null, null, null]
	ambush.resolve_player_attacks()
	check(ambush.enemy_lanes[0] == null, "Ambush kills before retaliation")
	check(ambush.player_lanes[0] != null and int(ambush.player_lanes[0].hp) == 2, "Ambusher takes no retaliation from destroyed target")

	var shield := Battle.new()
	shield.setup_starter(Catalog.DOMAIN_FOREST)
	shield.player_lanes = [shield.create_unit("lobo_joven", true), null, null, null]
	shield.enemy_lanes = [shield.create_unit("centinela_de_cobre", true), null, null, null]
	shield.resolve_player_attacks()
	check(shield.enemy_lanes[0] != null and int(shield.enemy_lanes[0].hp) == 2, "Blindage reduces the next incoming damage")
	check(int(shield.enemy_lanes[0].shield) == 0, "Blindage is consumed")

	var guard := Battle.new()
	guard.setup_starter(Catalog.DOMAIN_FOREST)
	guard.player_lanes = [guard.create_unit("lobo_joven", true), null, null, null]
	guard.enemy_lanes = [null, guard.create_unit("guardian_oseo", true), null, null]
	guard.resolve_player_attacks()
	check(guard.enemy_integrity == 20, "Guard intercepts direct damage from an adjacent lane")
	check(bool(guard.enemy_lanes[1].guard_used), "Guard can intercept only once per turn")

func _test_fatigue_and_slots() -> void:
	var fatigue := Battle.new()
	fatigue.setup_starter(Catalog.DOMAIN_FOREST)
	fatigue.draw_pile.clear()
	fatigue.hand.clear()
	fatigue.draw_card()
	check(fatigue.player_integrity == 19, "First failed draw deals one Instability damage")
	fatigue.draw_card()
	check(fatigue.player_integrity == 17, "Second failed draw deals two Instability damage")

	var slots := Battle.new()
	slots.setup_starter(Catalog.DOMAIN_FOREST)
	slots.energy_current = 12
	slots.hand = ["sello_del_rastro", "sello_del_rastro", "sello_del_rastro", "sello_del_rastro"]
	check(slots.play_card(0), "First Seal can be played")
	check(slots.play_card(0), "Second Seal can be played")
	check(slots.play_card(0), "Third Seal can be played")
	check(not slots.play_card(0), "Fourth Seal requires an explicit replacement")
	check(slots.play_card(0, -1, -1, 1), "Fourth Seal can replace a chosen slot")
	check(slots.active_seals.size() == 3, "Exactly three Seal slots remain active")

func _test_domain_resources() -> void:
	var crypt := Battle.new()
	crypt.setup_starter(Catalog.DOMAIN_CRYPT)
	crypt.player_lanes[0] = crypt.create_unit("esqueleto_roto", true)
	crypt._deal_damage_to_unit(true, 0, 5)
	check(crypt.essence_current == 2, "Broken Skeleton death produces base Remains plus Last Breath Remains")

	var forge := Battle.new()
	forge.setup_starter(Catalog.DOMAIN_FORGE)
	forge.essence_current = 6
	forge.end_player_turn()
	check(forge.player_integrity == 19 and forge.essence_current == 3, "Forge overload damages Nexus and drops Heat to three")
