class_name CardCatalog
extends RefCounted

const CARDS := [
	{"id":"lobo","name":"LOBO","style":"Bestias","resource":"blood","cost_value":2,"cost":"2 SANGRE","atk":3,"hp":2,"seal":"FEROCIDAD","glyph":"◢"},
	{"id":"alce","name":"ALCE","style":"Bestias","resource":"blood","cost_value":3,"cost":"3 SANGRE","atk":3,"hp":5,"seal":"CORREDOR","glyph":"♞"},
	{"id":"cuervo","name":"CUERVO","style":"Bestias","resource":"blood","cost_value":2,"cost":"2 SANGRE","atk":2,"hp":3,"seal":"AÉREO","glyph":"◆"},
	{"id":"esqueleto","name":"ESQUELETO","style":"No-muertos","resource":"bones","cost_value":1,"cost":"1 HUESO","atk":1,"hp":1,"seal":"FRÁGIL","glyph":"☠"},
	{"id":"sepulturero","name":"SEPULTURERO","style":"No-muertos","resource":"bones","cost_value":2,"cost":"2 HUESOS","atk":0,"hp":3,"seal":"EXHUMAR","glyph":"✚"},
	{"id":"zombi","name":"ZOMBI","style":"No-muertos","resource":"bones","cost_value":5,"cost":"5 HUESOS","atk":2,"hp":2,"seal":"TENAZ","glyph":"☩"},
	{"id":"automata","name":"AUTÓMATA","style":"Tecnología","resource":"energy","cost_value":3,"cost":"3 ENERGÍA","atk":1,"hp":2,"seal":"CONDUCTOR","glyph":"▣"},
	{"id":"francotirador","name":"BOT TIRADOR","style":"Tecnología","resource":"energy","cost_value":4,"cost":"4 ENERGÍA","atk":2,"hp":1,"seal":"APUNTAR","glyph":"⌖"},
	{"id":"conducto","name":"CONDUCTO","style":"Tecnología","resource":"energy","cost_value":2,"cost":"2 ENERGÍA","atk":0,"hp":3,"seal":"CIRCUITO","glyph":"⌁"},
	{"id":"mox_rubi","name":"MOX RUBÍ","style":"Magia","resource":"none","cost_value":0,"cost":"NINGUNO","atk":0,"hp":1,"seal":"RUBÍ","glyph":"♦"},
	{"id":"aprendiz","name":"APRENDIZ","style":"Magia","resource":"runes","cost_value":1,"cost":"1 RUNA","atk":1,"hp":2,"seal":"HECHIZO","glyph":"✦"},
	{"id":"guardian","name":"GUARDIÁN MOX","style":"Magia","resource":"runes","cost_value":2,"cost":"2 RUNAS","atk":2,"hp":3,"seal":"GUARDIA","glyph":"⬡"}
]

static func find_by_id(card_id: String) -> Dictionary:
	for card in CARDS:
		if card.id == card_id:
			return card.duplicate(true)
	return {}

static func campaign_reward_pool() -> Array[String]:
	return ["esqueleto", "sepulturero", "automata", "francotirador", "conducto", "mox_rubi"]
