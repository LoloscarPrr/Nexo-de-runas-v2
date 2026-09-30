class_name CardDefinition
extends RefCounted

## Plantilla canónica de una carta.
## Se trata como inmutable durante una batalla; el estado mutable vive en CardInstance.

var id := ""
var display_name := ""
var domain := ""
var card_type := ""
var base_attack := 0
var base_health := 0
var cost_resource := "energy"
var cost_amount := 0
var keywords: Array[String] = []
var tags: Array[String] = []
var ability_ids: Array[String] = []
var unique := false

static func from_dictionary(data: Dictionary):
	var definition := CardDefinition.new()
	definition.id = str(data.get("id", ""))
	definition.display_name = str(data.get("name", definition.id))
	definition.domain = str(data.get("domain", ""))
	definition.card_type = str(data.get("type", ""))
	definition.base_attack = int(data.get("attack", data.get("atk", 0)))
	definition.base_health = int(data.get("health", data.get("hp", 0)))
	definition.cost_resource = str(data.get("resource", "energy"))
	definition.cost_amount = int(data.get("cost", data.get("cost_value", 0)))
	for keyword in Array(data.get("keywords", [])):
		definition.keywords.append(str(keyword))
	for tag in Array(data.get("tags", data.get("tribes", []))):
		definition.tags.append(str(tag))
	for ability in Array(data.get("abilities", data.get("special_abilities", []))):
		definition.ability_ids.append(str(ability))
	var effect_id := str(data.get("effect_id", ""))
	if not effect_id.is_empty() and not definition.ability_ids.has(effect_id):
		definition.ability_ids.append(effect_id)
	definition.unique = bool(data.get("unique", false))
	return definition

func validate() -> Array[String]:
	var errors: Array[String] = []
	if id.is_empty():
		errors.append("CardDefinition requiere id.")
	if display_name.is_empty():
		errors.append("CardDefinition requiere nombre.")
	if card_type.is_empty():
		errors.append("CardDefinition requiere tipo.")
	if cost_amount < 0:
		errors.append("El coste no puede ser negativo.")
	if base_health < 0:
		errors.append("La salud base no puede ser negativa.")
	return errors

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": display_name,
		"domain": domain,
		"type": card_type,
		"attack": base_attack,
		"health": base_health,
		"cost_resource": cost_resource,
		"cost_amount": cost_amount,
		"keywords": keywords.duplicate(),
		"tags": tags.duplicate(),
		"ability_ids": ability_ids.duplicate(),
		"unique": unique
	}
