class_name VerticalBattleViewPolished
extends "res://scripts/presentation/battle/vertical_battle_view.gd"

## Presentation vertical fiel al mockup aprobado.
## La composición central conserva las proporciones 864x1536; en teléfonos más
## altos el espacio adicional queda como escenario y no estira el tablero.

const BattleCardScript = preload("res://scripts/presentation/battle/vertical_battle_card.gd")
const BackdropScript = preload("res://scripts/presentation/battle/vertical_battle_backdrop.gd")
const LaneSlotScript = preload("res://scripts/presentation/battle/vertical_lane_slot.gd")

const BRASS := Color("b67b2f")
const BRASS_BRIGHT := Color("e2a446")
const BRASS_DARK := Color("5d3a18")
const FOREST_GREEN := Color("173b1f")
const FOREST_GLOW := Color("65d44b")
const PARCHMENT := Color("dfc88f")
const BLACK_GLASS := Color(0.025, 0.03, 0.02, 0.88)
const BLOOD_RED := Color("8b211d")
const FIRE_ORANGE := Color("e56f2d")

var rival_integrity_bar: ProgressBar

func _build_view() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := BackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.05)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 8)
	outer.add_theme_constant_override("margin_right", 8)
	add_child(outer)

	# En un móvil 20.5:9 el viewport virtual es más alto que 1536. Estos dos
	# spacers reparten esa altura extra sin deformar el contenido canónico.
	var stage := VBoxContainer.new()
	stage.add_theme_constant_override("separation", 0)
	outer.add_child(stage)

	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_child(top_spacer)

	var content := VBoxContainer.new()
	content.name = "MockupComposition"
	content.custom_minimum_size = Vector2(0, 1512)
	content.add_theme_constant_override("separation", 4)
	stage.add_child(content)

	content.add_child(_build_top_bar())
	content.add_child(_build_rival_header())
	content.add_child(_build_board())
	content.add_child(_build_hud())
	content.add_child(_build_hand())
	content.add_child(_build_footer())

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_child(bottom_spacer)

