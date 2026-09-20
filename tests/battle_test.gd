extends SceneTree

const Battle = preload("res://scripts/domain/battle_state.gd")
const Catalog = preload("res://scripts/domain/card_catalog.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_core_payments()
	_test_full_catalog()
	_test_worthy_sacrifice()
	_test_many_lives()
	_test_combat_sigils()
	_test_evolution_and_generation()
	print("Battle checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_core_payments() -> void:
	var battle := Battle.new()
	battle.setup(["armino", "lobo", "zarigueya"])
	check(battle.play_card(3, 0, []), "Initial squirrel can be played")
	check(not battle.play_card(1, 1, [0]), "Two blood cannot be paid with one creature")
	check(battle.player_lanes[0] != null and battle.bones == 0, "Failed payment is atomic")
	check(battle.play_card(0, 0, [0]), "Sacrifice frees its own lane")
	check(battle.bones == 1 and battle.player_lanes[0].id == "armino", "Sacrifice grants one bone")
	check(not battle.play_card(1, 1, []), "Insufficient bones reject play")
	battle.bones = 2
	check(battle.play_card(1, 1, []), "Bone card pays exact cost")
	check(battle.bones == 0, "Bones spent")
	battle.draw_pile.clear()
	battle.squirrel_pile_count = 0
	battle.enemy_lanes = [null, null, null, null]
	battle.player_lanes = [null, null, null, null]
	battle.end_turn()
	check(not battle.needs_draw(), "Empty piles never deadlock the turn")
	battle.draw_pending = true
	battle.squirrel_pile_count = 1
	check(battle.draw_squirrel(), "Separate squirrel draw")
	check(not battle.draw_squirrel(), "Only one draw per turn")

func _test_full_catalog() -> void:
	check(Catalog.all_card_ids().size() == 94, "Canonical catalog contains all 94 cards")
	check(Catalog.campaign_reward_pool().size() > 12, "Reward pool is no longer limited to twelve cards")
	for card_id in Catalog.all_card_ids():
		check(not Catalog.find_by_id(card_id).is_empty(), "Catalog lookup works for %s" % card_id)

func _test_worthy_sacrifice() -> void:
	var battle := Battle.new()
	battle.setup(["cabra_negra", "oso_grizzly"])
	check(battle.play_card(2, 0, []), "Squirrel enters before Black Goat test")
	check(battle.play_card(0, 0, [0]), "Black Goat can replace squirrel")
	check(battle.blood_value_for_sacrifices([0]) == 3, "Black Goat provides three blood")
	check(battle.play_card(0, 1, [0]), "Three-blood Grizzly can be paid by one Black Goat")

func _test_many_lives() -> void:
	var battle := Battle.new()
	battle.player_lanes = [battle._new_unit("gato"), null, null, null]
	for i in range(9):
		battle._sacrifice_player_unit(0)
	check(battle.player_lanes[0] != null and battle.player_lanes[0].id == "gato_no_muerto", "Cat survives nine sacrifices and transforms")

	var child := Battle.new()
	child.player_lanes = [child._new_unit("nino_13"), null, null, null]
	child._sacrifice_player_unit(0)
	check(child.player_lanes[0].id == "nino_13_despierto", "Child 13 wakes after sacrifice")
	child._sacrifice_player_unit(0)
	check(child.player_lanes[0].id == "nino_13", "Child 13 alternates state")
	for i in range(11):
		child._sacrifice_player_unit(0)
	check(child.player_lanes[0] != null and child.player_lanes[0].id == "nino_hambriento", "Child 13 becomes Hungry Child after thirteen sacrifices")

func _test_combat_sigils() -> void:
	var flying := Battle.new()
	flying.player_lanes = [flying._new_unit("gorrion"), null, null, null]
	flying.enemy_lanes = [flying._new_unit("rana_toro"), null, null, null]
	flying._resolve_side_attacks(true)
	check(flying.scale == 0 and int(flying.enemy_lanes[0].hp) == 1, "Mighty Leap blocks Airborne")

	var quills := Battle.new()
	quills.player_lanes = [quills._new_unit("lobo"), null, null, null]
	quills.enemy_lanes = [quills._new_unit("puercoespin"), null, null, null]
	quills._resolve_side_attacks(true)
	check(quills.player_lanes[0] != null and int(quills.player_lanes[0].hp) == 1, "Sharp Quills damages attacker")
	check(quills.enemy_lanes[0] == null, "Wolf still kills Porcupine")

	var immortal := Battle.new()
	immortal.player_lanes = [immortal._new_unit("cucaracha"), null, null, null]
	immortal._kill_unit(true, 0, true, -1)
	check(immortal.hand.has("cucaracha"), "Unkillable returns Cockroach to hand")

func _test_evolution_and_generation() -> void:
	var evolve := Battle.new()
	evolve.player_lanes = [evolve._new_unit("cachorro_de_lobo"), null, null, null]
	evolve._end_side_phase(true)
	check(evolve.player_lanes[0] != null and evolve.player_lanes[0].id == "lobo", "Wolf Cub evolves into Wolf")

	var warren := Battle.new()
	warren.player_lanes = [warren._new_unit("madriguera"), null, null, null]
	warren._on_card_played(true, 0)
	check(warren.hand.has("conejo"), "Warren adds Rabbit to hand")

	var beaver := Battle.new()
	beaver.player_lanes = [null, beaver._new_unit("castor"), null, null]
	beaver._on_card_played(true, 1)
	check(beaver.player_lanes[0] != null and beaver.player_lanes[0].id == "represa", "Beaver creates left Dam")
	check(beaver.player_lanes[2] != null and beaver.player_lanes[2].id == "represa", "Beaver creates right Dam")
