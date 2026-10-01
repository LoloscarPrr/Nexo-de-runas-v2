class_name VerticalBattleView
extends Control

signal exit_requested

## Primera Presentation vertical canónica de batalla.
## No conoce reglas del Domain: sólo consulta/ejecuta casos de uso mediante Application.

const SessionScript = preload("res://scripts/application/battle/canonical_battle_session.gd")

const BG := Color("090b07")
const PANEL := Color("17140d")
const PANEL_2 := Color("21190e")
const GOLD := Color("d5a94f")
const INK := Color("f0e0ad")
const MUTED := Color("aaa078")
const FOREST := Color("315b2a")
const FOREST_DARK := Color("172a17")
const ENEMY := Color("5a2721")
const TARGET := Color("6fa83e")
const EMPTY := Color("15160f")
const DANGER := Color("8d3428")

var session
var _snapshot: Dictionary = {}
var selected_hand_index := -1

var enemy_lane_buttons: Array[Button] = []
var player_lane_buttons: Array[Button] = []
var hand_strip: HBoxContainer

var rival_name_label: Label
var rival_integrity_label: Label
var player_integrity_label: Label
var energy_label: Label
var essence_label: Label
var seals_label: Label
var deck_label: Label
var status_label: Label
var event_label: Label
var end_turn_button: Button
var impulse_button: Button

func _ready() -> void:
	_build_view()
	visible = false

func start_battle(domain: String = "forest") -> void:
	if session == null:
		session = SessionScript.new()
	selected_hand_index = -1
	_snapshot = session.start_vs_cpu(domain)
	_render()
	visible = true

func current_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)

func _build_view() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 18)
	outer.add_theme_constant_override("margin_right", 18)
	outer.add_theme_constant_override("margin_top", 14)
	outer.add_theme_constant_override("margin_bottom", 16)
	add_child(outer)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	outer.add_child(root)

	root.add_child(_build_top_bar())
	root.add_child(_build_rival_header())
	root.add_child(_build_board())
	root.add_child(_build_hud())
	root.add_child(_build_hand())
	root.add_child(_build_footer())

func _build_top_bar() -> Control:
	var bar := HBoxContainer.new()
	bar.custom_minimum_size = Vector2(0, 56)
	bar.add_theme_constant_override("separation", 8)

	var back := Button.new()
	back.text = "‹"
	back.custom_minimum_size = Vector2(62, 54)
	back.focus_mode = Control.FOCUS_NONE
	back.add_theme_font_size_override("font_size", 30)
	back.add_theme_color_override("font_color", INK)
	back.add_theme_stylebox_override("normal", _style(PANEL, GOLD, 2, 10))
	back.pressed.connect(func(): exit_requested.emit())
	bar.add_child(back)

	var title := _label("NEXO DE RUNAS", 26, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(title)

	var menu := Label.new()
	menu.text = "⚙"
	menu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu.custom_minimum_size = Vector2(62, 54)
	menu.add_theme_font_size_override("font_size", 28)
	menu.add_theme_color_override("font_color", INK)
	bar.add_child(menu)
	return bar

func _build_rival_header() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 124)
	frame.add_theme_stylebox_override("panel", _style(Color("12150f"), GOLD, 2, 14))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	frame.add_child(row)

	var crest := _label("♜", 34, Color("8fcb65"), HORIZONTAL_ALIGNMENT_CENTER)
	crest.custom_minimum_size = Vector2(76, 0)
	row.add_child(crest)

	rival_name_label = _label("GUARDABOSQUES DEL UMBRAL\nRival CPU", 21, INK, HORIZONTAL_ALIGNMENT_LEFT)
	rival_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rival_name_label)

	rival_integrity_label = _badge("20", ENEMY, 34)
	rival_integrity_label.custom_minimum_size = Vector2(96, 86)
	row.add_child(rival_integrity_label)
	return frame

