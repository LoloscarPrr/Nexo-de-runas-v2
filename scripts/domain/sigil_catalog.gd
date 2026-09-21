class_name SigilCatalog
extends RefCounted

const DATA := {
	"TOUCH_OF_DEATH":{"name":"TOQUE MORTAL","description":"La criatura que reciba daño de esta carta muere de inmediato."},
	"LEADER":{"name":"LÍDER","description":"Las criaturas adyacentes ganan +1 ATQ mientras este sello permanezca en mesa."},
	"AMORPHOUS":{"name":"AMORFO","description":"Al entrar a tu mano adopta un sello aleatorio para ese combate."},
	"ANT_SPAWNER":{"name":"GENERADOR DE HORMIGAS","description":"Al jugar esta carta, crea una Hormiga Obrera en tu mano."},
	"AIRBORNE":{"name":"AÉREO","description":"Ataca directamente al rival, ignorando la criatura opuesta salvo que tenga Salto Poderoso."},
	"DAM_BUILDER":{"name":"CONSTRUCTOR DE REPRESAS","description":"Al jugar esta carta crea Represas en los espacios adyacentes vacíos."},
	"BEES_WITHIN":{"name":"COLMENA","description":"Cuando esta carta recibe un golpe, crea una Abeja en tu mano."},
	"WORTHY_SACRIFICE":{"name":"SACRIFICIO DIGNO","description":"Al sacrificar esta carta aporta 3 puntos de Sangre en vez de 1."},
	"GUARDIAN":{"name":"GUARDIÁN","description":"Se mueve para bloquear una carta enemiga jugada frente a un espacio vacío."},
	"MIGHTY_LEAP":{"name":"SALTO PODEROSO","description":"Bloquea los ataques de criaturas con el sello Aéreo."},
	"MANY_LIVES":{"name":"MUCHAS VIDAS","description":"Puede ser sacrificada sin morir. Algunas cartas cambian tras varios sacrificios."},
	"UNKILLABLE":{"name":"INMORTAL","description":"Cuando muere, una copia vuelve a tu mano."},
	"CORPSE_EATER":{"name":"DEVORADOR DE CADÁVERES","description":"Si una criatura aliada muere en combate, esta carta salta desde tu mano a su espacio."},
	"SPRINTER":{"name":"CORREDOR","description":"Al terminar el turno se desplaza un espacio en la dirección de su sello."},
	"FLEDGLING":{"name":"CRÍA","description":"Si sobrevive un turno, evoluciona a una forma más fuerte."},
	"FECUNDITY":{"name":"FECUNDIDAD","description":"Al jugarla, crea una copia de sí misma en tu mano."},
	"FROZEN_AWAY":{"name":"CONGELADO","description":"Al morir deja en su lugar la criatura que estaba atrapada en su interior."},
	"BONE_KING":{"name":"REY DE HUESOS","description":"Cuando muere entrega 4 Huesos en vez de 1."},
	"WATERBORNE":{"name":"SUMERGIBLE","description":"Durante el turno rival se sumerge; el ataque enemigo pasa por encima y golpea directamente."},
	"STEEL_TRAP":{"name":"TRAMPA DE ACERO","description":"Al morir destruye también a la criatura opuesta y puede dejar un Pelaje de Lobo."},
	"HOARDER":{"name":"ACAPARADOR","description":"Al jugarla te permite buscar inmediatamente una carta de tu mazo."},
	"BIFURCATED_STRIKE":{"name":"GOLPE BIFURCADO","description":"Ataca los dos espacios diagonales en vez del espacio directamente opuesto."},
	"TRIFURCATED_STRIKE":{"name":"GOLPE TRIFURCADO","description":"Ataca a la izquierda, al frente y a la derecha."},
	"BURROWER":{"name":"MADRIGUERA","description":"Se mueve hasta un espacio vacío que vaya a ser atacado para bloquear el golpe."},
	"HEFTY":{"name":"PESADO","description":"Al terminar el turno avanza y empuja a las criaturas aliadas que tenga delante."},
	"TRINKET_BEARER":{"name":"PORTADOR DE OBJETO","description":"Al jugarla entrega un objeto consumible si tienes espacio disponible."},
	"SHARP_QUILLS":{"name":"ESPINAS","description":"Cuando recibe un golpe, inflige 1 de daño a la criatura atacante."},
	"RABBIT_HOLE":{"name":"MADRIGUERA DE CONEJOS","description":"Al jugarla crea un Conejo en tu mano."},
	"STINKY":{"name":"HEDOR","description":"La criatura que esté enfrente pierde 1 ATQ mientras este sello siga activo."},
	"LOOSE_TAIL":{"name":"COLA SUELTA","description":"La primera vez que vaya a ser golpeada se mueve y deja una cola ocupando su lugar."},
	"BELLIST":{"name":"CAMPANERO","description":"Al jugarla crea Campanillas en los espacios adyacentes vacíos."},
	"REPULSIVE":{"name":"REPULSIVO","description":"Las criaturas enemigas se niegan a atacar esta carta."},
	"STAT_ANTS":{"name":"PODER DE HORMIGAS","description":"Su ATQ es igual al número de Hormigas aliadas que tengas en la mesa."},
	"STAT_BELL":{"name":"PODER DE CAMPANA","description":"Su ATQ cambia según la distancia entre esta carta y la campana."},
	"STAT_CARDS_IN_HAND":{"name":"PODER DE LA MANO","description":"Su ATQ es igual a la cantidad de cartas que tengas en la mano."},
	"STAT_MIRROR":{"name":"PODER ESPEJO","description":"Copia el ATQ de la criatura que tenga directamente enfrente."}
}

static func get_info(code: String) -> Dictionary:
	if DATA.has(code):
		return DATA[code]
	return {"name":code.replace("_", " "), "description":"Sello especial."}

static func name_for(code: String) -> String:
	return str(get_info(code).get("name", code))

static func description_for(code: String) -> String:
	return str(get_info(code).get("description", ""))

static func codes_for_card(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for code in Array(card.get("sigils", [])):
		result.append(str(code))
	var stat := str(card.get("special_stat", "NONE"))
	if stat != "NONE":
		result.append("STAT_" + stat)
	return result

static func summary_for_card(card: Dictionary) -> String:
	var codes := codes_for_card(card)
	if codes.is_empty():
		return "SIN SELLO · Esta carta no posee una habilidad especial."
	var parts: Array[String] = []
	for code in codes:
		var info := get_info(code)
		parts.append("%s — %s" % [str(info.get("name", code)), str(info.get("description", ""))])
	return "\n".join(parts)
