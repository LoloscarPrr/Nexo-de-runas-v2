class_name CanonicalCollection
extends RefCounted

## Read-only catalog queries. Catalog membership does not imply ownership,
## discovery or an unlocked card in campaign/progression.
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

static func cards_for_domain(domain: String, query: String = "", card_type: String = "", cost: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var search := normalized_query(query.strip_edges())
	for card in Catalog.cards_for_domain(domain):
		if not card_type.is_empty() and str(card.get("type", "")) != card_type:
			continue
		if cost >= 0 and int(card.get("cost", -1)) != cost:
			continue
		var searchable := normalized_query("%s %s" % [card.get("name", ""), card.get("set_id", "")])
		if not search.is_empty() and not searchable.contains(search):
			continue
		result.append(card)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("set_id", "")) < str(b.get("set_id", "")))
	return result

static func normalized_query(value: String) -> String:
	var result := value.to_lower()
	for pair in [["á", "a"], ["é", "e"], ["í", "i"], ["ó", "o"], ["ú", "u"], ["ü", "u"]]:
		result = result.replace(pair[0], pair[1])
	return result
