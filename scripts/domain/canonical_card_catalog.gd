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
	{"id":"bs_002_ardilla_runica","set_id":"BS-002","name":"ARDILLA RÚNICA","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":1,"keywords":[],"tags":["FUNDACIONAL","BESTIA"],"effect_id":"forest_rune_squirrel","unique":false,"rarity":"common"},
	{"id":"lobo_joven","name":"LOBO JOVEN","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":["MANADA"],"tags":["BESTIA"],"effect_id":"forest_pack_attack","unique":false},
	{"id":"cierva_lunar","name":"CIERVA LUNAR","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":4,"keywords":[],"tags":["BESTIA"],"effect_id":"forest_moon_deer","unique":false},
	{"id":"zorro_acechante","name":"ZORRO ACECHANTE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":["EMBOSCADA"],"tags":["BESTIA"],"effect_id":"","unique":false},
	{"id":"bs_008_jabali_de_corteza","set_id":"BS-008","name":"JABALÍ DE CORTEZA","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":3,"attack":4,"health":3,"keywords":[],"tags":["FUNDACIONAL","BESTIA"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"bs_003_lobo_joven","set_id":"BS-003","name":"LOBO JOVEN","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":[],"tags":["FUNDACIONAL","BESTIA"],"effect_id":"forest_young_wolf_foundational","unique":false,"rarity":"common"},
	{"id":"oso_ancestral","name":"OSO ANCESTRAL","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":5,"attack":5,"health":7,"keywords":["GUARDIA"],"tags":["BESTIA"],"effect_id":"","unique":false},
	{"id":"bs_006_lobo_de_manada","set_id":"BS-006","name":"LOBO DE MANADA","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["FUNDACIONAL","BESTIA"],"effect_id":"forest_pack_wolf","unique":false,"rarity":"common"},
	{"id":"bs_015_crecimiento_repentino","set_id":"BS-015","name":"CRECIMIENTO REPENTINO","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_sudden_growth","unique":false,"rarity":"common"},
	{"id":"bs_010_oso_musgoso","set_id":"BS-010","name":"OSO MUSGOSO","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":6,"keywords":[],"tags":["FUNDACIONAL","BESTIA"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"sello_del_rastro","name":"SELLO DEL RASTRO","domain":DOMAIN_FOREST,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forest_trail_seal","unique":false},
	{"id":"bs_005_enredadera_vigilante","set_id":"BS-005","name":"ENREDADERA VIGILANTE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":2,"attack":1,"health":5,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"uncommon"},
	{"id":"bs_011_anciano_de_raices","set_id":"BS-011","name":"ANCIANO DE RAÍCES","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":5,"attack":4,"health":7,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"forest_ancient_roots","unique":false,"rarity":"rare"},
	{"id":"bs_014_savia_vital","set_id":"BS-014","name":"SAVIA VITAL","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_vital_sap","unique":false,"rarity":"common"},
	{"id":"bs_013_avatar_del_bosque","set_id":"BS-013","name":"AVATAR DEL BOSQUE","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":8,"keywords":[],"tags":["FUNDACIONAL","ANCESTRAL"],"effect_id":"forest_avatar","unique":true,"rarity":"legendary"},
	{"id":"bs_016_llamado_de_la_manada","set_id":"BS-016","name":"LLAMADO DE LA MANADA","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_call_foundational","unique":false,"rarity":"uncommon"},
	{"id":"bs_020_santuario_de_la_manada","set_id":"BS-020","name":"SANTUARIO DE LA MANADA","domain":DOMAIN_FOREST,"type":TYPE_RELIC,"cost":4,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_pack_sanctuary","unique":false,"rarity":"rare"},
	{"id":"bs_001_brote_del_claro","set_id":"BS-001","name":"BROTE DEL CLARO","domain":DOMAIN_FOREST,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_clearing_sprout","unique":false,"rarity":"common"},
	{"id":"bs_017_raices_invasoras","set_id":"BS-017","name":"RAÍCES INVASORAS","domain":DOMAIN_FOREST,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forest_invasive_roots","unique":false,"rarity":"rare"},

	# Cripta de Hueso
	{"id":"esqueleto_roto","name":"ESQUELETO ROTO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":1,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_broken_skeleton","unique":false},
	{"id":"ch_003_guardia_esqueletico","set_id":"CH-003","name":"GUARDIA ESQUELÉTICO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"perro_funebre","name":"PERRO FÚNEBRE","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_funeral_hound","unique":false},
	{"id":"lamentadora","name":"LAMENTADORA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":["ULTIMO_ALIENTO"],"tags":["NO_MUERTO"],"effect_id":"crypt_mourner","unique":false},
	{"id":"guardian_oseo","name":"GUARDIÁN ÓSEO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":4,"keywords":["GUARDIA"],"tags":["NO_MUERTO"],"effect_id":"","unique":false},
	{"id":"ch_005_perro_de_la_fosa","set_id":"CH-005","name":"PERRO DE LA FOSA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":2,"attack":3,"health":2,"keywords":["EMBESTIDA"],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"ch_008_caballero_desollado","set_id":"CH-008","name":"CABALLERO DESOLLADO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":4,"health":3,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"ch_009_portador_del_ataud","set_id":"CH-009","name":"PORTADOR DEL ATAÚD","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":4,"attack":3,"health":6,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"crypt_coffin_bearer","unique":false,"rarity":"uncommon"},
	{"id":"ofrenda_de_ceniza","name":"OFRENDA DE CENIZA","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"crypt_ash_offering","unique":false},
	{"id":"ch_014_exhumar","set_id":"CH-014","name":"EXHUMAR","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_exhume_foundational","unique":false,"rarity":"common"},
	{"id":"ch_015_toque_funebre","set_id":"CH-015","name":"TOQUE FÚNEBRE","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_funeral_touch","unique":false,"rarity":"common"},
	{"id":"sello_del_funeral","name":"SELLO DEL FUNERAL","domain":DOMAIN_CRYPT,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"crypt_funeral_seal","unique":false},
	{"id":"ch_007_nigromante_de_fosa","set_id":"CH-007","name":"NIGROMANTE DE FOSA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_pit_necromancer","unique":false,"rarity":"rare"},
	{"id":"ch_012_abominacion_ensamblada","set_id":"CH-012","name":"ABOMINACIÓN ENSAMBLADA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":5,"attack":5,"health":6,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","cost_rule":{"type":"deaths_since_last_turn","reduction_per_death":1,"floor":3},"unique":false,"rarity":"rare"},
	{"id":"ch_016_pacto_de_sangre","set_id":"CH-016","name":"PACTO DE SANGRE","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_blood_pact","unique":false,"rarity":"uncommon"},
	{"id":"ch_013_rey_sin_sepulcro","set_id":"CH-013","name":"REY SIN SEPULCRO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":6,"attack":5,"health":7,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"crypt_unburied_king","unique":true,"rarity":"legendary"},
	{"id":"ch_017_llamado_de_los_caidos","set_id":"CH-017","name":"LLAMADO DE LOS CAÍDOS","domain":DOMAIN_CRYPT,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_call_fallen","unique":false,"rarity":"rare"},
	{"id":"ch_019_osario_ritual","set_id":"CH-019","name":"OSARIO RITUAL","domain":DOMAIN_CRYPT,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"crypt_ritual_ossuary","unique":false,"rarity":"uncommon"},
	{"id":"ch_001_rata_de_osario","set_id":"CH-001","name":"RATA DE OSARIO","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":1,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"crypt_ossuary_rat","unique":false,"rarity":"common"},
	{"id":"ch_002_acolito_de_ceniza","set_id":"CH-002","name":"ACÓLITO DE CENIZA","domain":DOMAIN_CRYPT,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["FUNDACIONAL","NO_MUERTO"],"effect_id":"crypt_ash_acolyte","unique":false,"rarity":"common"},

	# Torre Arcana
	{"id":"familiar_arcano","name":"FAMILIAR ARCANO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":["REVELAR"],"tags":["ARCANO"],"effect_id":"tower_familiar","unique":false},
	{"id":"ta_001_aprendiz_de_sigilos","set_id":"TA-001","name":"APRENDIZ DE SIGILOS","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["FUNDACIONAL","ARCANO"],"effect_id":"tower_sigils_apprentice","unique":false,"rarity":"common"},
	{"id":"aprendiz_runico","name":"APRENDIZ RÚNICO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":[],"tags":["ARCANO"],"effect_id":"tower_apprentice","unique":false},
	{"id":"adepta_runica","name":"ADEPTA RÚNICA","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["ARCANO"],"effect_id":"tower_adept","unique":false},
	{"id":"golem_sigilado","name":"GÓLEM SIGILADO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":5,"keywords":["BLINDAJE_1"],"tags":["ARCANO","CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"ta_005_teurgo_de_chispas","set_id":"TA-005","name":"TEÚRGO DE CHISPAS","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":2,"keywords":[],"tags":["FUNDACIONAL","ARCANO"],"effect_id":"tower_spark_theurge","unique":false,"rarity":"uncommon"},
	{"id":"ta_006_maga_de_refraccion","set_id":"TA-006","name":"MAGA DE REFRACCIÓN","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["FUNDACIONAL","ARCANO"],"effect_id":"tower_refraction_mage","unique":false,"rarity":"uncommon"},
	{"id":"ta_014_reordenar","set_id":"TA-014","name":"REORDENAR","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_reorder_foundational","unique":false,"rarity":"common"},
	{"id":"ta_011_maestro_de_cinco_trazos","set_id":"TA-011","name":"MAESTRO DE CINCO TRAZOS","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":5,"attack":4,"health":6,"keywords":[],"tags":["FUNDACIONAL","ARCANO"],"effect_id":"tower_five_strokes_master","unique":false,"rarity":"rare"},
	{"id":"ta_012_archimaga_de_las_cinco_runas","set_id":"TA-012","name":"ARCHIMAGA DE LAS CINCO RUNAS","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":6,"attack":4,"health":7,"keywords":[],"tags":["FUNDACIONAL","ARCANO"],"effect_id":"tower_five_runes_archmage","unique":true,"rarity":"legendary"},
	{"id":"astrolabio","name":"ASTROLABIO","domain":DOMAIN_TOWER,"type":TYPE_RELIC,"cost":2,"attack":0,"health":0,"keywords":["REVELAR"],"tags":[],"effect_id":"tower_astrolabe","unique":false},
	{"id":"sello_del_circulo","name":"SELLO DEL CÍRCULO","domain":DOMAIN_TOWER,"type":TYPE_SEAL,"cost":2,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"tower_circle_seal","unique":false},
	{"id":"ta_016_descarga_runica","set_id":"TA-016","name":"DESCARGA RÚNICA","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_rune_discharge","unique":false,"rarity":"common"},
	{"id":"ta_017_geometria_imposible","set_id":"TA-017","name":"GEOMETRÍA IMPOSIBLE","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_impossible_geometry","unique":false,"rarity":"rare"},
	{"id":"ta_018_tormenta_de_glifos","set_id":"TA-018","name":"TORMENTA DE GLIFOS","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":4,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_glyph_storm","unique":false,"rarity":"rare"},
	{"id":"ta_003_adepta_del_vector","set_id":"TA-003","name":"ADEPTA DEL VECTOR","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_vector_adept","unique":false,"rarity":"common"},
	{"id":"ta_008_manipulador_cinetico","set_id":"TA-008","name":"MANIPULADOR CINÉTICO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_kinetic_manipulator","unique":false,"rarity":"rare"},
	{"id":"ta_010_golem_de_eter","set_id":"TA-010","name":"GÓLEM DE ÉTER","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":5,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"ta_007_centinela_runico","set_id":"TA-007","name":"CENTINELA RÚNICO","domain":DOMAIN_TOWER,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":4,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"ta_013_chispa_dirigida","set_id":"TA-013","name":"CHISPA DIRIGIDA","domain":DOMAIN_TOWER,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"tower_directed_spark","unique":false,"rarity":"common"},

	# Fundición Antigua
	{"id":"automata_obrero","name":"AUTÓMATA OBRERO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_worker","unique":false},
	{"id":"centinela_de_cobre","name":"CENTINELA DE COBRE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":3,"keywords":["BLINDAJE_1"],"tags":["CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"fa_002_chispero_de_cobre","set_id":"FA-002","name":"CHISPERO DE COBRE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":1,"attack":2,"health":1,"keywords":[],"tags":["FUNDACIONAL","CONSTRUCTO"],"effect_id":"forge_copper_sparker","unique":false,"rarity":"common"},
	{"id":"reparador_mecanico","name":"REPARADOR MECÁNICO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":3,"attack":2,"health":4,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_repairer","unique":false},
	{"id":"fa_006_soldado_remachado","set_id":"FA-006","name":"SOLDADO REMACHADO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":4,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"fa_008_lanzallamas_de_taller","set_id":"FA-008","name":"LANZALLAMAS DE TALLER","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":3,"attack":3,"health":3,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_workshop_flamethrower","unique":false,"rarity":"rare"},
	{"id":"golem_de_hierro","name":"GÓLEM DE HIERRO","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":6,"keywords":["BLINDAJE_1"],"tags":["CONSTRUCTO"],"effect_id":"","unique":false},
	{"id":"coloso_de_bronce","name":"COLOSO DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":8,"keywords":[],"tags":["CONSTRUCTO"],"effect_id":"forge_bronze_colossus","unique":false},
	{"id":"chispa_mecanica","name":"CHISPA MECÁNICA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":[],"effect_id":"forge_spark","unique":false},
	{"id":"fa_012_martillo_ambulante","set_id":"FA-012","name":"MARTILLO AMBULANTE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":5,"attack":6,"health":5,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_walking_hammer","unique":false,"rarity":"rare"},
	{"id":"fa_015_golpe_de_martillo","set_id":"FA-015","name":"GOLPE DE MARTILLO","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":2,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_hammer_blow","unique":false,"rarity":"common"},
	{"id":"fa_010_automata_de_engranajes","set_id":"FA-010","name":"AUTÓMATA DE ENGRANAJES","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":4,"health":5,"keywords":[],"tags":["FUNDACIONAL","CONSTRUCTO"],"effect_id":"","unique":false,"rarity":"common"},
	{"id":"fa_005_ariete_de_bronce","set_id":"FA-005","name":"ARIETE DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":3,"health":2,"keywords":["EMBESTIDA"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"uncommon"},
	{"id":"fa_009_bastion_rodante","set_id":"FA-009","name":"BASTIÓN RODANTE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":4,"attack":3,"health":7,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"rare"},
	{"id":"fa_014_reparacion_de_emergencia","set_id":"FA-014","name":"REPARACIÓN DE EMERGENCIA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":1,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_emergency_repair","unique":false,"rarity":"common"},
	{"id":"fa_013_coloso_de_bronce","set_id":"FA-013","name":"COLOSO DE BRONCE","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":6,"attack":6,"health":9,"keywords":["ENRAIZADO"],"tags":["FUNDACIONAL","CONSTRUCTO"],"effect_id":"forge_bronze_colossus_foundational","unique":true,"rarity":"legendary"},
	{"id":"fa_016_sobrecarga","set_id":"FA-016","name":"SOBRECARGA","domain":DOMAIN_FORGE,"type":TYPE_RITE,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_overload_foundational","unique":false,"rarity":"uncommon"},
	{"id":"fa_019_horno_runico","set_id":"FA-019","name":"HORNO RÚNICO","domain":DOMAIN_FORGE,"type":TYPE_RELIC,"cost":3,"attack":0,"health":0,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_rune_furnace_foundational","unique":false,"rarity":"uncommon"},
	{"id":"fa_001_aprendiz_de_remachador","set_id":"FA-001","name":"APRENDIZ DE REMACHADOR","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":1,"attack":1,"health":2,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"forge_riveter_apprentice","unique":false,"rarity":"common"},
	{"id":"fa_003_guardia_de_placas","set_id":"FA-003","name":"GUARDIA DE PLACAS","domain":DOMAIN_FORGE,"type":TYPE_CREATURE,"cost":2,"attack":2,"health":4,"keywords":[],"tags":["FUNDACIONAL"],"effect_id":"","unique":false,"rarity":"common"}
]

const STARTER_DECKS = {
	DOMAIN_FOREST: [
		"ardilla_vigilante","ardilla_vigilante","zorro_acechante","zorro_acechante",
		"lobo_joven","lobo_joven","cierva_lunar","cierva_lunar","bs_002_ardilla_runica",
		"bs_008_jabali_de_corteza","bs_008_jabali_de_corteza","bs_003_lobo_joven","oso_ancestral",
		"bs_006_lobo_de_manada","bs_006_lobo_de_manada","bs_015_crecimiento_repentino",
		"bs_015_crecimiento_repentino","bs_010_oso_musgoso","sello_del_rastro","sello_del_rastro"
	],
	DOMAIN_CRYPT: [
		"esqueleto_roto","esqueleto_roto","ch_003_guardia_esqueletico","ch_003_guardia_esqueletico","perro_funebre",
		"perro_funebre","lamentadora","lamentadora","guardian_oseo","ch_005_perro_de_la_fosa","ch_005_perro_de_la_fosa",
		"ch_008_caballero_desollado","ch_009_portador_del_ataud","ofrenda_de_ceniza","ofrenda_de_ceniza",
		"ch_014_exhumar","ch_014_exhumar","ch_015_toque_funebre","sello_del_funeral","sello_del_funeral"
	],
	DOMAIN_TOWER: [
		"familiar_arcano","familiar_arcano","ta_001_aprendiz_de_sigilos","ta_001_aprendiz_de_sigilos","aprendiz_runico",
		"aprendiz_runico","adepta_runica","golem_sigilado","golem_sigilado","ta_005_teurgo_de_chispas",
		"ta_006_maga_de_refraccion","ta_014_reordenar","ta_011_maestro_de_cinco_trazos","ta_011_maestro_de_cinco_trazos",
		"ta_012_archimaga_de_las_cinco_runas","ta_012_archimaga_de_las_cinco_runas","astrolabio","astrolabio",
		"sello_del_circulo","sello_del_circulo"
	],
	DOMAIN_FORGE: [
		"automata_obrero","automata_obrero","centinela_de_cobre","centinela_de_cobre",
		"fa_002_chispero_de_cobre","fa_002_chispero_de_cobre","reparador_mecanico","reparador_mecanico",
		"fa_006_soldado_remachado","fa_008_lanzallamas_de_taller","golem_de_hierro","coloso_de_bronce",
		"chispa_mecanica","chispa_mecanica","fa_012_martillo_ambulante","fa_012_martillo_ambulante","fa_015_golpe_de_martillo",
		"fa_015_golpe_de_martillo","fa_010_automata_de_engranajes","fa_010_automata_de_engranajes"
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
	if CARDS.size() != 80:
		errors.append("El catálogo transitorio estable debe contener 80 cartas durante Foundation Batch 3.")
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
		if cards_for_domain(domain).size() != 20:
			errors.append("El dominio %s debe tener 20 cartas durante Foundation Batch 3." % domain)
		errors.append_array(validate_deck(starter_deck(domain), domain))
	return errors
