class_name BattleSidePayer
extends RefCounted

var battle
var side := "player"

func _init(battle_value, side_value: String) -> void:
	battle = battle_value
	side = side_value

func resource_amount(resource_type: String) -> int:
	if battle == null:
		return 0
	return int(battle.resource_amount_for_side(side, resource_type))

func spend_resource(resource_type: String, amount: int) -> bool:
	if battle == null:
		return false
	return bool(battle.spend_resource_for_side(side, resource_type, amount))
