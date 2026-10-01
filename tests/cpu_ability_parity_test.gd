extends SceneTree

const Battle = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_cpu_summon_uses_shared_ability_engine()
	_test_cpu_policy_plays_targeted_rite()
	_test_cpu_relative_ally_targeting()
	_test_cpu_relative_token_summon()
	_test_cpu_last_breath_and_crypt_resource()
	_test_cpu_reveal_uses_own_deck()
	_test_cpu_exhumation_uses_own_discard()
	_test_invalid_cpu_target_spends_nothing()
	print("CPU ability parity checks: %d failures" % failures)
	quit(1 if failures else 0)

func _battle(player_domain: String, enemy_domain: String) -> CanonicalCpuBattle:
	var battle := Battle.new()
	battle.setup_cpu(
		player_domain,
		Catalog.starter_deck(player_domain),
		enemy_domain,
		Catalog.starter_deck(enemy_domain)
	)
	battle.event_queue.clear()
	battle.cpu_hand.clear()
	battle.cpu_draw_pile.clear()
	battle.cpu_energy_current = 12
	battle.cpu_essence_current = 0
	return battle

func _test_cpu_summon_uses_shared_ability_engine() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	battle.cpu_hand = ["sepulturero"]
	check(battle.cpu_play_card(0, 4), "CPU can play a creature through its canonical action path")
	check(battle.enemy_lanes[4] != null and str(battle.enemy_lanes[4].id) == "sepulturero", "CPU creature occupies enemy lane five")
	check(battle.cpu_essence_current == 1, "CPU summon ability grants its own Restos")
	check(battle.essence_current == 0, "CPU summon ability never grants player Essence")
	check(battle.cpu_energy_current == 10, "CPU pays the same printed Energy cost")
	var events := battle.drain_events()
	check(_has_event(events, "ABILITY_TRIGGERED"), "CPU summon exposes ABILITY_TRIGGERED")
	check(_has_side_event(events, "RESOURCE_SPENT", "enemy"), "CPU Energy spending is tagged as enemy-side")

func _test_cpu_policy_plays_targeted_rite() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.cpu_energy_current = 1
	battle.cpu_hand = ["proyectil_runico"]
	battle.player_lanes[4] = battle.create_unit("esqueleto_roto", true)
	var legal := battle.cpu_legal_actions_for_card(0)
	check(not legal.is_empty() and int(Dictionary(legal[0]).get("target_lane", -1)) == 4, "CPU policy sees legal opposing target on lane five")
	battle.cpu_take_actions()
	check(battle.player_lanes[4] == null, "CPU policy executes targeted Rite against player lane five")
	check(battle.cpu_hand.is_empty(), "CPU removes played Rite from its own hand")
	check(battle.enemy_discard.has("proyectil_runico"), "CPU Rite enters enemy discard")
	check(battle.cpu_essence_current == 1, "Tower CPU gains its own Conocimiento after playing a Rite")
	var events := battle.drain_events()
	check(_has_event(events, "EFFECT_APPLIED"), "CPU targeted Rite emits shared effect event")
	check(_has_side_card_event(events, "proyectil_runico", "enemy"), "CPU CARD_PLAYED identifies enemy side")

func _test_cpu_relative_ally_targeting() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_FORGE)
	battle.cpu_hand = ["sobrecarga"]
	battle.enemy_lanes[4] = battle.create_unit("centinela_de_cobre", true)
	check(battle.cpu_play_card(0, -1, 4), "CPU can target its own Construct with Overload")
	check(int(battle.enemy_lanes[4].attack) == 5, "Shared EffectResolver buffs CPU ally, not player lane")
	check(battle.cpu_essence_current == 2, "Overload grants Heat to CPU wallet")
	check(battle.essence_current == 0, "Overload does not leak Heat into player wallet")

func _test_cpu_relative_token_summon() -> void:
	var battle := _battle(Catalog.DOMAIN_CRYPT, Catalog.DOMAIN_FOREST)
	battle.cpu_hand = ["llamado_de_la_manada"]
	check(battle.cpu_play_card(0), "CPU can resolve no-click Call of the Pack")
	check(battle.enemy_lanes[0] != null and str(battle.enemy_lanes[0].id) == "cria_del_bosque", "First-free ally target resolves on CPU board")
	check(battle.player_lanes[0] == null, "CPU token never appears on player board")
	check(battle.cpu_essence_current == 1, "CPU token Rite grants its own Instinto")

