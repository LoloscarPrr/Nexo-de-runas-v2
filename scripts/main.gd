extends Control

## Nexo de Runas V2 — vertical slice de campaña.
## Menú, constructor táctil y primera expedición offline jugable.

const CardCatalogScript = preload("res://scripts/domain/card_catalog.gd")
const CampaignViewScript = preload("res://scripts/ui/campaign_view.gd")
const CardViewScript = preload("res://scripts/ui/card_view.gd")

const BG := Color8(8, 8, 7)
const PANEL := Color8(27, 23, 17)
const PANEL_ALT := Color8(18, 16, 13)
const INK := Color8(230, 220, 190)
const MUTED := Color8(157, 146, 121)
const ACCENT := Color8(190, 139, 57)
const ACCENT_DARK := Color8(83, 55, 25)
const BORDER := Color8(112, 82, 42)
const BLOOD := Color8(154, 52, 45)
const BONE := Color8(205, 194, 156)
const ENERGY := Color8(71, 152, 169)
const RUNE := Color8(145, 86, 180)

var menu_screen: Control
var deck_screen: Control
var detail_screen: Control
var campaign_screen
var collection_grid: GridContainer
var deck_grid: GridContainer
var deck_counter: Label
var style_label: Label
var style_tabs: Dictionary = {}
var selected_style := "Bestias"
var deck_ids: Array[String] = []
var cards = CardCatalogScript.CARDS.duplicate(true)

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_background()
	_build_menu()
	_build_deck_builder()
	_build_detail()
	_build_campaign()
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
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	return margin

func _build_menu() -> void:
	menu_screen = _screen_margin()
	add_child(menu_screen)
	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 14)
	menu_screen.add_child(root)

	var top_rule := HSeparator.new()
	top_rule.custom_minimum_size = Vector2(780, 4)
	root.add_child(top_rule)
	root.add_child(_label("NEXO DE RUNAS", 48, INK, HORIZONTAL_ALIGNMENT_CENTER))
	root.add_child(_label("◆  ELIGE TU PRÓXIMO MOVIMIENTO  ◆", 16, ACCENT, HORIZONTAL_ALIGNMENT_CENTER))

	var actions := VBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	root.add_child(actions)

	var deck_button := _menu_button("▦   CONSTRUCTOR DE MAZO", "Ordena tu colección y prepara un mazo libre")
	deck_button.pressed.connect(_open_deck)
	actions.add_child(deck_button)
	var campaign := _menu_button("◇   CAMPAÑA · ACTO 1", "Expedición, mapa, encuentros y combate contra CPU")
	campaign.pressed.connect(_open_campaign)
	actions.add_child(campaign)
	var local := _menu_button("⌁   BATALLA LOCAL", "Duelo en la misma red · próximamente")
	local.pressed.connect(_open_detail.bind("BATALLA LOCAL", "La conexión Wi-Fi llegará después de estabilizar el combate y la primera expedición offline."))
	actions.add_child(local)

	var bottom_rule := HSeparator.new()
	bottom_rule.custom_minimum_size = Vector2(780, 4)
	root.add_child(bottom_rule)

func _menu_button(title_text: String, subtitle_text: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [title_text, subtitle_text]
	button.custom_minimum_size = Vector2(760, 78)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 2))
	button.add_theme_stylebox_override("hover", _panel_style(PANEL, ACCENT, 3, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 3, 2))
	return button