func _build_top_bar() -> Control:
	var scene := Control.new()
	scene.name = "ScenicHeader"
	scene.custom_minimum_size = Vector2(0, 178)

	# Logo grande arriba a la izquierda, tal como el bloque azul del mockup.
	var logo := PanelContainer.new()
	logo.name = "MockupLogo"
	logo.anchor_left = 0.015
	logo.anchor_top = 0.04
	logo.anchor_right = 0.375
	logo.anchor_bottom = 0.64
	logo.add_theme_stylebox_override("panel", _ornate_style(Color("170d08"), BRASS_BRIGHT, 3, 6))
	scene.add_child(logo)

	var logo_row := HBoxContainer.new()
	logo_row.add_theme_constant_override("separation", 4)
	logo.add_child(logo_row)
	logo_row.add_child(_label("◆", 25, FIRE_ORANGE, HORIZONTAL_ALIGNMENT_CENTER))
	var logo_text := _label("NEXO DE RUNAS", 27, Color("f2b65a"), HORIZONTAL_ALIGNMENT_CENTER)
	logo_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	logo_row.add_child(logo_text)
	logo_row.add_child(_label("◆", 25, FIRE_ORANGE, HORIZONTAL_ALIGNMENT_CENTER))

	# Engranaje circular arriba a la derecha, segundo bloque azul.
	var gear := Button.new()
	gear.name = "SettingsGear"
	gear.text = "⚙"
	gear.anchor_left = 0.89
	gear.anchor_top = 0.06
	gear.anchor_right = 0.985
	gear.anchor_bottom = 0.55
	gear.focus_mode = Control.FOCUS_NONE
	gear.add_theme_font_size_override("font_size", 35)
	gear.add_theme_color_override("font_color", Color("ff7a31"))
	gear.add_theme_color_override("font_pressed_color", Color("ffd38a"))
	gear.add_theme_stylebox_override("normal", _ornate_style(Color(0.03, 0.025, 0.018, 0.88), Color("c56b2f"), 3, 48))
	gear.add_theme_stylebox_override("pressed", _ornate_style(Color("23130a"), BRASS_BRIGHT, 4, 48))
	scene.add_child(gear)

	var subtitle := _label("BATALLA DEL BOSQUE", 11, Color("b9c88d"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.anchor_left = 0.39
	subtitle.anchor_top = 0.77
	subtitle.anchor_right = 0.61
	subtitle.anchor_bottom = 0.98
	scene.add_child(subtitle)
	return scene

func _build_rival_header() -> Control:
	var wrapper := HBoxContainer.new()
	wrapper.name = "RivalHeaderWrapper"
	wrapper.custom_minimum_size = Vector2(0, 138)
	wrapper.add_theme_constant_override("separation", 4)

	var left := Control.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.0
	wrapper.add_child(left)

	var frame := PanelContainer.new()
	frame.name = "RivalPanel"
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_stretch_ratio = 3.25
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.035, 0.045, 0.03, 0.95), BRASS_BRIGHT, 3, 12))
	wrapper.add_child(frame)

	var right := Control.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	wrapper.add_child(right)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	frame.add_child(row)

	var crest_panel := PanelContainer.new()
	crest_panel.custom_minimum_size = Vector2(78, 0)
	crest_panel.add_theme_stylebox_override("panel", _ornate_style(Color("0b351b"), Color("61be54"), 2, 40))
	var crest := _label("♣", 39, Color("b7f0a6"), HORIZONTAL_ALIGNMENT_CENTER)
	crest_panel.add_child(crest)
	row.add_child(crest_panel)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 1)
	rival_name_label = _label("GUARDABOSQUES DEL UMBRAL", 22, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	info.add_child(rival_name_label)
	var cpu := _label("RIVAL CPU", 13, Color("d8a56d"), HORIZONTAL_ALIGNMENT_CENTER)
	info.add_child(cpu)

	rival_integrity_bar = ProgressBar.new()
	rival_integrity_bar.min_value = 0
	rival_integrity_bar.max_value = 20
	rival_integrity_bar.value = 20
	rival_integrity_bar.show_percentage = false
	rival_integrity_bar.custom_minimum_size = Vector2(0, 22)
	rival_integrity_bar.add_theme_stylebox_override("background", _style(Color("180807"), Color("5b271e"), 1, 6))
	rival_integrity_bar.add_theme_stylebox_override("fill", _style(Color("b33428"), Color("ef6a40"), 1, 6))
	info.add_child(rival_integrity_bar)
	row.add_child(info)

	rival_integrity_label = _badge("20", BLOOD_RED, 36)
	rival_integrity_label.custom_minimum_size = Vector2(88, 92)
	row.add_child(rival_integrity_label)
	return wrapper

func _build_board() -> Control:
	var frame := PanelContainer.new()
	frame.name = "BoardFrame"
	frame.custom_minimum_size = Vector2(0, 598)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.03, 0.04, 0.025, 0.38), Color("a76428"), 4, 6))

	var board := VBoxContainer.new()
	board.add_theme_constant_override("separation", 4)
	frame.add_child(board)

	board.add_child(_lane_markers())

	var enemy_row := HBoxContainer.new()
	enemy_row.name = "EnemyLaneRow"
	enemy_row.custom_minimum_size = Vector2(0, 245)
	enemy_row.add_theme_constant_override("separation", 5)
	board.add_child(enemy_row)
	for lane in range(5):
		var lane_index := lane
		var button := _lane_button(lane, "enemy")
		button.pressed.connect(func(): _on_lane_pressed("enemy", lane_index))
		enemy_lane_buttons.append(button)
		enemy_row.add_child(button)

	var nexus := PanelContainer.new()
	nexus.custom_minimum_size = Vector2(0, 28)
	nexus.add_theme_stylebox_override("panel", _style(Color(0.05, 0.04, 0.025, 0.70), Color("8b5a24"), 1, 8))
	var nexus_mark := _label("◇     ✦     ◇     ✦     ◇", 18, Color("d88932"), HORIZONTAL_ALIGNMENT_CENTER)
	nexus.add_child(nexus_mark)
	board.add_child(nexus)

	var player_row := HBoxContainer.new()
	player_row.name = "PlayerLaneRow"
	player_row.custom_minimum_size = Vector2(0, 245)
	player_row.add_theme_constant_override("separation", 5)
	board.add_child(player_row)
	for lane in range(5):
		var lane_index := lane
		var button := _lane_button(lane, "player")
		button.pressed.connect(func(): _on_lane_pressed("player", lane_index))
		player_lane_buttons.append(button)
		player_row.add_child(button)

	board.add_child(_lane_markers())
	return frame

func _lane_markers() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.add_theme_constant_override("separation", 5)
	for lane in range(5):
		var marker_panel := PanelContainer.new()
		marker_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		marker_panel.add_theme_stylebox_override("panel", _style(Color("24140a"), BRASS_BRIGHT, 2, 12))
		var marker := _label(str(lane + 1), 16, Color("ffd078"), HORIZONTAL_ALIGNMENT_CENTER)
		marker_panel.add_child(marker)
		row.add_child(marker_panel)
	return row