func _test_cpu_last_breath_and_crypt_resource() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	battle.enemy_lanes[2] = battle.create_unit("esqueleto_roto", true)
	battle._deal_damage_to_unit(false, 2, 99)
	check(battle.enemy_lanes[2] == null, "CPU creature can die through shared damage path")
	check(battle.cpu_essence_current == 2, "CPU Broken Skeleton grants base Restos plus Last Breath Restos")
	check(battle.essence_current == 0, "CPU death resources remain isolated from player")

	var hound := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	hound.enemy_lanes[3] = hound.create_unit("perro_funebre", true)
	hound.player_lanes[3] = hound.create_unit("lobo_joven", true)
	hound._deal_damage_to_unit(false, 3, 99)
	check(hound.player_lanes[3] != null and int(hound.player_lanes[3].hp) == 2, "CPU Funeral Hound Last Breath damages opposing same lane")

func _test_cpu_reveal_uses_own_deck() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_TOWER)
	battle.cpu_hand = ["vision_prohibida"]
	battle.cpu_draw_pile = ["buho_oculum", "aprendiz_runico", "adepta_runica"]
	battle.draw_pile = ["ardilla_vigilante"]
	check(battle.cpu_play_card(0), "CPU resolves Forbidden Vision")
	check(battle.cpu_last_revealed.size() == 3, "CPU reveal records its own top three")
	check(battle.cpu_hand.size() == 1 and battle.cpu_hand[0] == "buho_oculum", "CPU reveal draws from CPU deck")
	check(battle.draw_pile.size() == 1 and battle.draw_pile[0] == "ardilla_vigilante", "CPU reveal does not touch player deck")
	check(battle.last_revealed.is_empty(), "CPU reveal does not overwrite player reveal state")

func _test_cpu_exhumation_uses_own_discard() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_CRYPT)
	battle.cpu_hand = ["exhumacion"]
	battle.enemy_discard = ["guardian_oseo"]
	battle.discard_pile = ["lobo_joven"]
	check(battle.cpu_play_card(0), "CPU resolves Exhumation")
	check(battle.cpu_hand.has("guardian_oseo"), "CPU Exhumation returns creature from enemy discard")
	check(not battle.enemy_discard.has("guardian_oseo"), "Returned CPU creature leaves enemy discard")
	check(battle.discard_pile.has("lobo_joven"), "CPU Exhumation never consumes player discard")

func _test_invalid_cpu_target_spends_nothing() -> void:
	var battle := _battle(Catalog.DOMAIN_FOREST, Catalog.DOMAIN_FORGE)
	battle.cpu_energy_current = 2
	battle.cpu_hand = ["sobrecarga"]
	battle.enemy_lanes[4] = battle.create_unit("lobo_joven", true)
	check(battle.cpu_legal_actions_for_card(0).is_empty(), "CPU policy rejects non-Construct Overload target")
	check(not battle.cpu_play_card(0, -1, 4), "CPU executor also rejects invalid Overload target")
	check(battle.cpu_energy_current == 2, "Rejected CPU ability spends no Energy")
	check(battle.cpu_hand.size() == 1 and battle.cpu_hand[0] == "sobrecarga", "Rejected CPU ability stays in CPU hand")

func _has_event(events: Array, event_type: String) -> bool:
	for event in events:
		if str(Dictionary(event).get("type", "")) == event_type:
			return true
	return false

func _has_side_event(events: Array, event_type: String, side: String) -> bool:
	for event in events:
		var data := Dictionary(event)
		if str(data.get("type", "")) == event_type and str(Dictionary(data.get("payload", {})).get("side", "")) == side:
			return true
	return false

func _has_side_card_event(events: Array, card_id: String, side: String) -> bool:
	for event in events:
		var data := Dictionary(event)
		if str(data.get("type", "")) != "CARD_PLAYED" or str(data.get("source_id", "")) != card_id:
			continue
		if str(Dictionary(data.get("payload", {})).get("side", "")) == side:
			return true
	return false
