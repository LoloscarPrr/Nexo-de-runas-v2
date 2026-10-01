class_name EffectDefinition
extends RefCounted

const GAIN_ESSENCE := "gain_essence"
const DRAW_CARD := "draw_card"
const DAMAGE_UNIT := "damage_unit"
const MODIFY_STATS := "modify_stats"
const KILL_UNIT := "kill_unit"
const SUMMON_TOKEN := "summon_token"
const REVEAL_TOP := "reveal_top"

var effect_type := ""
var params: Dictionary = {}

static func create(type_value: String, params_value: Dictionary = {}):
	var effect := EffectDefinition.new()
	effect.effect_type = type_value
	effect.params = params_value.duplicate(true)
	return effect

static func from_dictionary(data: Dictionary):
	var raw_params = data.get("params", {})
	return create(
		str(data.get("type", "")),
		raw_params if raw_params is Dictionary else {}
	)

func validate() -> Array[String]:
	var errors: Array[String] = []
	if effect_type.is_empty():
		errors.append("EffectDefinition requiere type.")
	return errors

func to_dict() -> Dictionary:
	return {
		"type": effect_type,
		"params": params.duplicate(true)
	}