func _build_hud() -> Control:
	var strip := HBoxContainer.new()
	strip.name = "HudStrip"
	strip.custom_minimum_size = Vector2(0, 116)
	strip.add_theme_constant_override("separation", 4)

	energy_label = _label("ENERGÍA RÚNICA\n◆ 1/1", 14, Color("66ec68"), HORIZONTAL_ALIGNMENT_CENTER)
	var energy_panel := _hud_module("◉", energy_label, Color("58e55d"), 1.22)
	strip.add_child(energy_panel)

	essence_label = _label("ESENCIA DEL DOMINIO\nINSTINTO", 14, Color("f1b94f"), HORIZONTAL_ALIGNMENT_CENTER)
	var essence_panel := _hud_module("●", essence_label, Color("e6a23a"), 1.08)
	strip.add_child(essence_panel)

	seals_label = _label("SELLOS ACTIVOS\n○  ○  ○", 14, Color("c4de75"), HORIZONTAL_ALIGNMENT_CENTER)
	var seals_panel := _hud_module("✦", seals_label, Color("94b85b"), 1.0)
	strip.add_child(seals_panel)

	deck_label = _label("MAZO 16\nDESCARTE 0", 14, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	var deck_panel := _hud_module("▣", deck_label, Color("b98543"), 0.82)
	strip.add_child(deck_panel)
	return strip

func _hud_module(icon_text: String, value_label: Label, accent: Color, ratio: float) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = ratio
	panel.add_theme_stylebox_override("panel", _ornate_style(Color(0.035, 0.03, 0.02, 0.93), Color(accent.r, accent.g, accent.b, 0.72), 2, 4))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	panel.add_child(row)
	var icon := _label(icon_text, 28, accent, HORIZONTAL_ALIGNMENT_CENTER)
	icon.custom_minimum_size = Vector2(52, 0)
	row.add_child(icon)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)
	return panel

func _build_hand() -> Control:
	var frame := PanelContainer.new()
	frame.name = "HandFrame"
	frame.custom_minimum_size = Vector2(0, 300)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.025, 0.025, 0.018, 0.28), Color("9c4f23"), 2, 5))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	frame.add_child(stack)

	var title := _label("MANO", 14, Color("e0ab50"), HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size = Vector2(0, 20)
	stack.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)

	hand_strip = HBoxContainer.new()
	hand_strip.add_theme_constant_override("separation", 6)
	hand_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_strip.alignment = BoxContainer.ALIGNMENT_CENTER
	scroll.add_child(hand_strip)
	return frame

