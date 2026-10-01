class_name TargetSpec
extends RefCounted

const NONE := "none"
const PLAYER_UNIT := "player_unit"
const ENEMY_UNIT := "enemy_unit"
const FIRST_FREE_PLAYER_LANE := "first_free_player_lane"

var kind := NONE
var required := false

static func create(kind_value: String = NONE, required_value: bool = false):
	var spec := TargetSpec.new()
	spec.kind = kind_value
	spec.required = required_value
	return spec

static func from_dictionary(data: Dictionary):
	return create(str(data.get("kind", NONE)), bool(data.get("required", false)))

func uses_selected_lane() -> bool:
	return kind == PLAYER_UNIT or kind == ENEMY_UNIT

func target_side() -> String:
	match kind:
		PLAYER_UNIT, FIRST_FREE_PLAYER_LANE:
			return "player"
		ENEMY_UNIT:
			return "enemy"
		_:
			return ""

func to_dict() -> Dictionary:
	return {
		"kind": kind,
		"required": required
	}
