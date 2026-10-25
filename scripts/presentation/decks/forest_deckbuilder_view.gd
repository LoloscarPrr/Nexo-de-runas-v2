class_name ForestDeckbuilderView
extends "res://scripts/presentation/collection/forest_collection_view.gd"

signal deck_saved
signal battle_requested

const DeckEditorScript = preload("res://scripts/application/decks/forest_deck_editor.gd")
const CurveScript = preload("res://scripts/presentation/decks/deck_cost_curve.gd")

var editor: DeckEditorScript
var name_field: LineEdit
var deck_count: Label
var deck_status: Label
var save_button: Button
var play_button: Button
var in_deck_button: Button
var cost_curve

func _ready() -> void:
	super._ready()
	name = "ForestDeckbuilder"
	find_child("CatalogHeading", true, false).text = "CONSTRUCTOR DE MAZOS"
	_refresh_summary()

func _build_focus(column: VBoxContainer) -> void:
	_focus_panel = PanelContainer.new()
	_focus_panel.name = "DeckSummary"
	_focus_panel.custom_minimum_size.y = 380
	_focus_panel.add_theme_stylebox_override("panel", _style(Color("171a10")))
	column.add_child(_focus_panel)
	var summary := VBoxContainer.new()
	summary.add_theme_constant_override("separation", 10)
	_focus_panel.add_child(summary)
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 12)
	summary.add_child(name_row)
	name_field = LineEdit.new()
	name_field.name = "DeckName"
	name_field.placeholder_text = "Nombre del mazo"
	name_field.max_length = 32
	name_field.custom_minimum_size.y = 64
	name_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_field.add_theme_font_size_override("font_size", 24)
	name_field.add_theme_color_override("font_color", INK)
	name_field.add_theme_stylebox_override("normal", _style(Color("10160e")))
	name_field.add_theme_stylebox_override("focus", _style(Color("21351a")))
	name_field.text = str(editor.snapshot().get("name"))
	name_field.text_changed.connect(func(value: String):
		editor.set_name(value)
		_refresh_summary())
	name_row.add_child(name_field)
	deck_count = _label("", 32, INK)
	deck_count.name = "DeckCount"
	deck_count.custom_minimum_size.x = 125
	deck_count.autowrap_mode = TextServer.AUTOWRAP_OFF
	name_row.add_child(deck_count)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 12)
	summary.add_child(tools)
	var starter := Button.new()
	starter.name = "RestoreStarterDeck"
	starter.text = "MAZO INICIAL"
	_style_button(starter)
	starter.pressed.connect(func():
		editor.restore_starter()
		name_field.text = str(editor.snapshot().get("name"))
		_apply_filters()
		_refresh_summary())
	tools.add_child(starter)
	in_deck_button = Button.new()
	in_deck_button.name = "OnlyCardsInDeck"
	in_deck_button.text = "VER EN MAZO"
	in_deck_button.toggle_mode = true
	_style_button(in_deck_button)
	in_deck_button.toggled.connect(func(_pressed: bool): _apply_filters())
	tools.add_child(in_deck_button)
	cost_curve = CurveScript.new()
	cost_curve.name = "DeckCostCurve"
	cost_curve.custom_minimum_size.y = 80
	summary.add_child(cost_curve)
	deck_status = _label("", 20, INK)
	deck_status.name = "DeckStatus"
	deck_status.custom_minimum_size.y = 34
	summary.add_child(deck_status)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	summary.add_child(actions)
	save_button = Button.new()
	save_button.name = "SaveForestDeck"
	save_button.text = "GUARDAR"
	_style_button(save_button)
	save_button.pressed.connect(func(): _save(false))
	actions.add_child(save_button)
	play_button = Button.new()
	play_button.name = "PlayForestDeck"
	play_button.text = "GUARDAR Y JUGAR"
	_style_button(play_button)
	play_button.pressed.connect(func(): _save(true))
	actions.add_child(play_button)

func open_editor() -> void:
	card_detail.hide_detail()
	_refresh_cards()
	_refresh_summary()