func _build_footer() -> Control:
	var footer := HBoxContainer.new()
	footer.name = "BattleFooter"
	footer.custom_minimum_size = Vector2(0, 160)
	footer.add_theme_constant_override("separation", 8)

	# Nexo/vida del jugador: bloque amarillo circular del mockup.
	var nexus := PanelContainer.new()
	nexus.name = "PlayerNexus"
	nexus.custom_minimum_size = Vector2(184, 150)
	nexus.add_theme_stylebox_override("panel", _ornate_style(Color("0c3c1a"), Color("e2bb45"), 5, 76))
	var nexus_stack := VBoxContainer.new()
	nexus_stack.add_theme_constant_override("separation", -3)
	nexus.add_child(nexus_stack)
	var skull := _label("♠", 35, Color("d9c792"), HORIZONTAL_ALIGNMENT_CENTER)
	nexus_stack.add_child(skull)
	player_integrity_label = _label("20", 45, Color("fff0b1"), HORIZONTAL_ALIGNMENT_CENTER)
	player_integrity_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nexus_stack.add_child(player_integrity_label)
	var you := _label("JUGADOR 1", 11, Color("d6c493"), HORIZONTAL_ALIGNMENT_CENTER)
	nexus_stack.add_child(you)
	footer.add_child(nexus)

	var messages := VBoxContainer.new()
	messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	messages.add_theme_constant_override("separation", 2)
	status_label = _label("El Nexo aguarda tu jugada.", 13, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	messages.add_child(status_label)
	event_label = _label("", 10, Color("9cac78"), HORIZONTAL_ALIGNMENT_CENTER)
	messages.add_child(event_label)

	impulse_button = Button.new()
	impulse_button.name = "ImpulseButton"
	impulse_button.text = "+1 IMPULSO"
	impulse_button.custom_minimum_size = Vector2(110, 42)
	impulse_button.focus_mode = Control.FOCUS_NONE
	impulse_button.add_theme_font_size_override("font_size", 11)
	impulse_button.add_theme_color_override("font_color", Color("d8f6c1"))
	impulse_button.add_theme_stylebox_override("normal", _ornate_style(Color("163721"), Color("67a457"), 2, 8))
	impulse_button.add_theme_stylebox_override("pressed", _ornate_style(Color("0f2918"), Color("9eea7a"), 3, 8))
	impulse_button.pressed.connect(_on_impulse_pressed)
	messages.add_child(impulse_button)
	footer.add_child(messages)

	# Botón amarillo marcado: grande, verde y protagonista.
	end_turn_button = Button.new()
	end_turn_button.name = "EndTurnButton"
	end_turn_button.text = "FINALIZAR\nTURNO"
	end_turn_button.custom_minimum_size = Vector2(292, 146)
	end_turn_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.add_theme_font_size_override("font_size", 27)
	end_turn_button.add_theme_color_override("font_color", Color("fff1b0"))
	end_turn_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	end_turn_button.add_theme_stylebox_override("normal", _ornate_style(Color("17611f"), Color("e2b742"), 5, 10))
	end_turn_button.add_theme_stylebox_override("hover", _ornate_style(Color("1e7628"), Color("f4d35b"), 5, 10))
	end_turn_button.add_theme_stylebox_override("pressed", _ornate_style(Color("104317"), Color("fff080"), 6, 10))
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	footer.add_child(end_turn_button)
	return footer

func _render() -> void:
	super._render()
	if _snapshot.is_empty():
		return
	if rival_integrity_bar != null:
		rival_integrity_bar.value = int(_snapshot.get("enemy_integrity", 0))
	var energy_current := int(_snapshot.get("energy_current", 0))
	var energy_capacity := int(_snapshot.get("energy_capacity", 0))
	energy_label.text = "ENERGÍA RÚNICA\n%s  %d/%d" % [_energy_runes(energy_current, energy_capacity), energy_current, energy_capacity]
	essence_label.text = "ESENCIA DEL DOMINIO\n%s  %d/%d" % [str(_snapshot.get("essence_name", "ESENCIA")).to_upper(), int(_snapshot.get("essence_current", 0)), int(_snapshot.get("essence_max", 0))]
	var seal_count := Array(_snapshot.get("active_seals", [])).size()
	seals_label.text = "SELLOS ACTIVOS\n%s" % _seal_slots(seal_count)
	deck_label.text = "MAZO %d\nDESCARTE %d" % [int(_snapshot.get("draw_count", 0)), Array(_snapshot.get("discard", [])).size()]

func _energy_runes(current: int, capacity: int) -> String:
	var pips := ""
	for i in range(maxi(capacity, 1)):
		pips += "◆" if i < current else "◇"
	return pips

func _seal_slots(count: int) -> String:
	var result := ""
	for i in range(3):
		if i > 0:
			result += "  "
		result += "●" if i < count else "○"
	return result

func _rebuild_hand() -> void:
	for child in hand_strip.get_children():
		hand_strip.remove_child(child)
		child.queue_free()
	var hand: Array = _snapshot.get("hand", [])
	for index in range(hand.size()):
		var card: Dictionary = session.hand_card_definition(index)
		var visual = BattleCardScript.new()
		visual.name = "HandCard%d" % index
		visual.configure(card, -1, -1, index == selected_hand_index, false, true)
		var hand_index := index
		visual.pressed.connect(func(): _on_hand_card_pressed(hand_index))
		hand_strip.add_child(visual)

func _set_lane_state(button: Button, lane: int, side: String, unit, valid_target: bool) -> void:
	for child in button.get_children():
		button.remove_child(child)
		child.queue_free()

	var occupied := unit != null
	button.text = ""
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())

	var decor = LaneSlotScript.new()
	decor.name = "LaneDecor%d" % lane
	decor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	decor.configure(side, occupied, valid_target)
	button.add_child(decor)

	if occupied:
		var u: Dictionary = unit
		var card: Dictionary = session.card_definition(str(u.get("id", "")))
		if card.is_empty():
			card = u.duplicate(true)
		var visual = BattleCardScript.new()
		visual.name = "UnitCard%d" % lane
		visual.configure(card, int(u.get("attack", 0)), int(u.get("hp", 0)), false, true, bool(u.get("ready", true)))
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(visual)

func _lane_button(lane: int, side: String) -> Button:
	var button := Button.new()
	button.name = "%sLane%d" % [side.capitalize(), lane + 1]
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 245)
	button.focus_mode = Control.FOCUS_NONE
	button.clip_contents = false
	button.text = ""
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	return button

func _ornate_style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := _style(bg, border, width, radius)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	style.anti_aliasing = true
	return style
