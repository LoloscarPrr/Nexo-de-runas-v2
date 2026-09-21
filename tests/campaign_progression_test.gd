extends SceneTree

const Campaign = preload("res://scripts/domain/campaign_state.gd")
const Battle = preload("res://scripts/domain/battle_state.gd")
const Sigils = preload("res://scripts/domain/sigil_catalog.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failures += 1

func _initialize() -> void:
	_test_old_save_continues()
	_test_campfire_persists()
	_test_special_event_routes()
	_test_bone_lord()
	_test_prospector()
	_test_special_card_persistence()
	_test_sigil_rulebook()
	print("Campaign progression checks: %d failures" % failures)
	quit(1 if failures else 0)

func _test_old_save_continues() -> void:
	var old_save := {
		"version": 2,
		"run_seed": 123,
		"current_node": "gate_1",
		"resolved_nodes": ["start", "choice_left", "battle_1", "campfire_1", "gate_1"],
		"claimed_rewards": [],
		"deck_ids": ["armino", "lobo", "rana_toro"],
		"victories": 1,
		"defeats": 0,
		"started_at_unix": 1
	}
	var state := Campaign.new()
	check(state.load_from_dict(old_save), "Previous version-2 save still loads")
	check(state.can_enter("choice_2_left"), "Old save at gate can enter second left choice")
	check(state.can_enter("choice_2_right"), "Old save at gate can enter second right choice")

func _test_campfire_persists() -> void:
	var state := Campaign.new()
	check(state.upgrade_card("lobo", "atk"), "Campfire can add attack")
	check(state.upgrade_card("lobo", "hp"), "Campfire can add health")
	var buff := state.get_card_buff("lobo")
	check(int(buff.atk) == 1, "Attack buff stored")
	check(int(buff.hp) == 2, "Health buff stored")

	var reloaded := Campaign.new()
	check(reloaded.load_from_dict(state.to_dict()), "Save with campfire buffs reloads")
	var reloaded_buff := reloaded.get_card_buff("lobo")
	check(int(reloaded_buff.atk) == 1 and int(reloaded_buff.hp) == 2, "Campfire buffs persist through save")

	var battle := Battle.new()
	battle.setup(reloaded.deck_ids, reloaded.card_buffs, "battle_2")
	var player_wolf := battle._new_unit("lobo", true)
	var enemy_wolf := battle._new_unit("lobo", false)
	check(int(player_wolf.hp) == 4, "Campfire +2 health applies to player Wolf")
	check(int(player_wolf.attack_bonus) == 1, "Campfire +1 attack applies to player Wolf")
	check(int(enemy_wolf.hp) == 2 and int(enemy_wolf.attack_bonus) == 0, "Player buffs do not affect enemy copies")

func _reach_gate(state: Campaign) -> void:
	check(state.resolve_node("choice_left"), "Enter first choice")
	check(state.resolve_node("battle_1"), "Reach first battle")
	check(state.resolve_node("campfire_1"), "Reach first campfire")
	check(state.resolve_node("gate_1"), "Reach forest gate")

func _test_special_event_routes() -> void:
	var left := Campaign.new()
	_reach_gate(left)
	check(left.resolve_node("choice_2_left"), "Enter second left route")
	check(left.can_enter("prospector_event"), "Left route exposes Prospector event")

	var right := Campaign.new()
	_reach_gate(right)
	check(right.resolve_node("choice_2_right"), "Enter second right route")
	check(right.can_enter("bone_altar"), "Right route exposes Bone Lord altar")

func _test_bone_lord() -> void:
	var state := Campaign.new()
	state.deck_ids.append("cabra_negra")
	_reach_gate(state)
	check(state.resolve_node("choice_2_right"), "Reach Bone Lord route")
	check(state.sacrifice_to_bone_lord("bone_altar", "cabra_negra"), "Black Goat can be offered")
	check(state.bone_boon == 8, "Black Goat grants eight starting Bones")
	check(not state.deck_ids.has("cabra_negra"), "Sacrificed card leaves the deck")
	check(state.can_enter("battle_2"), "Bone altar resolves into second battle")

	var reloaded := Campaign.new()
	check(reloaded.load_from_dict(state.to_dict()), "Bone boon save reloads")
	check(reloaded.bone_boon == 8, "Bone boon persists in save")

func _test_prospector() -> void:
	var state := Campaign.new()
	state.run_seed = 456
	_reach_gate(state)
	check(state.resolve_node("choice_2_left"), "Reach Prospector route")
	var reward := state.claim_prospector_boulder("prospector_event", 1)
	check(not reward.is_empty(), "Prospector boulder yields a reward")
	check(state.deck_ids.has(reward), "Prospector reward enters deck")
	check(state.can_enter("battle_2"), "Prospector event resolves into second battle")
	check(not state.claim_prospector_boulder("prospector_event", 2), "Prospector event cannot be claimed twice")

func _test_special_card_persistence() -> void:
	var state := Campaign.new()
	state.ouroboros_bonus = 4
	var reloaded := Campaign.new()
	check(reloaded.load_from_dict(state.to_dict()), "Ouroboros special state reloads")
	check(reloaded.ouroboros_bonus == 4, "Ouroboros growth persists between battles")

func _test_sigil_rulebook() -> void:
	var flying := Sigils.get_info("AIRBORNE")
	check(str(flying.get("name", "")) == "AÉREO", "Sigil rulebook exposes localized name")
	check(str(flying.get("description", "")).length() > 20, "Sigil rulebook exposes readable description")
	var quills := Sigils.get_info("SHARP_QUILLS")
	check(str(quills.get("name", "")) == "ESPINAS", "Sharp Quills has dedicated rulebook entry")