func reset_filters() -> void:
	if in_deck_button != null:
		in_deck_button.set_pressed_no_signal(false)
	super.reset_filters()

func _catalog_definitions() -> Array[Dictionary]:
	var definitions := super._catalog_definitions()
	if in_deck_button != null and in_deck_button.button_pressed:
		var included: Array[Dictionary] = []
		for card in definitions:
			if int(editor.card_state(str(card.get("id"))).get("quantity")) > 0:
				included.append(card)
		return included
	return definitions

func _apply_filters() -> void:
	super._apply_filters()
	_focus_panel.show()
	_refresh_cards()
	_refresh_summary()

func _select_card(definition: Dictionary) -> void:
	selected_id = str(definition.get("id", ""))

func _add_card(definition: Dictionary) -> void:
	super._add_card(definition)
	var tile := card_grid.get_child(card_grid.get_child_count() - 1)
	var quantity := HBoxContainer.new()
	quantity.name = "QuantityControls"
	quantity.add_theme_constant_override("separation", 6)
	tile.add_child(quantity)
	var card_id := str(definition.get("id"))
	for action in ["Remove", "Quantity", "Add"]:
		if action == "Quantity":
			var counter := _label("", 26, INK)
			counter.name = "Quantity"
			counter.autowrap_mode = TextServer.AUTOWRAP_OFF
			counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			quantity.add_child(counter)
		else:
			var button := Button.new()
			button.name = action
			button.text = "−" if action == "Remove" else "+"
			button.tooltip_text = "Quitar una copia" if action == "Remove" else "Añadir una copia"
			_style_button(button)
			button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			button.custom_minimum_size = Vector2(86, 80)
			button.add_theme_font_size_override("font_size", 34)
			button.pressed.connect(_change_quantity.bind(card_id, action == "Add"))
			quantity.add_child(button)

func _change_quantity(card_id: String, add: bool) -> void:
	name_field.release_focus()
	search_field.release_focus()
	var result := editor.add_card(card_id) if add else editor.remove_card(card_id)
	if in_deck_button.button_pressed:
		var scroll_position := card_scroll.scroll_vertical
		_apply_filters()
		card_scroll.set_deferred("scroll_vertical", scroll_position)
	else:
		_refresh_cards()
	_refresh_summary()
	if not result.get("ok", false):
		deck_status.text = str(result.get("message"))

func _refresh_cards() -> void:
	for tile in card_grid.get_children():
		var controls := tile.get_node("QuantityControls")
		var card_id := str(tile.get_node("Preview").card_view.card.get("id"))
		var state := editor.card_state(card_id)
		controls.get_node("Quantity").text = "%d/%d" % [state.get("quantity"), state.get("limit")]
		controls.get_node("Remove").disabled = not state.get("can_remove")
		controls.get_node("Add").disabled = not state.get("can_add")

func _refresh_summary() -> void:
	var state := editor.snapshot()
	deck_count.text = "%d / 20" % state.get("count")
	cost_curve.set_distribution(state.get("curve"))
	save_button.disabled = not state.get("can_save")
	play_button.disabled = not state.get("can_save")
	if not Array(state.get("errors")).is_empty():
		deck_status.text = str(state.get("errors")[0])
	elif not str(state.get("load_notice")).is_empty():
		deck_status.text = str(state.get("load_notice"))
	elif state.get("dirty"):
		deck_status.text = "Cambios sin guardar. Guarda para activar este mazo."
	elif state.get("has_saved"):
		deck_status.text = "Mazo guardado y activo en JUGAR."
	else:
		deck_status.text = "Guarda tu mazo para usarlo en JUGAR."

func _save(and_play: bool) -> void:
	name_field.release_focus()
	search_field.release_focus()
	var result := editor.save_deck()
	_refresh_summary()
	deck_status.text = str(result.get("message"))
	if result.get("ok", false):
		name_field.text = str(editor.snapshot().get("name"))
		deck_saved.emit()
		if and_play:
			battle_requested.emit()

func handle_back() -> void:
	if not card_detail.visible and name_field.has_focus():
		name_field.release_focus()
	else:
		super.handle_back()
