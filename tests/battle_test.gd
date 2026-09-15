extends SceneTree

const Battle = preload("res://scripts/domain/battle_state.gd")
var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
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
	print("Battle checks: %d failures" % failures)
	quit(1 if failures else 0)
