class_name CanonicalCardDetail
extends Control

const CardScript = preload("res://scripts/ui/canonical_forest_card.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")

const INK := Color("eadca8")
const MUTED := Color("9b986c")
const GOLD := Color("d2aa54")
const MOSS := Color("718744")

const EFFECT_TEXT := {
	"ardilla_vigilante": "Al entrar, si controlas otra Bestia, obtienes +1 Instinto.",
	"zorro_acechante": "Emboscada: en su primer enfrentamiento golpea antes de recibir represalia.",
	"lobo_joven": "Manada: obtiene +1 ATQ mientras tenga una criatura aliada adyacente.",
	"cierva_lunar": "La primera vez por turno que sobreviva a un combate, cura 1 de Integridad a tu Nexo.",
	"cuervo_del_sendero": "Al hacer daño directo, roba 1 carta y luego descarta 1.",
	"jabali_de_raiz": "Al recibir daño obtiene +1 ATQ durante este turno.",
	"lobo_alfa": "Las Bestias aliadas adyacentes obtienen +1 ATQ.",
	"oso_ancestral": "Guardia: puede interceptar una vez por turno un ataque directo a un carril adyacente.",
	"llamado_de_la_manada": "Rito: crea una Cría 1/1 en un carril aliado vacío.",
	"crecimiento_violento": "Rito: una criatura aliada obtiene +2/+2 durante este turno.",
	"totem_de_manada": "Reliquia: tus criaturas con Manada reciben +1 SAL.",
	"sello_del_rastro": "Sello: el primer daño directo que inflijas cada turno genera +1 Instinto."
}

var _card_view
var _name_label: Label
var _type_label: Label
var _effect_label: Label
var _keyword_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build()

func _build() -> void:
	var shade := Button.new()
	shade.text = ""
	shade.focus_mode = Control.FOCUS_NONE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_theme_stylebox_override("normal", _style(Color(0.005, 0.008, 0.004, 0.82), Color.TRANSPARENT, 0, 0))
	shade.add_theme_stylebox_override("hover", shade.get_theme_stylebox("normal"))
	shade.add_theme_stylebox_override("pressed", shade.get_theme_stylebox("normal"))
	shade.pressed.connect(hide_detail)
	add_child(shade)

	var frame := Panel.new()
	frame.name = "CardDetailFrame"
	frame.add_theme_stylebox_override("panel", _style(Color("171109"), Color("a17d36"), 4, 12))
	add_child(frame)
	frame.position = Vector2(270, 105)
	frame.size = Vector2(740, 510)

	var inner := Panel.new()
	inner.add_theme_stylebox_override("panel", _style(Color(0.11, 0.09, 0.045, 0.92), Color("59662f"), 2, 9))
	frame.add_child(inner)
	inner.position = Vector2(12, 12)
	inner.size = Vector2(716, 486)

	_card_view = CardScript.new()
	_card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(_card_view)
	_card_view.position = Vector2(38, 48)
	_card_view.size = Vector2(235, 330)

	_name_label = _label("", 26, GOLD)
	inner.add_child(_name_label)
	_name_label.position = Vector2(310, 42)
	_name_label.size = Vector2(360, 54)

	_type_label = _label("", 12, MUTED)
	inner.add_child(_type_label)
	_type_label.position = Vector2(310, 92)
	_type_label.size = Vector2(360, 28)

	var effect_title := _label("EFECTO", 11, MOSS)
	inner.add_child(effect_title)
	effect_title.position = Vector2(310, 142)
	effect_title.size = Vector2(120, 26)

	_effect_label = _label("", 15, INK)
	_effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_effect_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	inner.add_child(_effect_label)
	_effect_label.position = Vector2(310, 174)
	_effect_label.size = Vector2(355, 150)

	_keyword_label = _label("", 11, MUTED)
	_keyword_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_keyword_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	inner.add_child(_keyword_label)
	_keyword_label.position = Vector2(310, 332)
	_keyword_label.size = Vector2(355, 70)

	var close := Button.new()
	close.text = "CERRAR"
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_size_override("font_size", 14)
	close.add_theme_color_override("font_color", INK)
	close.add_theme_stylebox_override("normal", _style(Color("24180d"), Color("75652e"), 2, 7))
	close.add_theme_stylebox_override("pressed", _style(Color("35190f"), GOLD, 3, 7))
	close.pressed.connect(hide_detail)
	inner.add_child(close)
	close.position = Vector2(430, 420)
	close.size = Vector2(165, 48)

func show_card(card: Dictionary, attack: int = -1, health: int = -1, ready_state: bool = true) -> void:
	if card.is_empty():
		return
	_card_view.configure(card, attack, health, false, false, ready_state)
	_card_view.size = Vector2(235, 330)
	_name_label.text = str(card.get("name", "CARTA"))
	var kind := str(card.get("type", "")).to_upper()
	if kind == Catalog.TYPE_CREATURE.to_upper():
		kind = "CRIATURA"
	elif kind == Catalog.TYPE_RITE.to_upper():
		kind = "RITO"
	elif kind == Catalog.TYPE_RELIC.to_upper():
		kind = "RELIQUIA"
	elif kind == Catalog.TYPE_SEAL.to_upper():
		kind = "SELLO"
	_type_label.text = "%s · COSTE %d" % [kind, int(card.get("cost", 0))]
	_effect_label.text = str(EFFECT_TEXT.get(str(card.get("id", "")), "Sin texto de efecto registrado."))
	var keywords: Array = card.get("keywords", [])
	_keyword_label.text = "PALABRAS CLAVE: " + (", ".join(keywords) if not keywords.is_empty() else "NINGUNA")
	visible = true
	move_to_front()

func hide_detail() -> void:
	visible = false

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _style(color: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style
