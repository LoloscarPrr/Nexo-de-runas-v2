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
	_test_second_segment_from_existing_end()
	_test_sigil_transfer()
	_test_mycologists()
	_test_deck_trial()
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
	battle.setup(reloaded.deck_ids, reloaded.card_buffs, "battle_2", reloaded.card_sigils)
	var player_wolf := battle._new_unit("lobo", true)
	var enemy_wolf := battle._new_unit("lobo", false)
	check(int(player_wolf.hp) == 4, "Campfire +2 health applies to player Wolf")
	check(int(player_wolf.attack_bonus) == 1, "Campfire +1 attack applies to player Wolf")
	check(int(enemy_wolf.hp) == 2 and int(enemy_wolf.attack_bonus) == 0, "Player buffs do not affect enemy copies")

func _reach_gate(state) -> void:
	check(state.resolve_node("choice_left"), "Enter first choice")
	check(state.resolve_node("battle_1"), "Reach first battle")
	check(state.resolve_node("campfire_1"), "Reach first campfire")
	check(state.resolve_node("gate_1"), "Reach forest gate")

func _reach_region_complete(state) -> void:
	_reach_gate(state)
	check(state.resolve_node("choice_2_left"), "Enter second left route")
	check(not state.claim_prospector_boulder("prospector_event", 0).is_empty(), "Prospector resolves")
	check(state.resolve_node("battle_2"), "Reach second battle")
	check(state.resolve_node("campfire_2"), "Reach second campfire")
	check(state.resolve_node("boss_1"), "Reach first boss")
	check(state.resolve_node("region_complete"), "Open second campaign segment")

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
	check(state.claim_prospector_boulder("prospector_event", 2).is_empty(), "Prospector event cannot be claimed twice")

func _test_second_segment_from_existing_end() -> void:
	var save := {
		"version":2,
		"run_seed":777,
		"current_node":"region_complete",
		"resolved_nodes":["start","choice_left","battle_1","campfire_1","gate_1","choice_2_left","prospector_event","battle_2","campfire_2","boss_1","region_complete"],
		"claimed_rewards":[],
		"deck_ids":["armino","lobo","rana_toro"],
		"victories":2,
		"defeats":0,
		"started_at_unix":1
	}
	var state := Campaign.new()
	check(state.load_from_dict(save), "Existing save on old end screen still loads")
	check(state.can_enter("sigil_stones"), "Old end screen now opens Mystery Stones")
	check(state.can_enter("mycologists"), "Old end screen now opens Mycologists")

func _test_sigil_transfer() -> void:
	var state := Campaign.new()
	state.current_node = "region_complete"
	state.resolved_nodes.append("region_complete")
	state.deck_ids = ["gorrion", "lobo", "rana_toro"]
	check(state.transfer_sigils("sigil_stones", "gorrion", "lobo"), "Mystery Stones transfer a sigil")
	check(not state.deck_ids.has("gorrion"), "Donor card is destroyed")
	check(state.get_card_sigils("lobo").has("AIRBORNE"), "Receiver keeps transferred Airborne sigil")
	check(state.can_enter("trial_event"), "Sigil transfer resolves into deck trial")

	var battle := Battle.new()
	battle.setup(state.deck_ids, state.card_buffs, "battle_3", state.card_sigils)
	check(Array(battle.card_for_id("lobo").get("sigils", [])).has("AIRBORNE"), "Transferred sigil is active in battle")

	var reload := Campaign.new()
	check(reload.load_from_dict(state.to_dict()), "Transferred sigils survive save reload")
	check(reload.get_card_sigils("lobo").has("AIRBORNE"), "Transferred sigil persists")

func _test_mycologists() -> void:
	var state := Campaign.new()
	state.current_node = "region_complete"
	state.resolved_nodes.append("region_complete")
	state.deck_ids = ["lobo", "lobo", "rana_toro"]
	check(state.mycologist_candidates().has("lobo"), "Duplicate Wolf is offered to Mycologists")
	check(state.fuse_duplicate("mycologists", "lobo"), "Mycologists fuse duplicate cards")
	check(state.deck_ids.count("lobo") == 1, "Two copies become one")
	var buff := state.get_card_buff("lobo")
	check(int(buff.get("atk", 0)) == 3, "Fusion adds base attack")
	check(int(buff.get("hp", 0)) == 2, "Fusion adds base health")
	check(state.can_enter("trial_event"), "Mycologist fusion resolves into deck trial")

func _test_deck_trial() -> void:
	var state := Campaign.new()
	state.current_node = "sigil_stones"
	state.resolved_nodes.append("sigil_stones")
	state.deck_ids = ["urayuli", "urayuli", "urayuli"]
	var result: Dictionary = state.begin_trial("trial_event", "power")
	check(not result.is_empty(), "Deck trial starts")
	check(bool(result.get("passed", false)), "Three Urayuli pass power trial")
	check(Array(result.get("cards", [])).size() == 3, "Deck trial reveals three cards")
	var rewards: Array = Array(result.get("rewards", []))
	check(not rewards.is_empty(), "Successful trial creates rare rewards")
	if not rewards.is_empty():
		check(state.claim_trial_reward("trial_event", str(rewards[0])), "Rare reward can be claimed")
		check(state.can_enter("battle_3"), "Claiming reward opens third battle")

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
