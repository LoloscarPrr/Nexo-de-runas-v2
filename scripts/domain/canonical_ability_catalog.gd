class_name CanonicalAbilityCatalog
extends RefCounted

const AbilityDefinitionScript = preload("res://scripts/domain/definitions/ability_definition.gd")

const ABILITIES = [
	{
		"id":"forest_watchful_squirrel",
		"trigger":"on_play",
		"conditions":[{"type":"other_ally_has_tag","params":{"tag":"BESTIA"}}],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"gain_essence","params":{"amount":1}}]
	},
	{
		"id":"forest_call_pack",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"first_free_player_lane","required":true},
		"effects":[
			{"type":"summon_token","params":{"id":"cria_del_bosque","name":"CRÍA DEL BOSQUE","attack":1,"health":1,"tags":["BESTIA"]}},
			{"type":"gain_essence","params":{"amount":1}}
		]
	},
	{
		"id":"forest_growth",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"player_unit","required":true},
		"effects":[{"type":"modify_stats","params":{"side":"player","attack":2,"health":2,"temporary":true}}]
	},
	{
		"id":"crypt_broken_skeleton",
		"trigger":"on_death",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"gain_essence","params":{"amount":1}}]
	},
	{
		"id":"crypt_gravedigger",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"gain_essence","params":{"amount":1}}]
	},
	{
		"id":"crypt_funeral_hound",
		"trigger":"on_death",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"damage_unit","params":{"side":"enemy","lane_mode":"source","amount":1,"optional":true}}]
	},
	{
		"id":"crypt_mourner",
		"trigger":"on_death",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"draw_card","params":{"amount":1}}]
	},
	{
		"id":"crypt_ash_offering",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"player_unit","required":true},
		"effects":[
			{"type":"kill_unit","params":{"side":"player"}},
			{"type":"draw_card","params":{"amount":2}}
		]
	},
	{
		"id":"crypt_exhumation",
		"trigger":"on_play",
		"conditions":[{"type":"discard_has_creature_max_cost","params":{"max_cost":3}}],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"return_creature_from_discard","params":{"max_cost":3}}]
	},
	{
		"id":"tower_familiar",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"reveal_top","params":{"amount":1,"draw":0}}]
	},
	{
		"id":"tower_rune_bolt",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"enemy_unit","required":true},
		"effects":[{"type":"damage_unit","params":{"side":"enemy","lane_mode":"target","amount":1}}]
	},
	{
		"id":"tower_forbidden_vision",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"reveal_top","params":{"amount":3,"draw":1}}]
	},
	{
		"id":"forge_worker",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"none","required":false},
		"effects":[{"type":"gain_essence","params":{"amount":1}}]
	},
	{
		"id":"forge_spark",
		"trigger":"on_play",
		"conditions":[],
		"target":{"kind":"enemy_unit","required":true},
		"effects":[
			{"type":"damage_unit","params":{"side":"enemy","lane_mode":"target","amount":1}},
			{"type":"gain_essence","params":{"amount":1}}
		]
	},
	{
		"id":"forge_overload",
		"trigger":"on_play",
		"conditions":[{"type":"target_has_tag","params":{"tag":"CONSTRUCTO"}}],
		"target":{"kind":"player_unit","required":true},
		"effects":[
			{"type":"modify_stats","params":{"side":"player","attack":3,"health":0,"temporary":true}},
			{"type":"gain_essence","params":{"amount":2}}
		]
	}
]

static func find_by_id(ability_id: String):
	if ability_id.is_empty():
		return null
	for data in ABILITIES:
		if str(data.get("id", "")) == ability_id:
			return AbilityDefinitionScript.from_dictionary(data)
	return null

static func for_card(card: Dictionary):
	return find_by_id(str(card.get("effect_id", "")))

static func has_for_card(card: Dictionary) -> bool:
	return for_card(card) != null

static func all_ids() -> Array[String]:
	var ids: Array[String] = []
	for data in ABILITIES:
		ids.append(str(data.get("id", "")))
	return ids

static func validate_catalog() -> Array[String]:
	var errors: Array[String] = []
	var seen: Dictionary = {}
	for data in ABILITIES:
		var ability = AbilityDefinitionScript.from_dictionary(data)
		if seen.has(ability.id):
			errors.append("Ability id duplicado: %s" % ability.id)
		seen[ability.id] = true
		for error in ability.validate():
			errors.append("%s: %s" % [ability.id, error])
	return errors
