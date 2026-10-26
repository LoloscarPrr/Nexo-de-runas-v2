class_name VerticalBattleResult
extends Control

signal rematch_requested
signal board_requested
signal exit_requested

const OrnamentScript = preload("res://scripts/presentation/battle/vertical_battle_ornament.gd")
const Themes = preload("res://scripts/presentation/themes/domain_theme_registry.gd")
const GOLD := Color("d5a94f")
const INK := Color("eadca8")

var title_label: Label
var summary_label: Label
var nexus_label: Label
var _message: Label
var _frame: PanelContainer
var _crest

func _ready() -> void:
	name = "BattleResult"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.003, 0.006, 0.003, 0.90)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_frame = PanelContainer.new()
	_frame.name = "BattleResultFrame"
	_frame.custom_minimum_size.x = 720
	_frame.add_theme_stylebox_override("panel", _style(Color("171109"), GOLD, 3))
	center.add_child(_frame)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	_frame.add_child(column)
	column.add_child(_label("✦  NEXO DE RUNAS  ✦", 24, GOLD))
	column.add_child(_label("RESULTADO DE PARTIDA", 26, INK))
	var stage := CenterContainer.new()
	column.add_child(stage)
	_crest = OrnamentScript.new()
	_crest.custom_minimum_size = Vector2(180, 180)
	stage.add_child(_crest)
	title_label = _label("", 52, INK)
	title_label.name = "BattleResultTitle"
	column.add_child(title_label)
	_message = _label("", 25, INK)
	column.add_child(_message)
	summary_label = _label("", 23, Color("c8b887"))
	summary_label.name = "BattleResultSummary"
	column.add_child(summary_label)
	var stats := PanelContainer.new()
	stats.add_theme_stylebox_override("panel", _style(Color("0d130c"), Color("73532d"), 2))
	column.add_child(stats)
	nexus_label = _label("", 28, INK)
	nexus_label.name = "BattleResultNexus"
	stats.add_child(nexus_label)
	for choice in [["ResultRematch", "REVANCHA"], ["ResultReviewBoard", "VER TABLERO"], ["ResultReturnToMenu", "VOLVER AL MENÚ"]]:
		var button := Button.new()
		button.name = choice[0]
		button.text = choice[1]
		button.custom_minimum_size.y = 88
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 28)
		button.add_theme_color_override("font_color", INK)
		button.add_theme_stylebox_override("normal", _style(Color("183b1f") if choice[0] == "ResultRematch" else Color("24190e"), GOLD, 2))
		button.add_theme_stylebox_override("pressed", _style(Color("314b26"), INK, 3))
		match choice[0]:
			"ResultRematch": button.pressed.connect(func(): rematch_requested.emit())
			"ResultReviewBoard": button.pressed.connect(func(): board_requested.emit())
			"ResultReturnToMenu": button.pressed.connect(func(): exit_requested.emit())
		column.add_child(button)
	hide()

func show_result(state: Dictionary) -> void:
	var result := str(state.get("result", "ongoing"))
	if not ["victory", "defeat"].has(result):
		return
	var won := result == "victory"
	var accent := Color("97dc64") if won else Color("e56b4f")
	title_label.text = "VICTORIA" if won else "DERROTA"
	title_label.add_theme_color_override("font_color", accent)
	_message.text = "El Nexo rival ha caído." if won else "Tu Nexo ha caído. La manada puede volver a levantarse."
	var theme := Themes.get_theme(str(state.get("player_domain", "forest")))
	summary_label.text = "VS CPU · %s\nTURNO FINAL %d" % [theme.get("title"), int(state.get("turn", 1))]
	nexus_label.text = "TU NEXO  %d     ·     NEXO RIVAL  %d" % [maxi(0, int(state.get("player_integrity", 0))), maxi(0, int(state.get("enemy_integrity", 0)))]
	_crest.configure(OrnamentScript.Mode.PLAYER_NEXUS, accent)
	_frame.add_theme_stylebox_override("panel", _style(Color("171109"), GOLD if won else Color("a14f36"), 3))
	show()
	move_to_front()

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _style(background: Color, edge: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = edge
	style.set_border_width_all(width)
	style.set_content_margin_all(24)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 8
	return style
