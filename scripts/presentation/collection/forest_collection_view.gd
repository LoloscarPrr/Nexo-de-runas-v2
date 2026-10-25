class_name ForestCollectionView
extends Control

signal exit_requested

const Collection = preload("res://scripts/application/collection/canonical_collection.gd")
const PreviewScript = preload("res://scripts/presentation/cards/card_preview.gd")
const TextScript = preload("res://scripts/presentation/cards/card_text.gd")
const DetailScript = preload("res://scripts/presentation/battle/vertical_card_detail.gd")
const BackdropScript = preload("res://scripts/presentation/battle/vertical_battle_backdrop.gd")
const INK := Color("eadca8")
const GOLD := Color("d5a94f")
const CARD_TYPES := ["", "creature", "rite", "relic"]

var search_field: LineEdit
var type_filter: OptionButton
var cost_filter: OptionButton
var card_grid: GridContainer
var card_scroll: ScrollContainer
var card_detail
var selected_id := ""
var visible_cards: Array[Dictionary] = []
var _focus_panel: PanelContainer
var _focus_preview
var _focus_name: Label
var _focus_metadata: Label
var _focus_rules: Label
var _count: Label
var _empty: Label
var _resetting := false

func _ready() -> void:
	name = "ForestCollection"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := BackdropScript.new()
	backdrop.show_guardian = false
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var margin := MarginContainer.new()
	margin.name = "CollectionSafeArea"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + edge, 28)
	for edge in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 20)
	add_child(margin)
	var column := VBoxContainer.new()
	column.name = "CollectionContent"
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)
	column.add_child(_label("✦  NEXO DE RUNAS  ✦", 20, GOLD))
	column.add_child(_label("COLECCIÓN", 38, INK))
	var domain := _label("✦  BOSQUE SALVAJE  ✦", 26, Color("91c875"))
	domain.custom_minimum_size.y = 50
	column.add_child(domain)
	search_field = LineEdit.new()
	search_field.name = "CollectionSearch"
	search_field.placeholder_text = "Buscar por nombre o BS-001…"
	search_field.clear_button_enabled = true
	search_field.custom_minimum_size.y = 64
	search_field.add_theme_font_size_override("font_size", 24)
	search_field.add_theme_color_override("font_color", INK)
	search_field.add_theme_stylebox_override("normal", _style(Color("0e130d")))
	search_field.add_theme_stylebox_override("focus", _style(Color("182916")))
	search_field.text_changed.connect(func(_text: String): _apply_filters())
	column.add_child(search_field)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 12)
	column.add_child(filters)
	type_filter = OptionButton.new()
	type_filter.name = "CollectionTypeFilter"
	for label in ["Todos los tipos", "Criaturas", "Ritos", "Reliquias"]:
		type_filter.add_item(label)
	_style_button(type_filter)
	type_filter.item_selected.connect(func(_index: int): _apply_filters())
	filters.add_child(type_filter)
	cost_filter = OptionButton.new()
	cost_filter.name = "CollectionCostFilter"
	cost_filter.add_item("Todo coste")
	for cost in range(1, 7):
		cost_filter.add_item("Coste %d" % cost)
	_style_button(cost_filter)
	cost_filter.item_selected.connect(func(_index: int): _apply_filters())
	filters.add_child(cost_filter)
	var clear := Button.new()
	clear.name = "ResetCollectionFilters"
	clear.text = "LIMPIAR"
	_style_button(clear)
	clear.pressed.connect(reset_filters)
	filters.add_child(clear)
	_build_focus(column)
	var count_row := HBoxContainer.new()
	column.add_child(count_row)
	_count = _label("", 24, INK)
	_count.autowrap_mode = TextServer.AUTOWRAP_OFF
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_row.add_child(_count)
	var hint := _label("Toca para ampliar", 20, Color("b8aa80"))
	hint.autowrap_mode = TextServer.AUTOWRAP_OFF
	count_row.add_child(hint)
	card_scroll = ScrollContainer.new()
	card_scroll.name = "CollectionScroll"
	card_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card_scroll.scroll_deadzone = 16
	card_scroll.scroll_started.connect(_cancel_card_gestures)
	column.add_child(card_scroll)
	card_grid = GridContainer.new()
	card_grid.name = "CollectionCardGrid"
	card_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_grid.columns = 3
	card_grid.add_theme_constant_override("h_separation", 14)
	card_grid.add_theme_constant_override("v_separation", 18)
	card_scroll.add_child(card_grid)
	_empty = _label("No hay cartas con estos filtros.\nPulsa LIMPIAR para volver al catálogo.", 28, INK)
	_empty.name = "CollectionEmptyState"
	_empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	column.add_child(_empty)
	var back := Button.new()
	back.name = "CollectionBack"
	back.text = "←  VOLVER"
	_style_button(back)
	back.custom_minimum_size.y = 72
	back.pressed.connect(func(): exit_requested.emit())
	column.add_child(back)
	card_detail = DetailScript.new()
	add_child(card_detail)
	resized.connect(_resize_columns)
	_resize_columns()
	reset_filters()

