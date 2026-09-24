class_name NexoResourcePalette
extends RefCounted

# La interfaz sigue siendo predominantemente oliva/negra.
const OLIVE_GLOW := Color("c6da58")
const OLIVE_EDGE := Color("4d5726")
const DEEP := Color("090d08")

# Acentos funcionales: apagados, envejecidos y siempre localizados.
const ENERGY := Color("4f8298")
const ENERGY_DIM := Color("29434c")
const MOX_GREEN := Color("4f8a58")
const MOX_GREEN_DIM := Color("2a4930")
const MOX_ORANGE := Color("b8733f")
const MOX_ORANGE_DIM := Color("5b3b24")
const MOX_BLUE := Color("6267a5")
const MOX_BLUE_DIM := Color("343654")
const BLOOD := Color("87362d")
const BONE := Color("c0b78d")

static func resource_color(resource: String) -> Color:
	match resource.to_lower():
		"energy":
			return ENERGY
		"mox":
			return MOX_BLUE
		"blood":
			return BLOOD
		"bones":
			return BONE
		_:
			return OLIVE_GLOW

static func mox_color(name: String, active := true) -> Color:
	match name.to_lower():
		"green":
			return MOX_GREEN if active else MOX_GREEN_DIM
		"orange":
			return MOX_ORANGE if active else MOX_ORANGE_DIM
		"blue":
			return MOX_BLUE if active else MOX_BLUE_DIM
		_:
			return OLIVE_EDGE
