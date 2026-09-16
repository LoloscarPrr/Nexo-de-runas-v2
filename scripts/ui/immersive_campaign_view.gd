extends "res://scripts/ui/campaign_view.gd"

const ImmersiveTableScript = preload("res://scripts/ui/battle_table.gd")
const ImmersiveCardScript = preload("res://scripts/ui/battle_card.gd")
const ImmersiveCatalogScript = preload("res://scripts/domain/card_catalog.gd")
const CampaignBackdropScript = preload("res://scripts/ui/campaign_backdrop.gd")

const I_INK := Color8(232, 218, 180)
const I_MUTED := Color8(157, 139, 105)
const I_AMBER := Color8(188, 126, 57)
const I_BONE := Color8(207, 195, 158)
const I_EDGE := Color8(78, 55, 31)
const I_WOOD := Color8(37, 27, 18)
const I_PAPER := Color8(92, 74, 49)
const I_SUCCESS := Color8(118, 133, 80)

func _render_battle() -> void:
	_clear_screen()
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	var table := ImmersiveTableScript.new()
	table.balance = battle_state.scale
	table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(table)

	var side_gap := 10.0
	var lane_width := clampf((vw - 515.0 - side_gap * 3.0) / 4.0, 150.0, 198.0)
	var lane_height := 176.0
	var board_width := lane_width * 4.0 + side_gap * 3.0
	var board_left := (vw - board_width) * 0.5
	var right_x := vw - 252.0

	_place(_label("LA MESA  /  TURNO %02d" % battle_state.turn, 20, I_INK, HORIZONTAL_ALIGNMENT_LEFT), Rect2(board_left, 28, board_width, 36))
	var leave := _small_button("‹ MAPA", 120)
	leave.pressed.connect(_show_map)
	_place(leave, Rect2(28, 27, 120, 44))

	_place(_label("BALANZA", 14, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(43, 193, 194, 28))
	_place(_label("%+d / 5" % battle_state.scale, 23, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(49, 405, 182, 34))
	_place(_label("HUESOS  %d" % battle_state.bones, 18, I_BONE, HORIZONTAL_ALIGNMENT_CENTER), Rect2(38, 452, 202, 34))
	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_text := "SANGRE  %d / %d" % [selected_sacrifices.size(), blood_cost] if blood_cost > 0 else "SANGRE  —"
	_place(_label(blood_text, 16, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(32, 489, 214, 34))

	_place(_label("EL GUARDIÁN", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(right_x, 238, 228, 28))
	if battle_state.enemy_queue_index < battle_state.enemy_queue.size():
		var next_card := ImmersiveCatalogScript.find_by_id(battle_state.enemy_queue[battle_state.enemy_queue_index])
		_place(_label("SE ACERCA\n%s" % str(next_card.get("name", "")), 13, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(right_x, 274, 228, 50))

	for lane in range(4):
		var x := board_left + float(lane) * (lane_width + side_gap)
		var enemy = battle_state.enemy_lanes[lane]
		_place(_immersive_slot(enemy, false, lane), Rect2(x, 98, lane_width, lane_height))
		var player = battle_state.player_lanes[lane]
		var player_slot := _immersive_slot(player, true, lane)
		player_slot.pressed.connect(_on_player_lane_pressed.bind(lane))
		_place(player_slot, Rect2(x, 294, lane_width, lane_height))
	_place(_label("SU LADO          ·          CUATRO CARRILES          ·          TU LADO", 11, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(board_left, 274, board_width, 20))

	var status_text: String = battle_state.last_message
	_place(_label(status_text, 15, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(board_left - 4, 473, board_width + 8, 43))

	var draw_deck := _small_button("MAZO\n%d cartas" % battle_state.draw_pile.size(), 110)
	draw_deck.disabled = not battle_state.needs_draw() or battle_state.draw_pile.is_empty()
	draw_deck.pressed.connect(_draw_regular)
	_place(draw_deck, Rect2(right_x, 440, 110, 102))
	var squirrels := _small_button("ARDILLAS\n%d cartas" % battle_state.squirrel_pile_count, 110)
	squirrels.disabled = not battle_state.needs_draw() or battle_state.squirrel_pile_count <= 0
	squirrels.pressed.connect(_draw_squirrel)
	_place(squirrels, Rect2(right_x + 120, 440, 110, 102))
	if battle_state.needs_draw():
		_place(_label("ELIGE DE DÓNDE ROBAR", 12, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(right_x - 3, 548, 236, 28))

	var hand_scroll := ScrollContainer.new()
	hand_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hand_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(hand_scroll, Rect2(board_left - 4, 518, board_width + 8, maxf(194.0, vh - 526.0)))
	var hand_row := HBoxContainer.new()
	hand_row.add_theme_constant_override("separation", 7)
	hand_scroll.add_child(hand_row)
	for index in range(battle_state.hand.size()):
		var card := ImmersiveCardScript.new()
		card.card = ImmersiveCatalogScript.find_by_id(battle_state.hand[index])
		card.chosen = index == selected_hand_index
		card.custom_minimum_size = Vector2(150, 190)
		card.disabled = battle_state.needs_draw()
		card.pressed.connect(_select_hand.bind(index))
		hand_row.add_child(card)
	if battle_state.hand.is_empty():
		hand_row.add_child(_label("Tu mano está vacía.", 16, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if selected_hand_index >= 0:
		hand_scroll.set_deferred("scroll_horizontal", maxi(0, selected_hand_index * 157 - int(board_width * 0.4)))

	var cancel := _small_button("CANCELAR\nSACRIFICIOS", 192)
	cancel.disabled = selected_sacrifices.is_empty()
	cancel.pressed.connect(_cancel_sacrifices)
	_place(cancel, Rect2(44, 566, 194, 60))
	if not selected_sacrifices.is_empty():
		_place(_label("Las cartas marcadas aún no se consumen.", 11, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(30, 632, 222, 42))

	var bell := _small_button("CAMPANA\nTerminar turno", 228)
	bell.disabled = battle_state.needs_draw()
	bell.pressed.connect(_end_battle_turn)
	_place(bell, Rect2(right_x, 614, 230, 70))

func _show_map() -> void:
	if state == null:
		open_launcher()
		return
	_clear_screen()
	_add_campaign_backdrop("map")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	var back := _small_button("‹ MENÚ", 116)
	back.pressed.connect(_exit_to_menu)
	_place(back, Rect2(28, 24, 116, 44))
	_place(_label("EL MAPA SOBRE LA MESA", 26, I_INK, HORIZONTAL_ALIGNMENT_LEFT), Rect2(175, 24, 500, 38))
	_place(_label("MAZO %d  ·  VICTORIAS %d" % [state.deck_ids.size(), state.victories], 14, I_AMBER, HORIZONTAL_ALIGNMENT_RIGHT), Rect2(vw - 380, 28, 340, 34))
	_place(_label("La tinta no es un menú: es el sendero que queda sobre la madera.", 13, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 70, vw * 0.5, 30))

	var cx := vw * 0.5
	var top := 150.0
	var usable := maxf(430.0, vh - 245.0)
	var y0 := top
	var y1 := top + usable * 0.20
	var y2 := top + usable * 0.43
	var y3 := top + usable * 0.67
	var y4 := top + usable * 0.90
	var branch_offset := minf(270.0, vw * 0.18)
	_place(_physical_map_node("start", "LA SENDA"), Rect2(cx - 115, y0 - 24, 230, 48))
	_place(_physical_map_node("choice_left", "ELEGIR BESTIA"), Rect2(cx - branch_offset - 125, y1 - 25, 250, 50))
	_place(_physical_map_node("choice_right", "ELEGIR COSTE"), Rect2(cx + branch_offset - 125, y1 - 25, 250, 50))
	_place(_physical_map_node("battle_1", "COMBATE"), Rect2(cx - 125, y2 - 25, 250, 50))
	_place(_physical_map_node("campfire_1", "FOGATA"), Rect2(cx - 125, y3 - 25, 250, 50))
	_place(_physical_map_node("gate_1", "UMBRAL DEL JEFE"), Rect2(cx - 135, y4 - 26, 270, 52))

	var current: Dictionary = state.get_node(state.current_node)
	_place(_label("TU FIGURA ESTÁ EN: %s" % str(current.get("title", state.current_node)), 13, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.33, vh - 43, vw * 0.34, 28))

func _show_choice(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("choice")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("TRES CARTAS ESPERAN", 30, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 38, vw * 0.5, 42))
	_place(_label("Toma una. Las otras vuelven a la oscuridad.", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 78, vw * 0.5, 30))
	var ids: Array[String]
	if node_id == "choice_left":
		ids = ["gorrion", "puercoespin", "topo"]
	else:
		ids = ["zarigueya", "coyote", "vibora"]
	var card_w := 190.0
	var card_h := 260.0
	var gap := minf(90.0, vw * 0.05)
	var total := card_w * 3.0 + gap * 2.0
	var left := (vw - total) * 0.5
	for index in range(ids.size()):
		var view := _choice_card_button(ids[index], _claim_choice.bind(node_id, ids[index]))
		_place(view, Rect2(left + float(index) * (card_w + gap), vh * 0.30, card_w, card_h))
	var back := _small_button("VOLVER AL MAPA", 230)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw * 0.5 - 115, vh - 82, 230, 52))

func _show_campfire(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("campfire")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("UNA FOGATA ENTRE LOS ÁRBOLES", 30, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.22, 38, vw * 0.56, 44))
	_place(_label("Las figuras del otro lado del fuego miran tu mazo con demasiado interés.", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.24, 83, vw * 0.52, 34))
	var approach := _small_button("ACERCARTE AL FUEGO", 300)
	approach.pressed.connect(_resolve_simple_node.bind(node_id))
	approach.add_theme_stylebox_override("normal", _panel_style(Color(0.18, 0.09, 0.035, 0.88), I_AMBER, 2, 3))
	_place(approach, Rect2(vw * 0.5 - 155, vh - 132, 310, 54))
	var leave := _small_button("ALEJARTE", 220)
	leave.pressed.connect(_show_map)
	_place(leave, Rect2(vw * 0.5 - 110, vh - 70, 220, 44))

func _show_region_gate(node_id: String) -> void:
	_clear_screen()
	_add_campaign_backdrop("gate")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)
	_place(_label("ALGO TE ESPERA MÁS ADELANTE", 31, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.22, 42, vw * 0.56, 44))
	_place(_label("Desde la oscuridad llegan golpes de metal y una respiración que no es la tuya.", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.24, 88, vw * 0.52, 34))
	var enter := _small_button("ACERCARTE AL UMBRAL", 320)
	enter.pressed.connect(_resolve_simple_node.bind(node_id))
	enter.add_theme_stylebox_override("normal", _panel_style(Color(0.08, 0.055, 0.035, 0.92), I_AMBER, 2, 3))
	_place(enter, Rect2(vw * 0.5 - 160, vh - 127, 320, 54))
	var back := _small_button("VOLVER AL MAPA", 230)
	back.pressed.connect(_show_map)
	_place(back, Rect2(vw * 0.5 - 115, vh - 66, 230, 44))

func _physical_map_node(node_id: String, text_value: String) -> Button:
	var button := _small_button(text_value, 0)
	button.add_theme_font_size_override("font_size", 13)
	var is_current: bool = state != null and state.current_node == node_id
	var is_resolved: bool = state != null and state.resolved_nodes.has(node_id)
	var accessible: bool = state != null and state.can_enter(node_id)
	if is_current:
		button.text = "●  %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(I_PAPER, I_AMBER, 3, 3))
		button.add_theme_color_override("font_disabled_color", I_INK)
	elif is_resolved:
		button.text = "×  %s" % text_value
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.09, 0.065, 0.04, 0.82), I_SUCCESS, 2, 3))
	elif accessible:
		button.pressed.connect(_enter_node.bind(node_id))
		button.add_theme_stylebox_override("normal", _panel_style(Color(0.16, 0.12, 0.075, 0.92), I_AMBER, 2, 3))
		button.add_theme_stylebox_override("pressed", _panel_style(I_PAPER, I_AMBER, 3, 3))
	else:
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.055, 0.04, 0.027, 0.72), I_EDGE, 1, 3))
	return button

func _add_campaign_backdrop(mode_name: String) -> void:
	var backdrop := CampaignBackdropScript.new()
	backdrop.mode = mode_name
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	move_child(backdrop, 0)

func _immersive_slot(unit, player_side: bool, lane: int) -> Button:
	if unit != null:
		var card := ImmersiveCardScript.new()
		card.card = ImmersiveCatalogScript.find_by_id(str(unit.get("id", "")))
		card.current_hp = int(unit.get("hp", 1))
		card.marked = player_side and selected_sacrifices.has(lane)
		card.disabled = not player_side or battle_state.needs_draw()
		return card

	var marks := ["I", "II", "III", "IV"]
	var slot := _small_button(marks[lane], 0)
	slot.disabled = not player_side or battle_state.needs_draw()
	slot.add_theme_color_override("font_color", I_MUTED)
	slot.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.024, 0.014, 0.34), I_EDGE, 2, 4))
	slot.add_theme_stylebox_override("disabled", _panel_style(Color(0.035, 0.024, 0.014, 0.34), I_EDGE, 2, 4))
	if player_side and selected_hand_index >= 0 and battle_state.can_play(selected_hand_index, lane, selected_sacrifices).is_empty():
		slot.text = "COLOCAR"
		slot.add_theme_color_override("font_color", I_INK)
		slot.add_theme_stylebox_override("normal", _panel_style(I_WOOD, I_AMBER, 3, 4))
	return slot