func _build_board() -> Control:
	var frame := PanelContainer.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.custom_minimum_size = Vector2(0, 540)
	frame.add_theme_stylebox_override("panel", _style(Color("11130d"), Color("5d512e"), 2, 14))

	var board := VBoxContainer.new()
	board.add_theme_constant_override("separation", 8)
	frame.add_child(board)

	var enemy_title := _label("CARRILES DEL RIVAL", 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	board.add_child(enemy_title)
	var enemy_row := HBoxContainer.new()
	enemy_row.add_theme_constant_override("separation", 8)
	board.add_child(enemy_row)
	for lane in range(5):
		var lane_index := lane
		var button := _lane_button(lane, "enemy")
		button.pressed.connect(func(): _on_lane_pressed("enemy", lane_index))
		enemy_lane_buttons.append(button)
		enemy_row.add_child(button)

	var nexus := HBoxContainer.new()
	nexus.custom_minimum_size = Vector2(0, 34)
	for lane in range(5):
		var mark := _label("◆ %d ◆" % (lane + 1), 12, Color("8c7a3c"), HORIZONTAL_ALIGNMENT_CENTER)
		mark.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nexus.add_child(mark)
	board.add_child(nexus)

	var player_row := HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 8)
	board.add_child(player_row)
	for lane in range(5):
		var lane_index := lane
		var button := _lane_button(lane, "player")
		button.pressed.connect(func(): _on_lane_pressed("player", lane_index))
		player_lane_buttons.append(button)
		player_row.add_child(button)

	var player_title := _label("TUS CARRILES", 13, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	board.add_child(player_title)
	return frame

func _build_hud() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 138)
	frame.add_theme_stylebox_override("panel", _style(PANEL_2, Color("72582c"), 2, 12))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 4)
	frame.add_child(grid)

	energy_label = _hud_cell("ENERGÍA RÚNICA\n1/1", Color("72df73"))
	essence_label = _hud_cell("ESENCIA\n0", Color("e2bc5a"))
	seals_label = _hud_cell("SELLOS 0/3\nRELIQUIAS 0/2", Color("b8d783"))
	deck_label = _hud_cell("MAZO 16\nDESCARTE 0", INK)
	grid.add_child(energy_label)
	grid.add_child(essence_label)
	grid.add_child(seals_label)
	grid.add_child(deck_label)
	return frame

func _build_hand() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 310)
	frame.add_theme_stylebox_override("panel", _style(Color("0f100b"), Color("4f4427"), 2, 14))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	frame.add_child(stack)

	var title := _label("MANO", 16, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	stack.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)

	hand_strip = HBoxContainer.new()
	hand_strip.add_theme_constant_override("separation", 10)
	hand_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(hand_strip)
	return frame

