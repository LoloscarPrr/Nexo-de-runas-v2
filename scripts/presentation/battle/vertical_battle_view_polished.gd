class_name VerticalBattleViewPolished
extends "res://scripts/presentation/battle/vertical_battle_view.gd"

## Capa visual sobre la batalla vertical funcional.
## Mantiene toda la interacción en la clase base y sólo cambia composición/render.

const BattleCardScript = preload("res://scripts/presentation/battle/vertical_battle_card.gd")
const BackdropScript = preload("res://scripts/presentation/battle/vertical_battle_backdrop.gd")

const BRASS := Color("b67b2f")
const BRASS_DARK := Color("5d3a18")
const FOREST_GREEN := Color("173b1f")
const FOREST_GLOW := Color("5ca643")
const PARCHMENT := Color("dfc88f")
const BLACK_GLASS := Color(0.03, 0.035, 0.025, 0.92)
const BLOOD_RED := Color("8b211d")

var rival_integrity_bar: ProgressBar
var _energy_pips: Label

func _build_view() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := BackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var veil := ColorRect.new()
	veil.color = Color(0, 0, 0, 0.10)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(veil)

	var outer := MarginContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("margin_left", 12)
	outer.add_theme_constant_override("margin_right", 12)
	outer.add_theme_constant_override("margin_top", 10)
	outer.add_theme_constant_override("margin_bottom", 12)
	add_child(outer)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 7)
	outer.add_child(root)

	root.add_child(_build_top_bar())
	root.add_child(_build_rival_header())
	root.add_child(_build_board())
	root.add_child(_build_hud())
	root.add_child(_build_hand())
	root.add_child(_build_footer())

func _build_top_bar() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 64)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color("140d08"), BRASS, 2, 10))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	frame.add_child(row)

	var back := Button.new()
	back.text = "‹"
	back.custom_minimum_size = Vector2(58, 56)
	back.focus_mode = Control.FOCUS_NONE
	back.add_theme_font_size_override("font_size", 30)
	back.add_theme_color_override("font_color", PARCHMENT)
	back.add_theme_stylebox_override("normal", _style(Color("24180d"), BRASS_DARK, 1, 8))
	back.add_theme_stylebox_override("pressed", _style(Color("171006"), BRASS, 2, 8))
	back.pressed.connect(func(): exit_requested.emit())
	row.add_child(back)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title := _label("NEXO DE RUNAS", 29, Color("f3c96b"), HORIZONTAL_ALIGNMENT_CENTER)
	title_box.add_child(title)
	var subtitle := _label("BATALLA DEL BOSQUE", 10, Color("8ead6e"), HORIZONTAL_ALIGNMENT_CENTER)
	title_box.add_child(subtitle)
	row.add_child(title_box)

	var gear := Button.new()
	gear.text = "⚙"
	gear.custom_minimum_size = Vector2(58, 56)
	gear.focus_mode = Control.FOCUS_NONE
	gear.add_theme_font_size_override("font_size", 25)
	gear.add_theme_color_override("font_color", Color("e68a3b"))
	gear.add_theme_stylebox_override("normal", _style(Color("24180d"), BRASS_DARK, 1, 8))
	gear.add_theme_stylebox_override("pressed", _style(Color("171006"), BRASS, 2, 8))
	row.add_child(gear)
	return frame