func _build_deck_builder() -> void:
	deck_screen = _screen_margin()
	add_child(deck_screen)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	deck_screen.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	root.add_child(header)
	var back := _small_button("‹ VOLVER", 132)
	back.pressed.connect(_show.bind(menu_screen))
	header.add_child(back)
	var title := _label("CONSTRUCTOR DE MAZO", 30, INK, HORIZONTAL_ALIGNMENT_LEFT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	deck_counter = _label("", 18, ACCENT, HORIZONTAL_ALIGNMENT_RIGHT)
	deck_counter.custom_minimum_size = Vector2(145, 42)
	deck_counter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(deck_counter)

	var tab_panel := PanelContainer.new()
	tab_panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, BORDER, 1, 2))
	root.add_child(tab_panel)
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 8)
	tab_panel.add_child(tabs)
	for style in ["Bestias", "No-muertos", "Tecnología", "Magia"]:
		var tab := _small_button(style.to_upper(), 180)
		tab.pressed.connect(_select_style.bind(style))
		tabs.add_child(tab)
		style_tabs[style] = tab

	style_label = _label("", 13, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	style_label.custom_minimum_size.y = 22
	root.add_child(style_label)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 12)
	root.add_child(columns)

	var collection_panel := _section_panel("COLECCIÓN", "TOCA UNA CARTA PARA AÑADIRLA")
	collection_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(collection_panel)
	var collection_scroll := ScrollContainer.new()
	collection_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	collection_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	collection_panel.get_node("Box").add_child(collection_scroll)
	collection_grid = GridContainer.new()
	collection_grid.columns = 4
	collection_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_grid.add_theme_constant_override("h_separation", 10)
	collection_grid.add_theme_constant_override("v_separation", 10)
	collection_scroll.add_child(collection_grid)

	var deck_panel := _section_panel("TU MAZO", "TOCA UNA CARTA PARA QUITARLA")
	deck_panel.custom_minimum_size = Vector2(330, 0)
	columns.add_child(deck_panel)
	var deck_scroll := ScrollContainer.new()
	deck_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	deck_panel.get_node("Box").add_child(deck_scroll)
	deck_grid = GridContainer.new()
	deck_grid.columns = 2
	deck_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_grid.add_theme_constant_override("h_separation", 8)
	deck_grid.add_theme_constant_override("v_separation", 8)
	deck_scroll.add_child(deck_grid)
	_refresh_cards()

func _section_panel(title_text: String, hint_text := "") -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(PANEL_ALT, BORDER, 2, 2))
	var box := VBoxContainer.new()
	box.name = "Box"
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_label(title_text, 17, INK, HORIZONTAL_ALIGNMENT_CENTER))
	if not hint_text.is_empty():
		box.add_child(_label(hint_text, 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER))
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

func _build_campaign() -> void:
	campaign_screen = CampaignViewScript.new()
	campaign_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	campaign_screen.connect("exit_requested", _show.bind(menu_screen))
	add_child(campaign_screen)

func _open_deck() -> void:
	_refresh_cards()
	_show(deck_screen)

func _open_campaign() -> void:
	campaign_screen.open_launcher()
	_show(campaign_screen)

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

	var available := 0
	for card in cards:
		if card.style == selected_style and not deck_ids.has(card.id):
			collection_grid.add_child(_card_view(card, false))
			available += 1
	for card_id in deck_ids:
		var card = _find_card(card_id)
		if not card.is_empty():
			deck_grid.add_child(_card_view(card, true))

	deck_counter.text = "%d / 20" % deck_ids.size()
	style_label.text = "%s  ·  %d disponibles  ·  mazo libre separado de campaña" % [selected_style.to_upper(), available]
	_refresh_style_tabs()

func _refresh_style_tabs() -> void:
	for style in style_tabs:
		var tab: Button = style_tabs[style]
		if style == selected_style:
			tab.add_theme_stylebox_override("normal", _panel_style(PANEL, _style_color(style), 3, 2))
		else:
			tab.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 2))

func _card_view(card: Dictionary, in_deck: bool) -> Button:
	var view = CardViewScript.new()
	view.configure(card, in_deck, in_deck)
	if in_deck:
		view.pressed.connect(_remove_card.bind(str(card.id)))
	else:
		view.pressed.connect(_add_card.bind(str(card.id)))
	return view

func _add_card(card_id: String) -> void:
	if deck_ids.size() < 20 and not deck_ids.has(card_id):
		deck_ids.append(card_id)
	_refresh_cards()

func _remove_card(card_id: String) -> void:
	deck_ids.erase(card_id)
	_refresh_cards()

func _find_card(card_id: String) -> Dictionary:
	return CardCatalogScript.find_by_id(card_id)

func _style_color(style: String) -> Color:
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
	campaign_screen.visible = target == campaign_screen

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
	button.custom_minimum_size = Vector2(width, 42)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 2))
	button.add_theme_stylebox_override("hover", _panel_style(PANEL, ACCENT, 2, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 2, 2))
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
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style
