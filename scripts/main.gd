extends Control

## Nexo de Runas V2 — Fase 1B.
## Constructor de mazo táctil y primer componente reutilizable de carta.

const BG := Color8(8, 8, 7)
const PANEL := Color8(27, 23, 17)
const PANEL_ALT := Color8(18, 16, 13)
const INK := Color8(230, 220, 190)
const MUTED := Color8(157, 146, 121)
const ACCENT := Color8(190, 139, 57)
const ACCENT_DARK := Color8(83, 55, 25)
const BORDER := Color8(112, 82, 42)
const BLOOD := Color8(126, 38, 34)
const BONE := Color8(180, 170, 137)
const ENERGY := Color8(58, 124, 137)
const RUNE := Color8(112, 67, 143)

var menu_screen: Control
var deck_screen: Control
var detail_screen: Control
var collection_grid: GridContainer
var deck_grid: GridContainer
var deck_counter: Label
var style_label: Label
var selected_style := "Bestias"
var deck_ids: Array[String] = []

var cards := [
	{"id":"lobo","name":"LOBO","style":"Bestias","cost":"2 SANGRE","atk":3,"hp":2,"seal":"FEROCIDAD","glyph":"◢"},
	{"id":"alce","name":"ALCE","style":"Bestias","cost":"3 SANGRE","atk":3,"hp":5,"seal":"CORREDOR","glyph":"♞"},
	{"id":"cuervo","name":"CUERVO","style":"Bestias","cost":"2 SANGRE","atk":2,"hp":3,"seal":"AÉREO","glyph":"◆"},
	{"id":"esqueleto","name":"ESQUELETO","style":"No-muertos","cost":"1 HUESO","atk":1,"hp":1,"seal":"FRÁGIL","glyph":"☠"},
	{"id":"sepulturero","name":"SEPULTURERO","style":"No-muertos","cost":"2 HUESOS","atk":0,"hp":3,"seal":"EXHUMAR","glyph":"✚"},
	{"id":"zombi","name":"ZOMBI","style":"No-muertos","cost":"5 HUESOS","atk":2,"hp":2,"seal":"TENAZ","glyph":"☩"},
	{"id":"automata","name":"AUTÓMATA","style":"Tecnología","cost":"3 ENERGÍA","atk":1,"hp":2,"seal":"CONDUCTOR","glyph":"▣"},
	{"id":"francotirador","name":"BOT TIRADOR","style":"Tecnología","cost":"4 ENERGÍA","atk":2,"hp":1,"seal":"APUNTAR","glyph":"⌖"},
	{"id":"conducto","name":"CONDUCTO","style":"Tecnología","cost":"2 ENERGÍA","atk":0,"hp":3,"seal":"CIRCUITO","glyph":"⌁"},
	{"id":"mox_rubi","name":"MOX RUBÍ","style":"Magia","cost":"NINGUNO","atk":0,"hp":1,"seal":"RUBÍ","glyph":"♦"},
	{"id":"aprendiz","name":"APRENDIZ","style":"Magia","cost":"1 RUNA","atk":1,"hp":2,"seal":"HECHIZO","glyph":"✦"},
	{"id":"guardian","name":"GUARDIÁN MOX","style":"Magia","cost":"2 RUNAS","atk":2,"hp":3,"seal":"GUARDIA","glyph":"⬡"}
]

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_background()
	_build_menu()
	_build_deck_builder()
	_build_detail()
	_show(menu_screen)

func _build_background() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

func _screen_margin() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	return margin

func _build_menu() -> void:
	menu_screen = _screen_margin()
	add_child(menu_screen)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER, 3, 8))
	menu_screen.add_child(panel)
	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 17)
	panel.add_child(root)
	root.add_child(_label("NEXO DE RUNAS", 50, INK, HORIZONTAL_ALIGNMENT_CENTER))
	root.add_child(_label("ELIGE TU PRÓXIMO MOVIMIENTO", 18, ACCENT, HORIZONTAL_ALIGNMENT_CENTER))
	var deck_button := _wide_button("CONSTRUCTOR DE MAZO")
	deck_button.pressed.connect(_open_deck)
	root.add_child(deck_button)
	var cpu := _wide_button("BATALLA VS CPU")
	cpu.pressed.connect(_open_detail.bind("BATALLA VS CPU", "El combate se conectará al mismo mazo que prepares aquí."))
	root.add_child(cpu)
	var local := _wide_button("BATALLA LOCAL")
	local.pressed.connect(_open_detail.bind("BATALLA LOCAL", "La conexión Wi-Fi llegará después de estabilizar el combate contra CPU."))
	root.add_child(local)