func _build_rival_header() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 138)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.04, 0.06, 0.035, 0.94), BRASS, 2, 14))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	frame.add_child(row)

	var crest := Label.new()
	crest.text = "♜"
	crest.custom_minimum_size = Vector2(92, 0)
	crest.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crest.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crest.add_theme_font_size_override("font_size", 42)
	crest.add_theme_color_override("font_color", Color("80d95b"))
	crest.add_theme_stylebox_override("normal", _style(Color("103019"), BRASS, 2, 44))
	row.add_child(crest)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	rival_name_label = _label("GUARDABOSQUES DEL UMBRAL", 21, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	info.add_child(rival_name_label)
	var cpu := _label("RIVAL CPU", 12, Color("d8a56d"), HORIZONTAL_ALIGNMENT_CENTER)
	info.add_child(cpu)

	rival_integrity_bar = ProgressBar.new()
	rival_integrity_bar.min_value = 0
	rival_integrity_bar.max_value = 20
	rival_integrity_bar.value = 20
	rival_integrity_bar.show_percentage = false
	rival_integrity_bar.custom_minimum_size = Vector2(0, 24)
	rival_integrity_bar.add_theme_stylebox_override("background", _style(Color("1a0908"), Color("5b271e"), 1, 6))
	rival_integrity_bar.add_theme_stylebox_override("fill", _style(Color("a62f24"), Color("e56a3f"), 1, 6))
	info.add_child(rival_integrity_bar)
	row.add_child(info)

	rival_integrity_label = _badge("20", BLOOD_RED, 32)
	rival_integrity_label.custom_minimum_size = Vector2(94, 90)
	row.add_child(rival_integrity_label)
	return frame

func _build_board() -> Control:
	var frame := PanelContainer.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.custom_minimum_size = Vector2(0, 650)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.035, 0.045, 0.03, 0.88), Color("76501f"), 2, 12))

	var board := VBoxContainer.new()
	board.add_theme_constant_override("separation", 5)
	frame.add_child(board)

	board.add_child(_lane_markers())

	var enemy_row := HBoxContainer.new()
	enemy_row.add_theme_constant_override("separation", 5)
	enemy_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
		var mark := _label("◇", 22, Color("d18b32"), HORIZONTAL_ALIGNMENT_CENTER)
		mark.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nexus.add_child(mark)
	board.add_child(nexus)

	var player_row := HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 5)
	player_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	row.custom_minimum_size = Vector2(0, 34)
	row.add_theme_constant_override("separation", 5)
	for lane in range(5):
		var marker := Label.new()
		marker.text = str(lane + 1)
		marker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		marker.add_theme_font_size_override("font_size", 15)
		marker.add_theme_color_override("font_color", Color("ffd078"))
		marker.add_theme_stylebox_override("normal", _style(Color("24150b"), BRASS, 2, 17))
		row.add_child(marker)
	return row

func _build_hud() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 132)
	frame.add_theme_stylebox_override("panel", _ornate_style(BLACK_GLASS, Color("70461d"), 2, 8))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 0)
	frame.add_child(grid)

	energy_label = _hud_cell("ENERGÍA RÚNICA\n◆ 1/1", Color("58e55d"))
	essence_label = _hud_cell("INSTINTO\n● 0/6", Color("e7b348"))
	seals_label = _hud_cell("SELLOS 0/3\nRELIQUIAS 0/2", Color("acd66f"))
	deck_label = _hud_cell("MAZO 16\nDESCARTE 0", Color("e5d6a6"))
	grid.add_child(energy_label)
	grid.add_child(essence_label)
	grid.add_child(seals_label)
	grid.add_child(deck_label)
	return frame

func _build_hand() -> Control:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(0, 330)
	frame.add_theme_stylebox_override("panel", _ornate_style(Color(0.025, 0.03, 0.02, 0.88), Color("5c3b19"), 2, 10))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	frame.add_child(stack)

	var title := _label("MANO", 14, Color("d9ab54"), HORIZONTAL_ALIGNMENT_CENTER)
	stack.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)

	hand_strip = HBoxContainer.new()
	hand_strip.add_theme_constant_override("separation", 8)
	hand_strip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_strip.alignment = BoxContainer.ALIGNMENT_CENTER
	scroll.add_child(hand_strip)
	return frame

