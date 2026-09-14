class_name CampaignCore
extends RefCounted
## First expedition rules fixture, not a complete Act 1 implementation.
## UI submits commands; this domain owns all progression and combat.

const VERSION := 1
const CARDS := {
	"squirrel": {"name": "Ardilla", "attack": 0, "health": 1, "blood": 0},
	"stoat": {"name": "Armiño", "attack": 1, "health": 3, "blood": 1},
	"wolf": {"name": "Lobo", "attack": 3, "health": 2, "blood": 2},
	"adder": {"name": "Víbora", "attack": 1, "health": 1, "blood": 2}
}
const ROUTES := {"start": ["choice_left", "choice_right"],
	"choice_left": ["battle"], "choice_right": ["battle"], "battle": ["reward"],
	"reward": ["finish"], "finish": []}
const OFFERS := {"choice_left": ["wolf", "stoat"],
	"choice_right": ["adder", "wolf"], "reward": ["wolf", "stoat", "adder"]}

var node := "start"
var phase := "map"
var deck: Array = ["stoat", "wolf", "stoat"]
var hand: Array = []
var draw_pile: Array = []
var player: Array = [{}, {}, {}, {}]
var enemy: Array = [{}, {}, {}, {}]
var balance := 0
var bones := 0
var turn := 0
var log: Array = []

func apply(command: Dictionary) -> bool:
	if log.size() >= 2000:
		return false
	var ok := false
	match command.get("action", ""):
		"travel":
			ok = _travel(str(command.get("target", "")))
		"choose":
			ok = _choose(str(command.get("card", "")))
		"draw":
			ok = _draw(str(command.get("source", "")))
		"play":
			if command.get("slot") is int and command.get("hand") is int and command.get("sacrifices", []) is Array:
				ok = _play(command.hand, command.slot, command.get("sacrifices", []))
		"end_turn":
			ok = _end_turn()
	if ok:
		log.append(command.duplicate(true))
	return ok

func available_routes() -> Array:
	if phase != "map":
		return []
	return ROUTES[node].duplicate()

func offers() -> Array:
	if phase != "choice":
		return []
	return OFFERS[node].duplicate()

func _travel(target: String) -> bool:
	if not available_routes().has(target):
		return false
	node = target
	if OFFERS.has(node):
		phase = "choice"
	elif node == "battle":
		_start_battle()
	elif node == "finish":
		phase = "complete"
	return true

func _choose(card: String) -> bool:
	if not offers().has(card):
		return false
	deck.append(card)
	phase = "map"
	return true

func _start_battle() -> void:
	phase = "play"
	balance = 0
	bones = 0
	turn = 0
	player = [{}, {}, {}, {}]
	enemy = [{}, {}, {}, {}]
	draw_pile = deck.duplicate()
	hand = ["squirrel"]
	for i in range(mini(3, draw_pile.size())):
		hand.append(draw_pile.pop_front())
	enemy[0] = _unit("stoat")

func _unit(card: String) -> Dictionary:
	var unit: Dictionary = CARDS[card].duplicate(true)
	unit["id"] = card
	return unit

func _draw(source: String) -> bool:
	if phase != "draw":
		return false
	if source == "squirrel":
		hand.append("squirrel")
	elif source == "deck" and not draw_pile.is_empty():
		hand.append(draw_pile.pop_front())
	else:
		return false
	phase = "play"
	return true

func _play(hand_index: int, slot: int, sacrifices: Array) -> bool:
	if phase != "play" or slot < 0 or slot >= 4 or hand_index < 0 or hand_index >= hand.size():
		return false
	var seen: Array = []
	for value in sacrifices:
		if not value is int or value < 0 or value >= 4 or seen.has(value):
			return false
		if player[value].is_empty():
			return false
		seen.append(value)
	var card: String = hand[hand_index]
	var cost: int = CARDS[card].blood
	if seen.size() != cost:
		return false
	if not player[slot].is_empty() and not seen.has(slot):
		return false
	for sacrificed in seen:
		player[sacrificed] = {}
		bones += 1
	player[slot] = _unit(card)
	hand.remove_at(hand_index)
	return true

func _strike(attackers: Array, defenders: Array, direction: int) -> void:
	for lane in range(4):
		if attackers[lane].is_empty():
			continue
		var damage: int = attackers[lane].attack
		if defenders[lane].is_empty():
			balance += direction * damage
		else:
			defenders[lane].health -= damage
			if defenders[lane].health <= 0:
				defenders[lane] = {}
				if direction < 0:
					bones += 1
		if absi(balance) >= 5:
			return

func _end_turn() -> bool:
	if phase != "play":
		return false
	_strike(player, enemy, 1)
	if balance >= 5:
		phase = "map"
		return true
	_strike(enemy, player, -1)
	if balance <= -5:
		phase = "defeat"
		return true
	turn += 1
	# Fixed encounter fixture: deterministic arrivals, no hidden random state.
	if turn <= 3:
		for lane in range(4):
			if enemy[lane].is_empty():
				enemy[lane] = _unit("stoat")
				break
	phase = "draw"
	return true

func snapshot() -> Dictionary:
	return {"version": VERSION, "commands": log.duplicate(true)}

static func restore(data: Variant) -> CampaignCore:
	if not data is Dictionary or data.get("version") != VERSION:
		return null
	if not data.get("commands") is Array or data.commands.size() > 2000:
		return null
	var result := CampaignCore.new()
	for raw in data.commands:
		if not raw is Dictionary:
			return null
		var command: Dictionary = raw.duplicate(true)
		# JSON decodes numbers as floats; normalize only exact integer fields.
		for field in ["slot", "hand"]:
			if command.has(field):
				if not (command[field] is int or command[field] is float):
					return null
				if command[field] != int(command[field]):
					return null
				command[field] = int(command[field])
		if command.has("sacrifices"):
			if not command.sacrifices is Array:
				return null
			for i in range(command.sacrifices.size()):
				var value: Variant = command.sacrifices[i]
				if not (value is int or value is float) or value != int(value):
					return null
				command.sacrifices[i] = int(value)
		if not result.apply(command):
			return null
	return result
