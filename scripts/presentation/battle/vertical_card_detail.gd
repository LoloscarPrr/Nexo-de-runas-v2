class_name VerticalCardDetail
extends Control

## Modal portrait inspection. Data and live stats come from Application.
const CardScript = preload("res://scripts/presentation/battle/vertical_battle_card.gd")
const TextScript = preload("res://scripts/presentation/cards/card_text.gd")
const CARD_SIZE := Vector2(270, 395)

var card_view
var title_label: Label
var metadata_label: Label
var stats_label: Label
var effect_label: Label
var _holder: Control
var _card_stage: Control

func _ready() -> void:
	name = "VerticalCardDetail"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := Button.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.focus_mode = Control.FOCUS_NONE
	var shade_style := StyleBoxFlat.new()
	shade_style.bg_color = Color(0.005, 0.008, 0.004, 0.90)
	for state in ["normal", "hover", "pressed", "focus"]:
		shade.add_theme_stylebox_override(state, shade_style)
	shade.pressed.connect(hide_detail)
	add_child(shade)

	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = 36
	frame.offset_right = -36
	frame.offset_top = 80
	frame.offset_bottom = -80
	var style := StyleBoxFlat.new()
	style.bg_color = Color("171109")
	style.border_color = Color("b67b2f")
	style.set_border_width_all(3)
	style.set_content_margin_all(24)
	frame.add_theme_stylebox_override("panel", style)
	add_child(frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	frame.add_child(column)
	column.add_child(_label("DETALLE DE CARTA", 28, Color("d5a94f")))
	title_label = _label("", 30, Color("f0e0ad"))
	column.add_child(title_label)
	metadata_label = _label("", 22, Color("d5a94f"))
	column.add_child(metadata_label)
	_holder = Control.new()
	_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_holder)
	_card_stage = Control.new()
	_holder.add_child(_card_stage)
	card_view = CardScript.new()
	card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_stage.add_child(card_view)
	_holder.resized.connect(_layout_card)
	stats_label = _label("", 28, Color("f0e0ad"))
	column.add_child(stats_label)
	effect_label = _label("", 28, Color("dfc88f"))
	column.add_child(effect_label)
	var close := Button.new()
	close.name = "CloseDetail"
	close.text = "CERRAR"
	close.custom_minimum_size.y = 72
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_size_override("font_size", 26)
	close.add_theme_color_override("font_color", Color("f0e0ad"))
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color("173b1f")
	close_style.border_color = Color("d5a94f")
	close_style.set_border_width_all(2)
	close.add_theme_stylebox_override("normal", close_style)
	close.pressed.connect(hide_detail)
	column.add_child(close)
	visible = false

func show_card(card: Dictionary, attack: int = -1, health: int = -1, ready_state: bool = true) -> void:
	if card.is_empty():
		return
	card_view.configure(card, attack, health, false, false, ready_state)
	card_view.size = CARD_SIZE
	title_label.text = str(card.get("name", "CARTA"))
	metadata_label.text = TextScript.metadata(card)
	metadata_label.visible = not str(card.get("set_id", "")).is_empty()
	var creature := str(card.get("type", "")) == "creature"
	stats_label.text = "COSTE %d" % int(card.get("cost", 0))
	if creature:
		stats_label.text += "   ·   ATQ %d   ·   SAL %d" % [attack if attack >= 0 else int(card.get("attack", 0)), health if health >= 0 else int(card.get("health", 0))]
	effect_label.text = TextScript.rules_text(card)
	effect_label.visible = not effect_label.text.is_empty()
	visible = true
	move_to_front()
	_layout_card.call_deferred()

func hide_detail() -> void:
	visible = false

func _layout_card() -> void:
	var factor := minf(_holder.size.x / CARD_SIZE.x, _holder.size.y / CARD_SIZE.y)
	_card_stage.scale = Vector2.ONE * factor
	_card_stage.position = (_holder.size - CARD_SIZE * factor) * 0.5

func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_detail()
		get_viewport().set_input_as_handled()

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