func _build_footer() -> Control:
	var footer := HBoxContainer.new()
	footer.custom_minimum_size = Vector2(0, 132)
	footer.add_theme_constant_override("separation", 8)

	var player_badge := VBoxContainer.new()
	player_badge.custom_minimum_size = Vector2(126, 0)
	var you := _label("TÚ", 13, Color("d9c98e"), HORIZONTAL_ALIGNMENT_CENTER)
	player_badge.add_child(you)
	player_integrity_label = _badge("20", Color("155126"), 33)
	player_integrity_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	player_badge.add_child(player_integrity_label)
	footer.add_child(player_badge)

	var messages := VBoxContainer.new()
	messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	messages.add_theme_constant_override("separation", 2)
	status_label = _label("El Nexo aguarda tu jugada.", 14, PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	status_label.add_theme_stylebox_override("normal", _style(Color(0.02, 0.025, 0.018, 0.74), Color("59401e"), 1, 8))
	messages.add_child(status_label)
	event_label = _label("", 10, Color("9cac78"), HORIZONTAL_ALIGNMENT_CENTER)
	messages.add_child(event_label)
	footer.add_child(messages)

	impulse_button = Button.new()
	impulse_button.text = "+1\nIMPULSO"
	impulse_button.custom_minimum_size = Vector2(92, 0)
	impulse_button.focus_mode = Control.FOCUS_NONE
	impulse_button.add_theme_font_size_override("font_size", 11)
	impulse_button.add_theme_color_override("font_color", Color("d8f6c1"))
	impulse_button.add_theme_stylebox_override("normal", _ornate_style(Color("163721"), Color("67a457"), 2, 8))
	impulse_button.add_theme_stylebox_override("pressed", _ornate_style(Color("0f2918"), Color("9eea7a"), 3, 8))
	impulse_button.pressed.connect(_on_impulse_pressed)
	footer.add_child(impulse_button)

	end_turn_button = Button.new()
	end_turn_button.text = "FINALIZAR\nTURNO"
	end_turn_button.custom_minimum_size = Vector2(218, 0)
	end_turn_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.add_theme_font_size_override("font_size", 22)
	end_turn_button.add_theme_color_override("font_color", Color("fff0a8"))
	end_turn_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	end_turn_button.add_theme_stylebox_override("normal", _ornate_style(Color("17611f"), Color("d6a63b"), 3, 12))
	end_turn_button.add_theme_stylebox_override("hover", _ornate_style(Color("1e7628"), Color("f0ca55"), 3, 12))
	end_turn_button.add_theme_stylebox_override("pressed", _ornate_style(Color("104317"), Color("fff080"), 4, 12))
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
	essence_label.text = "%s\n● %d/%d" % [str(_snapshot.get("essence_name", "ESENCIA")).to_upper(), int(_snapshot.get("essence_current", 0)), int(_snapshot.get("essence_max", 0))]

func _energy_runes(current: int, capacity: int) -> String:
	var pips := ""
	for i in range(maxi(capacity, 1)):
		pips += "◆" if i < current else "◇"
	return pips

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
		if str(child.name).begins_with("UnitCard") or str(child.name).begins_with("EmptyMark"):
			button.remove_child(child)
			child.queue_free()

	var occupied := unit != null
	var base := Color("3a1512") if side == "enemy" else Color("102817")
	if not occupied:
		base = Color(0.025, 0.03, 0.02, 0.84)
	var border := Color("75cf54") if valid_target else (Color("915031") if side == "enemy" else Color("496d39"))
	button.add_theme_stylebox_override("normal", _ornate_style(base, border, 4 if valid_target else 2, 7))
	button.add_theme_stylebox_override("hover", _ornate_style(base.lightened(0.06), Color("d8a548") if not valid_target else Color("9af06b"), 3, 7))
	button.text = ""

	if occupied:
		var u: Dictionary = unit
		var card: Dictionary = session.card_definition(str(u.get("id", "")))
		if card.is_empty():
			card = u.duplicate(true)
		var visual = BattleCardScript.new()
		visual.name = "UnitCard%d" % lane
		visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		visual.offset_left = 4
		visual.offset_top = 4
		visual.offset_right = -4
		visual.offset_bottom = -4
		visual.configure(card, int(u.get("attack", 0)), int(u.get("hp", 0)), false, true, bool(u.get("ready", true)))
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(visual)
	else:
		var empty := Label.new()
		empty.name = "EmptyMark%d" % lane
		empty.text = "×"
		empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", 30)
		empty.add_theme_color_override("font_color", Color(0.62, 0.53, 0.34, 0.55))
		empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(empty)

func _lane_button(lane: int, side: String) -> Button:
	var button := Button.new()
	button.name = "%sLane%d" % [side.capitalize(), lane + 1]
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 224)
	button.focus_mode = Control.FOCUS_NONE
	button.clip_contents = true
	button.text = ""
	button.add_theme_stylebox_override("normal", _ornate_style(Color(0.025, 0.03, 0.02, 0.84), Color("4e4c2d"), 2, 7))
	return button

func _hud_cell(text_value: String, accent: Color) -> Label:
	var label := _label(text_value, 14, accent, HORIZONTAL_ALIGNMENT_CENTER)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(0, 110)
	label.add_theme_stylebox_override("normal", _ornate_style(Color(0.04, 0.035, 0.025, 0.92), Color(accent.r, accent.g, accent.b, 0.52), 1, 6))
	return label

func _ornate_style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := _style(bg, border, width, radius)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0, 2)
	style.anti_aliasing = true
	return style
