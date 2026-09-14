class_name ActOneCardView
extends Button

## Vista transitoria de carta para el rumbo Acto 1.
## Evita colores/facciones del Acto 2 y aproxima papel envejecido sobre mesa oscura.
const PAPER := Color8(91, 74, 48)
const PAPER_PRESSED := Color8(111, 87, 53)
const PAPER_DARK := Color8(46, 37, 25)
const INK := Color8(235, 222, 184)
const MUTED := Color8(180, 164, 126)
const SHADOW := Color8(18, 14, 10)
const BLOOD := Color8(148, 47, 38)
const BONE := Color8(211, 199, 162)
const NEUTRAL := Color8(161, 125, 73)
const EDGE := Color8(54, 40, 24)

var card: Dictionary = {}
var compact := false
var in_deck := false

func configure(card_data: Dictionary, is_in_deck := false, compact_mode := false) -> void:
	card = card_data.duplicate(true)
	in_deck = is_in_deck
	compact = compact_mode
	focus_mode = Control.FOCUS_NONE
	text = ""
	clip_contents = true
	custom_minimum_size = Vector2(142, 198) if compact else Vector2(178, 244)
	_apply_theme()
	_build_contents()

func _apply_theme() -> void:
	add_theme_stylebox_override("normal", _style(PAPER_DARK, EDGE, 3))
	add_theme_stylebox_override("hover", _style(PAPER, NEUTRAL, 3))
	add_theme_stylebox_override("pressed", _style(PAPER_PRESSED, BLOOD, 4))
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _build_contents() -> void:
	for child in get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var edge := 7 if compact else 9
	margin.add_theme_constant_override("margin_left", edge)
	margin.add_theme_constant_override("margin_right", edge)
	margin.add_theme_constant_override("margin_top", edge)
	margin.add_theme_constant_override("margin_bottom", edge)
	add_child(margin)

	var root := VBoxContainer.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_theme_constant_override("separation", 4 if compact else 6)
	margin.add_child(root)

	var title := _label(str(card.get("name", "CARTA")), 13 if compact else 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size.y = 22 if compact else 26
	root.add_child(title)

	var cost := _label(str(card.get("cost", "SIN COSTE")), 10 if compact else 12, resource_color(str(card.get("resource", "none"))), HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(cost)

	var portrait := PanelContainer.new()
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.custom_minimum_size.y = 72 if compact else 104
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_theme_stylebox_override("panel", _style(SHADOW, EDGE, 2))
	root.add_child(portrait)

	var portrait_stack := VBoxContainer.new()
	portrait_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	portrait_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(portrait_stack)
	var glyph := _label(str(card.get("glyph", "?")), 38 if compact else 54, INK, HORIZONTAL_ALIGNMENT_CENTER)
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait_stack.add_child(glyph)

	var seal_text := str(card.get("seal", "NINGUNO"))
	if seal_text != "NINGUNO":
		var seal_panel := PanelContainer.new()
		seal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seal_panel.add_theme_stylebox_override("panel", _style(Color8(31, 24, 17), EDGE, 1))
		root.add_child(seal_panel)
		var seal := _label(seal_text, 9 if compact else 11, INK, HORIZONTAL_ALIGNMENT_CENTER)
		seal.custom_minimum_size.y = 22 if compact else 26
		seal.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		seal_panel.add_child(seal)
	else:
		var blank := Control.new()
		blank.custom_minimum_size.y = 23 if compact else 27
		root.add_child(blank)

	var stats := HBoxContainer.new()
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(stats)
	var attack := _label("%d" % int(card.get("atk", 0)), 19 if compact else 25, INK, HORIZONTAL_ALIGNMENT_LEFT)
	attack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(attack)
	var health := _label("%d" % int(card.get("hp", 0)), 19 if compact else 25, INK, HORIZONTAL_ALIGNMENT_RIGHT)
	health.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(health)

	if in_deck:
		var hint := _label("TOCA PARA QUITAR", 8 if compact else 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
		root.add_child(hint)

func _label(value: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = align
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	return label

func _style(color: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 3
	style.content_margin_right = 3
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style

static func resource_color(resource: String) -> Color:
	match resource:
		"blood": return BLOOD
		"bones": return BONE
		_: return NEUTRAL
