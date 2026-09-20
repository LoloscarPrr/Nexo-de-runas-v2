class_name CampaignState
extends RefCounted

# Se conserva la versión 2 para que las partidas de las builds anteriores
# carguen sin reiniciar la campaña. Los campos nuevos son opcionales.
const SAVE_VERSION := 2
const STARTER_DECK := ["armino", "lobo", "rana_toro"]

const MAP_NODES := {
	"start": {"title":"LA SENDA", "type":"start", "next":["choice_left", "choice_right"]},
	"choice_left": {"title":"ELECCIÓN DE BESTIA", "type":"choice", "next":["battle_1"]},
	"choice_right": {"title":"ELECCIÓN DE COSTE", "type":"choice", "next":["battle_1"]},
	"battle_1": {"title":"COMBATE DEL BOSQUE", "type":"battle", "next":["campfire_1"]},
	"campfire_1": {"title":"FOGATA I", "type":"campfire", "next":["gate_1"]},
	"gate_1": {"title":"UMBRAL DEL BOSQUE", "type":"gate", "next":["choice_2_left", "choice_2_right"]},
	"choice_2_left": {"title":"RASTRO DE BESTIA", "type":"choice", "next":["battle_2"]},
	"choice_2_right": {"title":"RASTRO DE SANGRE", "type":"choice", "next":["battle_2"]},
	"battle_2": {"title":"COMBATE PROFUNDO", "type":"battle", "next":["campfire_2"]},
	"campfire_2": {"title":"FOGATA II", "type":"campfire", "next":["boss_1"]},
	"boss_1": {"title":"GUARDIÁN DEL BOSQUE", "type":"boss", "next":["region_complete"]},
	"region_complete": {"title":"SENDERO SIGUIENTE", "type":"end", "next":[]}
}

var version := SAVE_VERSION
var run_seed := 0
var current_node := "start"
var resolved_nodes: Array[String] = ["start"]
var claimed_rewards: Array[String] = []
var deck_ids: Array[String] = []
var card_buffs: Dictionary = {}
var victories := 0
var defeats := 0
var started_at_unix := 0

func _init() -> void:
	reset()

func reset() -> void:
	version = SAVE_VERSION
	run_seed = int(Time.get_unix_time_from_system())
	current_node = "start"
	resolved_nodes = ["start"]
	claimed_rewards = []
	deck_ids = []
	card_buffs = {}
	for card_id in STARTER_DECK:
		deck_ids.append(card_id)
	victories = 0
	defeats = 0
	started_at_unix = int(Time.get_unix_time_from_system())

func get_node(node_id: String) -> Dictionary:
	if MAP_NODES.has(node_id):
		return MAP_NODES[node_id]
	return {}

func available_nodes() -> Array[String]:
	var result: Array[String] = []
	var node := get_node(current_node)
	if node.is_empty():
		return result
	for node_id in node.get("next", []):
		result.append(str(node_id))
	return result

func can_enter(node_id: String) -> bool:
	return available_nodes().has(node_id)

func resolve_node(node_id: String) -> bool:
	if node_id == current_node:
		return true
	if not can_enter(node_id):
		return false
	if not resolved_nodes.has(node_id):
		resolved_nodes.append(node_id)
	current_node = node_id
	return true

func add_card(card_id: String) -> void:
	deck_ids.append(card_id)

func claim_reward(reward_key: String, card_id: String) -> bool:
	if claimed_rewards.has(reward_key):
		return false
	claimed_rewards.append(reward_key)
	add_card(card_id)
	return true

func get_card_buff(card_id: String) -> Dictionary:
	if not card_buffs.has(card_id):
		return {"atk":0, "hp":0}
	var buff = card_buffs[card_id]
	if buff is Dictionary:
		return {
			"atk": int(buff.get("atk", 0)),
			"hp": int(buff.get("hp", 0))
		}
	return {"atk":0, "hp":0}

func upgrade_card(card_id: String, stat: String) -> bool:
	if not deck_ids.has(card_id):
		return false
	var buff := get_card_buff(card_id)
	match stat:
		"atk":
			buff["atk"] = int(buff.get("atk", 0)) + 1
		"hp":
			buff["hp"] = int(buff.get("hp", 0)) + 2
		_:
			return false
	card_buffs[card_id] = buff
	return true

func to_dict() -> Dictionary:
	return {
		"version": version,
		"run_seed": run_seed,
		"current_node": current_node,
		"resolved_nodes": resolved_nodes,
		"claimed_rewards": claimed_rewards,
		"deck_ids": deck_ids,
		"card_buffs": card_buffs,
		"victories": victories,
		"defeats": defeats,
		"started_at_unix": started_at_unix
	}

func load_from_dict(data: Dictionary) -> bool:
	if int(data.get("version", -1)) != SAVE_VERSION:
		return false
	var loaded_node := str(data.get("current_node", "start"))
	if not MAP_NODES.has(loaded_node):
		return false
	version = SAVE_VERSION
	run_seed = int(data.get("run_seed", 0))
	current_node = loaded_node
	resolved_nodes = _string_array(data.get("resolved_nodes", ["start"]))
	claimed_rewards = _string_array(data.get("claimed_rewards", []))
	deck_ids = _string_array(data.get("deck_ids", STARTER_DECK))
	card_buffs = {}
	var loaded_buffs = data.get("card_buffs", {})
	if loaded_buffs is Dictionary:
		for card_id in loaded_buffs:
			var raw = loaded_buffs[card_id]
			if raw is Dictionary:
				card_buffs[str(card_id)] = {
					"atk": int(raw.get("atk", 0)),
					"hp": int(raw.get("hp", 0))
				}
	victories = int(data.get("victories", 0))
	defeats = int(data.get("defeats", 0))
	started_at_unix = int(data.get("started_at_unix", 0))
	if not resolved_nodes.has("start"):
		resolved_nodes.push_front("start")
	return true

func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			result.append(str(value))
	return result
