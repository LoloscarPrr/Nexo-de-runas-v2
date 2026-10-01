class_name CpuActionPolicy
extends RefCounted

const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

## Selecciona una acción legal sin ejecutar reglas.
## La ejecución sigue perteneciendo a CanonicalCpuBattle y a los resolvers compartidos.
static func choose_action(battle) -> Dictionary:
	var best_action: Dictionary = {}
	var best_cost := -1
	for hand_index in range(battle.cpu_hand.size()):
		var card_id := str(battle.cpu_hand[hand_index])
		var card := Catalog.find_by_id(card_id)
		if card.is_empty():
			continue
		var actions: Array = battle.cpu_legal_actions_for_card(hand_index)
		if actions.is_empty():
			continue
		var cost := int(card.get("cost", 0))
		if cost < best_cost:
			continue
		best_cost = cost
		best_action = Dictionary(actions[0]).duplicate(true)
		best_action["hand_index"] = hand_index
	return best_action