func _build_focus(column: VBoxContainer) -> void:
	_focus_panel = PanelContainer.new()
	_focus_panel.name = "CollectionSelectedCard"
	_focus_panel.custom_minimum_size.y = 330
	_focus_panel.add_theme_stylebox_override("panel", _style(Color("171a10")))
	column.add_child(_focus_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	_focus_panel.add_child(row)
	_focus_preview = PreviewScript.new()
	_focus_preview.custom_minimum_size = Vector2(198, 286)
	_focus_preview.inspection_requested.connect(_inspect_selected)
	row.add_child(_focus_preview)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 14)
	row.add_child(info)
	_focus_name = _label("", 28, INK)
	_focus_metadata = _label("", 20, GOLD)
	_focus_rules = _label("", 23, Color("d6c79d"))
	for item in [_focus_name, _focus_metadata, _focus_rules]:
		item.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		info.add_child(item)

func open_collection() -> void:
	card_detail.hide_detail()
	reset_filters()

func reset_filters() -> void:
	_resetting = true
	search_field.text = ""
	search_field.release_focus()
	type_filter.select(0)
	cost_filter.select(0)
	_resetting = false
	_apply_filters()

func _apply_filters() -> void:
	if _resetting:
		return
	var cost := cost_filter.selected if cost_filter.selected > 0 else -1
	visible_cards = Collection.cards_for_domain("forest", search_field.text, CARD_TYPES[type_filter.selected], cost)
	for child in card_grid.get_children():
		card_grid.remove_child(child)
		child.queue_free()
	for definition in visible_cards:
		_add_card(definition)
	_count.text = "CATÁLOGO · %d / 20" % visible_cards.size()
	_empty.visible = visible_cards.is_empty()
	card_scroll.visible = not visible_cards.is_empty()
	_focus_panel.visible = not visible_cards.is_empty()
	if not visible_cards.is_empty():
		var selected := visible_cards[0]
		for definition in visible_cards:
			if str(definition.get("id", "")) == selected_id:
				selected = definition
		_select_card(selected)
	card_scroll.set_deferred("scroll_vertical", 0)

func _add_card(definition: Dictionary) -> void:
	var tile := VBoxContainer.new()
	tile.name = str(definition.get("set_id", ""))
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_constant_override("separation", 4)
	card_grid.add_child(tile)
	var preview := PreviewScript.new()
	preview.name = "Preview"
	preview.custom_minimum_size = Vector2(220, 318)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.configure(definition)
	preview.inspection_requested.connect(func():
		_select_card(definition)
		card_detail.show_card(definition)
		search_field.release_focus())
	tile.add_child(preview)
	var title := _label(str(definition.get("name", "")), 20, INK)
	title.custom_minimum_size.y = 54
	tile.add_child(title)
	tile.add_child(_label("%s · %s" % [definition.get("set_id", ""), TextScript.type_label(definition)], 18, GOLD))

func _select_card(definition: Dictionary) -> void:
	selected_id = str(definition.get("id", ""))
	_focus_preview.configure(definition)
	_focus_name.text = str(definition.get("name", ""))
	_focus_metadata.text = TextScript.metadata(definition)
	_focus_rules.text = TextScript.rules_text(definition)

func _inspect_selected() -> void:
	for definition in visible_cards:
		if str(definition.get("id", "")) == selected_id:
			card_detail.show_card(definition)
			search_field.release_focus()
			return

func _cancel_card_gestures() -> void:
	for tile in card_grid.get_children():
		tile.get_node("Preview").cancel_pointer_gesture()

func _resize_columns() -> void:
	if is_instance_valid(card_grid):
		card_grid.columns = 3 if size.x >= 780 else 2

func handle_back() -> void:
	if card_detail.visible:
		card_detail.hide_detail()
	elif search_field.has_focus():
		search_field.release_focus()
	else:
		exit_requested.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		handle_back()
		get_viewport().set_input_as_handled()

func _style_button(button: Button) -> void:
	button.custom_minimum_size.y = 64
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_stylebox_override("normal", _style(Color("19170e")))
	button.add_theme_stylebox_override("hover", _style(Color("253720")))
	button.add_theme_stylebox_override("pressed", _style(Color("314b26")))
	if button is OptionButton:
		button.get_popup().add_theme_font_size_override("font_size", 28)
		button.get_popup().add_theme_constant_override("v_separation", 22)

func _style(background: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = Color("8e6b32")
	style.set_border_width_all(2)
	style.set_content_margin_all(14)
	style.set_corner_radius_all(5)
	return style

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
