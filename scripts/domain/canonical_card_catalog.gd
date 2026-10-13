class_name CanonicalCardCatalog
extends RefCounted

const DOMAIN_FOREST := "forest"
const DOMAIN_CRYPT := "crypt"
const DOMAIN_TOWER := "tower"
const DOMAIN_FORGE := "forge"

const TYPE_CREATURE := "creature"
const TYPE_RITE := "rite"
const TYPE_RELIC := "relic"
const TYPE_SEAL := "seal"

const CARDS = [
	# Bosque Salvaje
	{"id":"ardilla_vigilante","name":"ARDILLA VIGILANTE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":1,"attack":0,"health":2,"keywords":[],"tags":["BESTIA"],"effect_id":"forest_watchful_squirrel","unique":false},
	{"id":"zorro_acechante","name":"ZORRO ACECHANTE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":["EMBOSCADA"],"tags":["BESTIA"],"effect_id":"","unique":false},
	{"id":"lobo_joven","name":"LOBO JOVEN","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":["MANADA"],"tags":["BESTIA"],"effect_id":"forest_pack_attack","unique":false},
	{"id":"cierva_lunar","name":"CIERVA LUNAR","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":4,"keywords":[],"tags":["BESTIA"],"effect_id":"forest_moon_deer","unique":false},
	{"id":"cuervo_del_sendero","name":"CUERVO DEL SENDERO","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":[],"tags":["BESTIA"],"effect_id":"forest_path_raven","unique":false},
	{"id":"jabali_de_raiz","name":"JABALÍ DE RAÍZ","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":4,"keywords":[],"tags":["BESTIA"],"effect_id":"forest_root_boar","unique":false},
	{"id":"lobo_alfa","name":"LOBO ALFA","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":4,"keywords":["MANADA"],"tags":["BESTIA"],"effect_id":"forest_alpha_aura","unique":false},
	{"id":"oso_ancestral","name":"OSO ANCESTRAL","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":5,"attack":5,"health":7,"keywords":["GUARDIA"],"tags":["BESTIA"],"effect_id":"","unique":false},
	{"id":"llamado_de_la_manada","name":"LLAMADO DE LA MANADA","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forest_call_pack","unique":false},
	{"id":"crecimiento_violento","name":"CRECIMIENTO VIOLENTO","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forest_growth","unique":false},
	{"id":"totem_de_manada","name":"TÓTEM DE MANADA","domain":DOMAIN_FOREST,"type":TYPE_RELIC,"cost":3,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forest_pack_totem","unique":false},
	{"id":"sello_del_rastro","name":"SELLO DEL RASTRO","domain":DOMAIN_FOREST,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forest_trail_seal","unique":false},
	{"id":"bs_005_enredadera_vigilante","set_id":"BS-005","name":"ENREDADERA VIGILANTE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":5,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"uncommon"},
	{"id":"bs_011_anciano_de_raices","set_id":"BS-011","name":"ANCIANO DE RAÍCES","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":5,"attack":4,"health":7,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"forest_ancient_roots","unique":false,"rarity":"rare"},
	{"id":"bs_014_savia_vital","set_id":"BS-014","name":"SAVIA VITAL","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_vital_sap","unique":false,"rarity":"common"},
	{"id":"bs_013_avatar_del_bosque","set_id":"BS-013","name":"AVATAR DEL BOSQUE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":8,"keywords":[],"tags":["FUNDACIONAL","ANCESTRAL"],"effect_id":"forest_avatar","unique":true,"rarity":"legendary"},
	{"id":"bs_016_llamado_de_la_manada","set_id":"BS-016","name":"LLAMADO DE LA MANADA","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_call_foundational","unique":false,"rarity":"uncommon"},
	{"id":"bs_020_santuario_de_la_manada","set_id":"BS-020","name":"SANTUARIO DE LA MANADA","domain":DOMAIN_FOREST,"type":TYPE_RELIC,"cost":4,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_pack_sanctuary","unique":false,"rarity":"rare"},

	# Cripta de Hueso
	{"id":"esqueleto_roto","name":"ESQUELETO ROTO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":1,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_broken_skeleton","unique":false},
	{"id":"sepulturero","name":"SEPULTURERO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":3,"keywords":[],"tags":["NO_MUERTO"],"effect_id":"crypt_gravedigger","unique":false},
	{"id":"perro_funebre","name":"PERRO FÚNEBRE","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_funeral_hound","unique":false},
	{"id":"lamentadora","name":"LAMENTADORA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_mourner","unique":false},
	{"id":"guardian_oseo","name":"GUARDIÁN ÓSEO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":4,"keywords":["GUARDIA"],"tags":["NO_MUERTO"],"effect_id":"","unique":false},
	{"id":"necrofago","name":"NECRÓFAGO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["NO_MUERTO"],"effect_id":"crypt_ghoul","unique":false},
	{"id":"caballero_vacio","name":"CABALLERO VACÍO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":5,"keywords":[],"tags":["NO_MUERTO"],"effect_id":"crypt_empty_knight","unique":false},
	{"id":"revenante","name":"REVENANTE","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":5,"attack":4,"health":6,"keywords":["EXHUMAR"],"tags":["NO_MUERTO"],"effect_id":"crypt_revenant","unique":false},
	{"id":"ofrenda_de_ceniza","name":"OFRENDA DE CENIZA","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"crypt_ash_offering","unique":false},
	{"id":"exhumacion","name":"EXHUMACIÓN","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":["EXHUMAR"],"tags":[],"effect_id":"crypt_exhumation","unique":false},
	{"id":"urna_de_restos","name":"URNA DE RESTOS","domain":DOMAIN_CRYPT,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"crypt_remains_urn","unique":false},
	{"id":"sello_del_funeral","name":"SELLO DEL FUNERAL","domain":DOMAIN_CRYPT,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"crypt_funeral_seal","unique":false},
	{"id":"ch_007_nigromante_de_fosa","set_id":"CH-007","name":"NIGROMANTE DE FOSA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_pit_necromancer","unique":false,"rarity":"rare"},
	{"id":"ch_012_abominacion_ensamblada","set_id":"CH-012","name":"ABOMINACIÓN ENSAMBLADA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":5,"attack":5,"health":6,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","cost_rule":{"type":"deaths_since_last_turn","reduction_per_death":1,"floor":3},"unique":false,"rarity":"rare"},
	{"id":"ch_016_pacto_de_sangre","set_id":"CH-016","name":"PACTO DE SANGRE","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_blood_pact","unique":false,"rarity":"uncommon"},
	{"id":"ch_013_rey_sin_sepulcro","set_id":"CH-013","name":"REY SIN SEPULCRO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":6,"attack":5,"health":7,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"crypt_unburied_king","unique":true,"rarity":"legendary"},
	{"id":"ch_017_llamado_de_los_caidos","set_id":"CH-017","name":"LLAMADO DE LOS CAÍDOS","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_call_fallen","unique":false,"rarity":"rare"},
	{"id":"ch_019_osario_ritual","set_id":"CH-019","name":"OSARIO RITUAL","domain":DOMAIN_CRYPT,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_ritual_ossuary","unique":false,"rarity":"uncommon"},

	# Torre Arcana
	{"id":"familiar_arcano","name":"FAMILIAR ARCANO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":["REVELAR"],"tags":["ARCANO"],"effect_id":"tower_familiar","unique":false},
	{"id":"buho_oculum","name":"BÚHO ÓCULUM","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":3,"keywords":["REVELAR"],"tags":["ARCANO"],"effect_id":"tower_oculum_owl","unique":false},
	{"id":"aprendiz_runico","name":"APRENDIZ RÚNICO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":[],"tags":["ARCANO"],"effect_id":"tower_apprentice","unique":false},
	{"id":"adepta_runica","name":"ADEPTA RÚNICA","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["ARCANO"],"effect_id":"tower_adept","unique":false},
	{"id":"golem_sigilado","name":"GÓLEM SIGILADO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":5,"keywords":["BLINDAJE_1"],"tags":["ARCANO","CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"serpiente_de_mana","name":"SERPIENTE DE MANÁ","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":["CANALIZAR_1"],"tags":["ARCANO"],"effect_id":"tower_mana_serpent","unique":false},
	{"id":"espectro_del_tomo","name":"ESPECTRO DEL TOMO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":4,"attack":3,"health":4,"keywords":[],"tags":["ARCANO"],"effect_id":"tower_tome_specter","unique":false},
	{"id":"cartografo_astral","name":"CARTÓGRAFO ASTRAL","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":4,"attack":2,"health":5,"keywords":["REVELAR"],"tags":["ARCANO"],"effect_id":"tower_astral_cartographer","unique":false},
	{"id":"proyectil_runico","name":"PROYECTIL RÚNICO","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":["CANALIZAR_1"],"tags":[],"effect_id":"tower_rune_bolt","unique":false},
	{"id":"vision_prohibida","name":"VISIÓN PROHIBIDA","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":["REVELAR"],"tags":[],"effect_id":"tower_forbidden_vision","unique":false},
	{"id":"astrolabio","name":"ASTROLABIO","domain":DOMAIN_TOWER,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":["REVELAR"],"tags":[],"effect_id":"tower_astrolabe","unique":false},
	{"id":"sello_del_circulo","name":"SELLO DEL CÍRCULO","domain":DOMAIN_TOWER,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"tower_circle_seal","unique":false},
	{"id":"ta_016_descarga_runica","set_id":"TA-016","name":"DESCARGA RÚNICA","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_rune_discharge","unique":false,"rarity":"common"},
	{"id":"ta_017_geometria_imposible","set_id":"TA-017","name":"GEOMETRÍA IMPOSIBLE","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_impossible_geometry","unique":false,"rarity":"rare"},
	{"id":"ta_018_tormenta_de_glifos","set_id":"TA-018","name":"TORMENTA DE GLIFOS","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":4,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_glyph_storm","unique":false,"rarity":"rare"},
	{"id":"ta_003_adepta_del_vector","set_id":"TA-003","name":"ADEPTA DEL VECTOR","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_vector_adept","unique":false,"rarity":"common"},
	{"id":"ta_008_manipulador_cinetico","set_id":"TA-008","name":"MANIPULADOR CINÉTICO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_kinetic_manipulator","unique":false,"rarity":"rare"},
	{"id":"ta_010_golem_de_eter","set_id":"TA-010","name":"GÓLEM DE ÉTER","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":5,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"common"},

	# Fundición Antigua
	{"id":"automata_obrero","name":"AUTÓMATA OBRERO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_worker","unique":false},
	{"id":"centinela_de_cobre","name":"CENTINELA DE COBRE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":["BLINDAJE_1"],"tags":["CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"engranaje_vivo","name":"ENGRANAJE VIVO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":["ENSAMBLAR"],"tags":["CONSTRUCTO"],"effect_id":"forge_living_gear","unique":false},
	{"id":"reparador_mecanico","name":"REPARADOR MECÁNICO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_repairer","unique":false},
	{"id":"torreta_runica","name":"TORRETA RÚNICA","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_turret","unique":false},
	{"id":"caldera_andante","name":"CALDERA ANDANTE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":2,"health":6,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_walking_boiler","unique":false},
	{"id":"golem_de_hierro","name":"GÓLEM DE HIERRO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":6,"keywords":["BLINDAJE_1"],"tags":["CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"coloso_de_bronce","name":"COLOSO DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":8,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_bronze_colossus","unique":false},
	{"id":"chispa_mecanica","name":"CHISPA MECÁNICA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forge_spark","unique":false},
	{"id":"sobrecarga","name":"SOBRECARGA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":["SOBRECALENTAR"],"tags":[],"effect_id":"forge_overload","unique":false},
	{"id":"horno_runico","name":"HORNO RÚNICO","domain":DOMAIN_FORGE,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forge_rune_furnace","unique":false},
	{"id":"sello_de_presion","name":"SELLO DE PRESIÓN","domain":DOMAIN_FORGE,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forge_pressure_seal","unique":false},
	{"id":"fa_005_ariete_de_bronce","set_id":"FA-005","name":"ARIETE DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":3,"health":2,"keywords":["EMBESTIDA"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"uncommon"},
	{"id":"fa_009_bastion_rodante","set_id":"FA-009","name":"BASTIÓN RODANTE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":3,"health":7,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"rare"},
	{"id":"fa_014_reparacion_de_emergencia","set_id":"FA-014","name":"REPARACIÓN DE EMERGENCIA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_emergency_repair","unique":false,"rarity":"common"},
	{"id":"fa_013_coloso_de_bronce","set_id":"FA-013","name":"COLOSO DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":9,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL","CONSTRUCTO"],"effect_id":"forge_bronze_colossus_foundational","unique":true,"rarity":"legendary"},
	{"id":"fa_016_sobrecarga","set_id":"FA-016","name":"SOBRECARGA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_overload_foundational","unique":false,"rarity":"uncommon"},
	{"id":"fa_019_horno_runico","set_id":"FA-019","name":"HORNO RÚNICO","domain":DOMAIN_FORGE,"type":TYPE_RELIC,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_rune_furnace_foundational","unique":false,"rarity":"uncommon"}
]

const STARTER_DECKS = {
	DOMAIN_FOREST: [
		"ardilla_vigilante","ardilla_vigilante","zorro_acechante","zorro_acechante",
		"lobo_joven","lobo_joven","cierva_lunar","cierva_lunar","cuervo_del_sendero",
		"jabali_de_raiz","jabali_de_raiz","lobo_alfa","oso_ancestral",
		"llamado_de_la_manada","llamado_de_la_manada","crecimiento_violento",
		"crecimiento_violento","totem_de_manada","sello_del_rastro","sello_del_rastro"
	],
	DOMAIN_CRYPT: [
		"esqueleto_roto","esqueleto_roto","sepulturero","sepulturero","perro_funebre",
		"perro_funebre","lamentadora","lamentadora","guardian_oseo","necrofago","necrofago",
		"caballero_vacio","revenante","ofrenda_de_ceniza","ofrenda_de_ceniza",
		"exhumacion","exhumacion","urna_de_restos","sello_del_funeral","sello_del_funeral"
	],
	DOMAIN_TOWER: [
		"familiar_arcano","familiar_arcano","buho_oculum","buho_oculum","aprendiz_runico",
		"aprendiz_runico","adepta_runica","golem_sigilado","golem_sigilado","serpiente_de_mana",
		"espectro_del_tomo","cartografo_astral","proyectil_runico","proyectil_runico",
		"vision_prohibida","vision_prohibida","astrolabio","astrolabio",
		"sello_del_circulo","sello_del_circulo"
	],
	DOMAIN_FORGE: [
		"automata_obrero","automata_obrero","centinela_de_cobre","centinela_de_cobre",
		"engranaje_vivo","engranaje_vivo","reparador_mecanico","reparador_mecanico",
		"torreta_runica","caldera_andante","golem_de_hierro","coloso_de_bronce",
		"chispa_mecanica","chispa_mecanica","sobrecarga","sobrecarga","horno_runico",
		"horno_runico","sello_de_presion","sello_de_presion"
	]
}

const ESSENCE_NAMES = {
	DOMAIN_FOREST: "Instinto",
	DOMAIN_CRYPT: "Restos",
	DOMAIN_TOWER: "Conocimiento",
	DOMAIN_FORGE: "Calor"
}

const ESSENCE_MAX = {
	DOMAIN_FOREST: 5,
	DOMAIN_CRYPT: 6,
	DOMAIN_TOWER: 5,
	DOMAIN_FORGE: 6
}

static func find_by_id(card_id: String) -> Dictionary:
	for card in CARDS:
		if str(card.get("id", "")) == card_id:
			return card.duplicate(true)
	return {}

static func all_cards() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in CARDS:
		result.append(card.duplicate(true))
	return result

static func all_card_ids() -> Array[String]:
	var result: Array[String] = []
	for card in CARDS:
		result.append(str(card.get("id", "")))
	return result

static func cards_for_domain(domain: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in CARDS:
		if str(card.get("domain", "")) == domain:
			result.append(card.duplicate(true))
	return result

static func starter_deck(domain: String) -> Array[String]:
	var result: Array[String] = []
	for card_id in STARTER_DECKS.get(domain, []):
		result.append(str(card_id))
	return result

static func essence_name(domain: String) -> String:
	return str(ESSENCE_NAMES.get(domain, ""))

static func essence_max(domain: String) -> int:
	return int(ESSENCE_MAX.get(domain, 0))

static func validate_deck(deck_ids: Array[String], domain: String) -> Array[String]:
	var errors: Array[String] = []
	if deck_ids.size() != 20:
		errors.append("El mazo debe contener exactamente 20 cartas.")
	var counts := {}
	for card_id in deck_ids:
		var card := find_by_id(card_id)
		if card.is_empty():
			errors.append("Carta desconocida: %s" % card_id)
			continue
		if str(card.get("domain", "")) != domain:
			errors.append("%s no pertenece al dominio %s." % [card_id, domain])
		counts[card_id] = int(counts.get(card_id, 0)) + 1
		var limit := 1 if bool(card.get("unique", false)) else 2
		if int(counts[card_id]) > limit:
			errors.append("%s excede el límite de %d copia(s)." % [card_id, limit])
	return errors

static func validate_catalog() -> Array[String]:
	var errors: Array[String] = []
	if CARDS.size() != 72:
		errors.append("El catálogo transitorio debe contener 72 cartas durante Foundation Batch 2.")
	var ids := {}
	for card in CARDS:
		var card_id := str(card.get("id", ""))
		if card_id.is_empty():
			errors.append("Existe una carta sin id.")
		elif ids.has(card_id):
			errors.append("ID duplicado: %s" % card_id)
		ids[card_id] = true
		if int(card.get("cost", -1)) < 0:
			errors.append("Coste inválido: %s" % card_id)
		if not [TYPE_CREATURE, TYPE_RITE, TYPE_RELIC, TYPE_SEAL].has(str(card.get("type", ""))):
			errors.append("Tipo inválido: %s" % card_id)
	for domain in [DOMAIN_FOREST, DOMAIN_CRYPT, DOMAIN_TOWER, DOMAIN_FORGE]:
		if cards_for_domain(domain).size() != 18:
			errors.append("El dominio %s debe tener 18 cartas durante Foundation Batch 2." % domain)
		errors.append_array(validate_deck(starter_deck(domain), domain))
	return errors
