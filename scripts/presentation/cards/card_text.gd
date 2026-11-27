class_name CardText
extends RefCounted

## Display copy for the current Forest definitions/effect contracts.
## This never grants abilities or changes battle data.
const LEGACY_EFFECTS := {
	"forest_watchful_squirrel": "Si controlas otra Bestia, ganas 1 Instinto.",
	"forest_call_pack": "Invoca una Cría del Bosque 1/1 y ganas 1 Instinto.",
	"forest_growth": "Una criatura aliada obtiene +2/+2 este turno.",
	"crypt_gravedigger": "Al entrar, ganas 1 Resto.",
	"crypt_broken_skeleton": "Último Aliento: ganas 1 Resto.",
	"crypt_funeral_hound": "Último Aliento: inflige 1 daño a la criatura enfrentada.",
	"crypt_mourner": "Último Aliento: roba 1 carta.",
	"crypt_ash_offering": "Destruye una criatura aliada. Roba 2 cartas.",
	"crypt_exhumation": "Devuelve una criatura de coste 3 o menos desde tu descarte.",
	"tower_familiar": "Al entrar, revela la carta superior de tu mazo.",
	"tower_rune_bolt": "Inflige 1 daño a una criatura enemiga.",
	"tower_forbidden_vision": "Revela las 3 cartas superiores y roba la primera.",
	"forge_worker": "Al entrar, ganas 1 Calor.",
	"forge_spark": "Inflige 1 daño y ganas 1 Calor.",
	"forge_overload": "Un Constructo aliado obtiene +3 ATQ y ganas 2 Calor."
}
const TYPES := {"creature": "Criatura", "rite": "Rito", "relic": "Reliquia", "seal": "Sello"}
const RARITIES := {"common": "Común", "uncommon": "Poco común", "rare": "Rara", "legendary": "Legendaria"}
const FOREST_EFFECTS := {
	"forest_clearing_sprout": "Al entrar, si tiene un aliado adyacente, obtiene +0/+1.",
	"forest_rune_squirrel": "Último Aliento: restaura 1 de Integridad a tu Nexo.",
	"forest_young_wolf_foundational": "Al atacar, obtiene +1 ATQ este turno.",
	"forest_guard_deer": "Al entrar, cura 1 a otra criatura aliada.",
	"forest_pack_wolf": "Al entrar, si tiene un aliado adyacente, obtiene +1/+1.",
	"forest_oak_shaman": "Al inicio de tu turno, cura 1 a la primera criatura aliada dañada.",
	"forest_canopy_stalker": "Al entrar, puedes mover a una criatura aliada adyacente un carril hacia un espacio libre.",
	"forest_ancient_roots": "Tus criaturas adyacentes tienen +0/+1 mientras este Anciano permanezca en el tablero.",
	"forest_green_moon_alpha": "Al atacar, sus aliados adyacentes obtienen +1 ATQ este turno.",
	"forest_avatar": "Al entrar, cura 2 a tus criaturas y restaura 2 de Integridad a tu Nexo.",
	"forest_vital_sap": "Una criatura aliada obtiene +0/+2.",
	"forest_sudden_growth": "Una criatura aliada obtiene +1/+1. Si estaba dañada, también cura 1.",
	"forest_call_foundational": "Invoca un Brote 1/1 en un carril aliado vacío. El Brote tiene +1 ATQ mientras tenga un aliado adyacente.",
	"forest_invasive_roots": "Inflige 2 de daño a una criatura enemiga y la Enraíza hasta el inicio de tu próximo turno.",
	"forest_clearing_roar": "Tus criaturas obtienen +1 ATQ este turno.",
	"forest_sap_totem": "La primera vez que cures a una criatura aliada en cada turno, restaura 1 de Integridad a tu Nexo.",
	"forest_pack_sanctuary": "La primera criatura que invoques en cada turno obtiene +1/+1 si tiene un aliado adyacente."
}

static func type_label(card: Dictionary) -> String:
	return str(TYPES.get(str(card.get("type", "")), "Carta"))

static func metadata(card: Dictionary) -> String:
	var value := "%s · %s · %s" % [card.get("set_id", ""), type_label(card), RARITIES.get(str(card.get("rarity", "")), "")]
	if bool(card.get("unique", false)):
		value += " · Única"
	return value

static func rules_text(card: Dictionary) -> String:
	var effect_id := str(card.get("effect_id", ""))
	var effect := str(FOREST_EFFECTS.get(effect_id, LEGACY_EFFECTS.get(effect_id, "")))
	var keywords: Array[String] = []
	for keyword in Array(card.get("keywords", [])):
		if str(keyword) == "ENRAIZADO":
			keywords.append("Enraizado: no puede moverse ni ser desplazado.")
		else:
			keywords.append(str(keyword).replace("_", " ").capitalize())
	if not keywords.is_empty():
		effect = " ".join(keywords) + ("\n" + effect if not effect.is_empty() else "")
	return "Sin habilidad adicional." if effect.is_empty() and effect_id.is_empty() else effect
