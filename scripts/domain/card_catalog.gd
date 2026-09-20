class_name CardCatalog
extends RefCounted

## Catálogo activo de la reconstrucción Acto 1.
## El flujo principal usa únicamente Sangre, Huesos y cartas sin coste.
const CARDS := [
	{"id":"ardilla","name":"ARDILLA","resource":"none","cost_value":0,"cost":"SIN COSTE","atk":0,"hp":1,"seal":"SACRIFICIO","glyph":"S"},
	{"id":"armino","name":"ARMIÑO","resource":"blood","cost_value":1,"cost":"1 SANGRE","atk":1,"hp":3,"seal":"NINGUNO","glyph":"A"},
	{"id":"lobo","name":"LOBO","resource":"blood","cost_value":2,"cost":"2 SANGRE","atk":3,"hp":2,"seal":"NINGUNO","glyph":"L"},
	{"id":"rana_toro","name":"RANA TORO","resource":"blood","cost_value":1,"cost":"1 SANGRE","atk":1,"hp":2,"seal":"SALTO PODEROSO","glyph":"R"},
	{"id":"gorrion","name":"GORRIÓN","resource":"blood","cost_value":1,"cost":"1 SANGRE","atk":1,"hp":2,"seal":"AÉREO","glyph":"G"},
	{"id":"vibora","name":"VÍBORA","resource":"blood","cost_value":2,"cost":"2 SANGRE","atk":1,"hp":1,"seal":"TOQUE MORTAL","glyph":"V"},
	{"id":"puercoespin","name":"PUERCOESPÍN","resource":"blood","cost_value":1,"cost":"1 SANGRE","atk":1,"hp":2,"seal":"ESPINAS","glyph":"P"},
	{"id":"topo","name":"TOPO","resource":"blood","cost_value":1,"cost":"1 SANGRE","atk":0,"hp":4,"seal":"MADRIGUERA","glyph":"T"},
	{"id":"alce","name":"ALCE","resource":"blood","cost_value":3,"cost":"3 SANGRE","atk":3,"hp":7,"seal":"CORREDOR","glyph":"M"},
	{"id":"zarigueya","name":"ZARIGÜEYA","resource":"bones","cost_value":2,"cost":"2 HUESOS","atk":1,"hp":1,"seal":"NINGUNO","glyph":"Z"},
	{"id":"coyote","name":"COYOTE","resource":"bones","cost_value":4,"cost":"4 HUESOS","atk":2,"hp":1,"seal":"NINGUNO","glyph":"C"},
	{"id":"buitre","name":"BUITRE PAVO","resource":"bones","cost_value":8,"cost":"8 HUESOS","atk":3,"hp":3,"seal":"AÉREO","glyph":"B"}
]

static func find_by_id(card_id: String) -> Dictionary:
	for card in CARDS:
		if card.id == card_id:
			return card.duplicate(true)
	return {}

static func campaign_reward_pool() -> Array[String]:
	return ["rana_toro", "gorrion", "vibora", "puercoespin", "topo", "zarigueya", "coyote", "alce"]