func _build_deck_builder() -> void:
	deck_screen = _screen_margin()
	add_child(deck_screen)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	deck_screen.add_child(root)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	root.add_child(header)
	var back := _small_button("‹ VOLVER", 150)
	back.pressed.connect(_show.bind(menu_screen))
	header.add_child(back)
	var title := _label("CONSTRUCTOR DE MAZO", 32, INK, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	deck_counter = _label("", 20, ACCENT, HORIZONTAL_ALIGNMENT_RIGHT)
	deck_counter.custom_minimum_size = Vector2(170, 44)
	header.add_child(deck_counter)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	root.add_child(tabs)
	for style in ["Bestias", "No-muertos", "Tecnología", "Magia"]:
		var tab := _small_button(style.to_upper(), 195)
		tab.pressed.connect(_select_style.bind(style))
		tabs.add_child(tab)
	style_label = _label("", 15, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(style_label)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	root.add_child(columns)
	var collection_panel := _section_panel("COLECCIÓN · TOCA PARA AÑADIR")
	collection_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(collection_panel)
	collection_grid = GridContainer.new()
	collection_grid.columns = 3
	collection_grid.add_theme_constant_override("h_separation", 10)
	collection_grid.add_theme_constant_override("v_separation", 10)
	collection_panel.get_node("Box").add_child(collection_grid)

	var deck_panel := _section_panel("TU MAZO · TOCA PARA QUITAR")
	deck_panel.custom_minimum_size = Vector2(375, 0)
	columns.add_child(deck_panel)
	deck_grid = GridContainer.new()
	deck_grid.columns = 2
	deck_grid.add_theme_constant_override("h_separation", 9)
	deck_grid.add_theme_constant_override("v_separation", 9)
	deck_panel.get_node("Box").add_child(deck_grid)
	_refresh_cards()

func _section_panel(title_text: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, BORDER, 2, 4))
	var box := VBoxContainer.new()
	box.name = "Box"
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_label(title_text, 15, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	return panel

func _build_detail() -> void:
	detail_screen = _screen_margin()
	add_child(detail_screen)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 24)
	detail_screen.add_child(box)
	var title := _label("", 38, INK, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	box.add_child(title)
	var body := _label("", 20, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	body.name = "Body"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	var back := _wide_button("VOLVER")
	back.pressed.connect(_show.bind(menu_screen))
	box.add_child(back)

func _open_deck() -> void:
	_refresh_cards()
	_show(deck_screen)

func _open_detail(title_text: String, body_text: String) -> void:
	detail_screen.get_node("VBoxContainer/Title").text = title_text
	detail_screen.get_node("VBoxContainer/Body").text = body_text
	_show(detail_screen)

func _select_style(style: String) -> void:
	selected_style = style
	_refresh_cards()

func _refresh_cards() -> void:
	if collection_grid == null:
		return
	for child in collection_grid.get_children():
		child.queue_free()
	for child in deck_grid.get_children():
		child.queue_free()
	for card in cards:
		if card.style == selected_style and not deck_ids.has(card.id):
			collection_grid.add_child(_card_view(card, false))
	for card_id in deck_ids:
		var card = _find_card(card_id)
		if not card.is_empty():
			deck_grid.add_child(_card_view(card, true))
	deck_counter.text = "%d / 20 CARTAS" % deck_ids.size()
	style_label.text = "ESTILO: %s · las cartas ya comparten el componente que usará la batalla" % selected_style.to_upper()

func _card_view(card: Dictionary, in_deck: bool) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(155, 205)
	button.focus_mode = Control.FOCUS_NONE
	button.text = "%s\n\n%s\n\n%s\n%s\n⚔ %d     ♥ %d" % [
		card.name, card.glyph, card.cost, card.seal, card.atk, card.hp
	]
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	var tint := _resource_color(card.style)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL, tint, 3, 3))
	button.add_theme_stylebox_override("hover", _panel_style(Color8(42, 34, 24), ACCENT, 4, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 4, 3))
	if in_deck:
		button.pressed.connect(_remove_card.bind(card.id))
	else:
		button.pressed.connect(_add_card.bind(card.id))
	return button

func _add_card(card_id: String) -> void:
	if deck_ids.size() < 20 and not deck_ids.has(card_id):
		deck_ids.append(card_id)
	_refresh_cards()

func _remove_card(card_id: String) -> void:
	deck_ids.erase(card_id)
	_refresh_cards()

func _find_card(card_id: String) -> Dictionary:
	for card in cards:
		if card.id == card_id:
			return card
	return {}

func _resource_color(style: String) -> Color:
	match style:
		"Bestias": return BLOOD
		"No-muertos": return BONE
		"Tecnología": return ENERGY
		"Magia": return RUNE
		_: return BORDER

func _show(target: Control) -> void:
	menu_screen.visible = target == menu_screen
	deck_screen.visible = target == deck_screen
	detail_screen.visible = target == detail_screen

func _label(text_value: String, size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _wide_button(text_value: String) -> Button:
	var button := _small_button(text_value, 620)
	button.custom_minimum_size.y = 64
	button.add_theme_font_size_override("font_size", 22)
	return button

func _small_button(text_value: String, width: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 44)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 3))
	button.add_theme_stylebox_override("hover", _panel_style(Color8(38, 31, 22), ACCENT, 2, 3))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 2, 3))
	return button

func _panel_style(color: Color, border_color: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style