func _build_footer() -> Control:
	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 116)
	footer.add_theme_constant_override("separation", 10)

	var player_badge := VBoxContainer.new()
	player_badge.custom_minimum_size = Vector2(126, 0)
	var you := _label("TÚ", 14, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	player_badge.add_child(you)
	player_integrity_label = _badge("20", FOREST, 34)
	player_integrity_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	player_badge.add_child(player_integrity_label)
	footer.add_child(player_badge)

	var messages := VBoxContainer.new()
	messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label = _label("El Nexo aguarda tu jugada.", 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	messages.add_child(status_label)
	event_label = _label("", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	messages.add_child(event_label)
	footer.add_child(messages)

	impulse_button = Button.new()
	impulse_button.text = "+1\nIMPULSO"
	impulse_button.custom_minimum_size = Vector2(96, 0)
	impulse_button.focus_mode = Control.FOCUS_NONE
	impulse_button.add_theme_font_size_override("font_size", 12)
	impulse_button.add_theme_stylebox_override("normal", _style(Color("243327"), Color("77a86a"), 2, 10))
	impulse_button.pressed.connect(_on_impulse_pressed)
	footer.add_child(impulse_button)

	end_turn_button = Button.new()
	end_turn_button.text = "FINALIZAR\nTURNO"
	end_turn_button.custom_minimum_size = Vector2(220, 0)
	end_turn_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.add_theme_font_size_override("font_size", 21)
	end_turn_button.add_theme_color_override("font_color", Color("fff0b0"))
	end_turn_button.add_theme_stylebox_override("normal", _style(Color("1c4b22"), Color("b8a340"), 3, 12))
	end_turn_button.add_theme_stylebox_override("pressed", _style(Color("173818"), GOLD, 3, 12))
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	footer.add_child(end_turn_button)
	return footer

func _render() -> void:
	if _snapshot.is_empty():
		return
	rival_integrity_label.text = str(_snapshot.get("enemy_integrity", 0))
	player_integrity_label.text = str(_snapshot.get("player_integrity", 0))
	energy_label.text = "ENERGÍA RÚNICA\n%d/%d" % [int(_snapshot.get("energy_current", 0)), int(_snapshot.get("energy_capacity", 0))]
	essence_label.text = "%s\n%d/%d" % [str(_snapshot.get("essence_name", "ESENCIA")).to_upper(), int(_snapshot.get("essence_current", 0)), int(_snapshot.get("essence_max", 0))]
	seals_label.text = "SELLOS %d/3\nRELIQUIAS %d/2" % [Array(_snapshot.get("active_seals", [])).size(), Array(_snapshot.get("active_relics", [])).size()]
	deck_label.text = "MAZO %d\nDESCARTE %d" % [int(_snapshot.get("draw_count", 0)), Array(_snapshot.get("discard", [])).size()]
	impulse_button.visible = bool(_snapshot.get("impulse_available", false))
	end_turn_button.disabled = str(_snapshot.get("result", "ongoing")) != "ongoing"
	_refresh_lanes()
	_rebuild_hand()
	if not str(_snapshot.get("message", "")).is_empty():
		status_label.text = str(_snapshot.get("message", ""))

func _refresh_lanes() -> void:
	var enemy_units: Array = _snapshot.get("enemy_lanes", [])
	var player_units: Array = _snapshot.get("player_lanes", [])
	for lane in range(5):
		var enemy_unit = enemy_units[lane] if lane < enemy_units.size() else null
		var player_unit = player_units[lane] if lane < player_units.size() else null
		var enemy_valid := selected_hand_index >= 0 and session.can_target_enemy_lane(selected_hand_index, lane)
		var player_valid := selected_hand_index >= 0 and session.can_target_player_lane(selected_hand_index, lane)
		_set_lane_state(enemy_lane_buttons[lane], lane, "enemy", enemy_unit, enemy_valid)
		_set_lane_state(player_lane_buttons[lane], lane, "player", player_unit, player_valid)

func _rebuild_hand() -> void:
	for child in hand_strip.get_children():
		child.queue_free()
	var hand: Array = _snapshot.get("hand", [])
	for index in range(hand.size()):
		var card := session.hand_card_definition(index)
		var button := Button.new()
		button.name = "HandCard%d" % index
		button.custom_minimum_size = Vector2(178, 252)
		button.focus_mode = Control.FOCUS_NONE
		button.text = _card_text(card)
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", INK)
		var selected := index == selected_hand_index
		button.add_theme_stylebox_override("normal", _style(Color("252014") if not selected else Color("314527"), GOLD if selected else Color("75602f"), 3 if selected else 2, 12))
		button.add_theme_stylebox_override("hover", _style(Color("302919"), GOLD, 3, 12))
		var hand_index := index
		button.pressed.connect(func(): _on_hand_card_pressed(hand_index))
		hand_strip.add_child(button)

func _on_hand_card_pressed(index: int) -> void:
	if session == null:
		return
	if selected_hand_index == index:
		selected_hand_index = -1
		status_label.text = "Selección cancelada."
		_render()
		return
	selected_hand_index = index
	var card := session.hand_card_definition(index)
	status_label.text = "%s seleccionada." % str(card.get("name", "Carta"))
	var has_legal_target := false
	for lane in range(int(_snapshot.get("lane_count", 5))):
		has_legal_target = has_legal_target or session.can_target_player_lane(index, lane) or session.can_target_enemy_lane(index, lane)
	var card_type := str(card.get("type", ""))
	if (card_type == "rite" or card_type == "seal" or card_type == "relic") and not has_legal_target:
		var result := session.play_hand_card(index, -1)
		if bool(result.get("ok", false)):
			selected_hand_index = -1
		_apply_result(result)
		return
	_render()

func _on_lane_pressed(side: String, lane: int) -> void:
	if selected_hand_index < 0:
		var info := session.inspect_unit(side, lane)
		if info.is_empty():
			status_label.text = "Carril %d vacío." % (lane + 1)
		else:
			var unit: Dictionary = info.get("unit", {})
			status_label.text = "%s · %d ATQ · %d SAL" % [str(unit.get("name", "Unidad")), int(unit.get("attack", 0)), int(unit.get("hp", 0))]
		return
	var valid := session.can_target_player_lane(selected_hand_index, lane) if side == "player" else session.can_target_enemy_lane(selected_hand_index, lane)
	if not valid:
		status_label.text = "Ese carril no es un objetivo legal."
		return
	var result := session.play_hand_card(selected_hand_index, lane)
	if bool(result.get("ok", false)):
		selected_hand_index = -1
	_apply_result(result)

func _on_end_turn_pressed() -> void:
	if session == null:
		return
	selected_hand_index = -1
	_apply_result(session.end_round())

func _on_impulse_pressed() -> void:
	if session == null:
		return
	_apply_result(session.use_impulse())

func _apply_result(result: Dictionary) -> void:
	if result.has("snapshot"):
		_snapshot = Dictionary(result.get("snapshot", {})).duplicate(true)
	status_label.text = str(result.get("message", ""))
	_consume_events(Array(result.get("events", [])))
	_render()

func _consume_events(events: Array) -> void:
	if events.is_empty():
		event_label.text = ""
		return
	var readable: Array[String] = []
	for event in events.slice(maxi(0, events.size() - 3), events.size()):
		readable.append(_event_name(str((event as Dictionary).get("type", ""))))
	event_label.text = " · ".join(readable)
	var last: Dictionary = events[events.size() - 1]
	var payload: Dictionary = last.get("payload", {})
	var lane := int(payload.get("target_lane", payload.get("lane", -1)))
	var side := str(payload.get("target_side", payload.get("side", "")))
	if lane >= 0 and lane < 5 and (side == "player" or side == "enemy"):
		_pulse_lane(side, lane)

func _pulse_lane(side: String, lane: int) -> void:
	var buttons := player_lane_buttons if side == "player" else enemy_lane_buttons
	if lane < 0 or lane >= buttons.size():
		return
	var button: Button = buttons[lane]
	var tween := create_tween()
	tween.tween_property(button, "modulate", Color(1.35, 1.15, 0.65, 1.0), 0.08)
	tween.tween_property(button, "modulate", Color.WHITE, 0.18)

func _set_lane_state(button: Button, lane: int, side: String, unit, valid_target: bool) -> void:
	var occupied := unit != null
	if occupied:
		var u: Dictionary = unit
		button.text = "%d\n%s\n%d ATQ · %d SAL" % [lane + 1, str(u.get("name", "UNIDAD")), int(u.get("attack", 0)), int(u.get("hp", 0))]
	else:
		button.text = "%d\nCARRIL VACÍO" % (lane + 1)
	var base := ENEMY if side == "enemy" else FOREST_DARK
	if not occupied:
		base = EMPTY
	var border := TARGET if valid_target else (Color("8f5c3a") if side == "enemy" else Color("556d39"))
	button.add_theme_stylebox_override("normal", _style(base, border, 4 if valid_target else 2, 10))
	button.add_theme_stylebox_override("hover", _style(base.lightened(0.08), TARGET if valid_target else GOLD, 3, 10))
	button.add_theme_color_override("font_color", Color("eff0d0") if valid_target else INK)

func _lane_button(lane: int, side: String) -> Button:
	var button := Button.new()
	button.name = "%sLane%d" % [side.capitalize(), lane + 1]
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 210)
	button.focus_mode = Control.FOCUS_NONE
	button.text = "%d\nCARRIL VACÍO" % (lane + 1)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_stylebox_override("normal", _style(EMPTY, Color("4e4c2d"), 2, 10))
	return button

func _card_text(card: Dictionary) -> String:
	if card.is_empty():
		return "CARTA"
	var lines: Array[String] = []
	lines.append("◈ %d" % int(card.get("cost", 0)))
	lines.append(str(card.get("name", "CARTA")))
	if str(card.get("type", "")) == "creature":
		lines.append("%d ATQ  ·  %d SAL" % [int(card.get("attack", 0)), int(card.get("health", 0))])
	else:
		lines.append(str(card.get("type", "")).to_upper())
	var keywords := ""
	for keyword in Array(card.get("keywords", [])):
		if not keywords.is_empty():
			keywords += " · "
		keywords += str(keyword).replace("_", " ")
	if not keywords.is_empty():
		lines.append(keywords)
	return "\n".join(lines)

func _event_name(code: String) -> String:
	match code:
		"CARD_PLAYED": return "Carta jugada"
		"ABILITY_TRIGGERED": return "Habilidad"
		"EFFECT_APPLIED": return "Efecto"
		"UNIT_DIED": return "Unidad destruida"
		"RESOURCE_GAINED": return "Recurso ganado"
		"RESOURCE_SPENT": return "Recurso gastado"
		"TURN_STARTED": return "Nuevo turno"
		"BATTLE_ENDED": return "Fin de batalla"
		_: return code.replace("_", " ").capitalize()

func _hud_cell(text_value: String, accent: Color) -> Label:
	var label := _label(text_value, 15, accent, HORIZONTAL_ALIGNMENT_CENTER)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(0, 112)
	label.add_theme_stylebox_override("normal", _style(Color("17140e"), Color(accent, 0.55), 1, 8))
	return label

func _badge(text_value: String, color: Color, font_size: int) -> Label:
	var label := _label(text_value, font_size, Color("fff0bf"), HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_stylebox_override("normal", _style(color, GOLD, 3, 18))
	return label

func _label(text_value: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
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
