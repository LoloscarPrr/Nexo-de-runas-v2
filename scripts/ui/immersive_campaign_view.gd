extends "res://scripts/ui/campaign_view.gd"

const ImmersiveTableScript = preload("res://scripts/ui/battle_table.gd")
const ImmersiveCardScript = preload("res://scripts/ui/battle_card.gd")
const ImmersiveCatalogScript = preload("res://scripts/domain/card_catalog.gd")
const CampaignBackdropScript = preload("res://scripts/ui/campaign_backdrop.gd")

const I_INK := Color8(199, 213, 103)
const I_MUTED := Color8(113, 125, 67)
const I_AMBER := Color8(198, 218, 88)
const I_BONE := Color8(184, 187, 111)
const I_EDGE := Color8(76, 89, 40)
const I_WOOD := Color8(18, 25, 13)
const I_PAPER := Color8(118, 119, 65)
const I_SUCCESS := Color8(168, 187, 83)
const MOCK_GLOW := Color8(198, 218, 88)
const MOCK_INK := Color8(199, 205, 116)
const MOCK_MUTED := Color8(119, 128, 68)
const MOCK_PANEL := Color8(18, 24, 13)
const MOCK_EDGE := Color8(78, 91, 39)
const MOCK_PAPER := Color8(171, 166, 92)

func _render_battle() -> void:
	_clear_screen()
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1.0)
	var vh := maxf(viewport_size.y, 1.0)
	var s := minf(vw / 1536.0, vh / 864.0)
	var ox := (vw - 1536.0 * s) * 0.5
	var oy := (vh - 864.0 * s) * 0.5

	var table := ImmersiveTableScript.new()
	table.balance = battle_state.scale
	table.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(table)

	# Encabezado idéntico al lenguaje del mockup: título pequeño sobre el tablero.
	_place(_label("NEXO DE RUNAS", maxi(14, int(23 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(24, 12, 205, 36, s, ox, oy))
	var leave := _small_button("MAPA", int(82 * s))
	leave.pressed.connect(_show_map)
	_mock_button_style(leave, false)
	_place(leave, _mock_rect(214, 12, 82, 32, s, ox, oy))

	# Valores de la balanza bajo los platos.
	var left_weight := 2 + maxi(battle_state.scale, 0)
	var right_weight := 2 + maxi(-battle_state.scale, 0)
	_place(_label(str(left_weight), maxi(15, int(28 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(29, 183, 48, 42, s, ox, oy))
	_place(_label(str(right_weight), maxi(15, int(28 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(142, 183, 48, 42, s, ox, oy))

	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_text := "SANGRE  %d/%d" % [selected_sacrifices.size(), blood_cost] if blood_cost > 0 else "HUESOS  %d" % battle_state.bones
	_place(_label(blood_text, maxi(12, int(20 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(28, 536, 170, 36, s, ox, oy))
	_place(_label("◆  ◆  ◆", maxi(13, int(22 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(38, 576, 150, 34, s, ox, oy))

	# Mensaje fijo del retrato derecho, como en la referencia.
	_place(_label("TODO\nVUELVE\nAL CICLO.", maxi(12, int(21 * s)), MOCK_INK, HORIZONTAL_ALIGNMENT_LEFT), _mock_rect(1344, 215, 144, 108, s, ox, oy))
	var turn_text := "ROBA CARTA" if battle_state.needs_draw() else "TU TURNO"
	_place(_label(turn_text, maxi(13, int(22 * s)), MOCK_GLOW, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(1338, 416, 154, 34, s, ox, oy))

	# Cuatro cartas del rival y cuatro del jugador, alineadas como la captura.
	var lane_x0 := 350.0
	var lane_pitch := 220.0
	var card_w := 198.0
	var card_h := 246.0
	for lane in range(4):
		var x := lane_x0 + float(lane) * lane_pitch
		var enemy = battle_state.enemy_lanes[lane]
		_place(_immersive_slot(enemy, false, lane), _mock_rect(x, 58, card_w, card_h, s, ox, oy))
		var player = battle_state.player_lanes[lane]
		var player_slot := _immersive_slot(player, true, lane)
		player_slot.pressed.connect(_on_player_lane_pressed.bind(lane))
		_place(player_slot, _mock_rect(x, 334, card_w, card_h, s, ox, oy))

	# Estado discreto sobre la mano, sin convertirlo en un HUD separado.
	_place(_label(battle_state.last_message, maxi(10, int(13 * s)), MOCK_MUTED, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(300, 603, 900, 27, s, ox, oy))

	# Mano física/abanicada. Sin ScrollContainer ni fila plana.
	var hand_count: int = battle_state.hand.size()
	if hand_count > 0:
		var hand_w := 170.0
		var hand_h := 210.0
		var step := 150.0
		if hand_count > 7:
			step = 900.0 / float(hand_count - 1)
		var total_w := hand_w + step * float(maxi(hand_count - 1, 0))
		var start_x := 768.0 - total_w * 0.5
		for index in range(hand_count):
			var card := ImmersiveCardScript.new()
			card.card = ImmersiveCatalogScript.find_by_id(battle_state.hand[index])
			card.chosen = index == selected_hand_index
			card.disabled = battle_state.needs_draw()
			card.pressed.connect(_select_hand.bind(index))
			var rel := float(index) - float(hand_count - 1) * 0.5
			var y := 645.0 + absf(rel) * 3.5
			if index == selected_hand_index:
				y -= 16.0
			_place(card, _mock_rect(start_x + float(index) * step, y, hand_w, hand_h, s, ox, oy))
			card.rotation = deg_to_rad(rel * 1.6)
	else:
		_place(_label("TU MANO ESTÁ VACÍA", maxi(12, int(18 * s)), MOCK_MUTED, HORIZONTAL_ALIGNMENT_CENTER), _mock_rect(570, 735, 400, 32, s, ox, oy))

	# Pilas de mazo en las esquinas inferiores. Son los propios objetivos táctiles.
	var draw_deck := _small_button("MAZO\n%d" % battle_state.draw_pile.size(), int(104 * s))
	draw_deck.disabled = not battle_state.needs_draw() or battle_state.draw_pile.is_empty()
	draw_deck.pressed.connect(_draw_regular)
	_mock_button_style(draw_deck, true)
	_place(draw_deck, _mock_rect(28, 696, 112, 128, s, ox, oy))

	var squirrels := _small_button("ARDILLAS\n%d" % battle_state.squirrel_pile_count, int(104 * s))
	squirrels.disabled = not battle_state.needs_draw() or battle_state.squirrel_pile_count <= 0
	squirrels.pressed.connect(_draw_squirrel)
	_mock_button_style(squirrels, true)
	_place(squirrels, _mock_rect(1396, 696, 112, 128, s, ox, oy))

	# Columna derecha: finalizar como botón grande de papel.
	var bell := _small_button("FINALIZAR", int(170 * s))
	bell.disabled = battle_state.needs_draw()
	bell.pressed.connect(_end_battle_turn)
	_mock_button_style(bell, false, true)
	_place(bell, _mock_rect(1330, 492, 170, 96, s, ox, oy))

	if not selected_sacrifices.is_empty():
		var cancel := _small_button("CANCELAR", int(160 * s))
		cancel.pressed.connect(_cancel_sacrifices)
		_mock_button_style(cancel, false)
		_place(cancel, _mock_rect(31, 618, 160, 46, s, ox, oy))

func _mock_rect(x: float, y: float, w: float, h: float, s: float, ox: float, oy: float) -> Rect2:
	return Rect2(ox + x * s, oy + y * s, w * s, h * s)

func _mock_button_style(button: Button, deck_style := false, paper_style := false) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 16 if not deck_style else 13)
	button.add_theme_color_override("font_color", Color("c7d669") if not paper_style else Color("0a0d07"))
	button.add_theme_color_override("font_disabled_color", Color("59612f"))
	if paper_style:
		button.add_theme_stylebox_override("normal", _panel_style(Color("aaa65c"), Color("11170d"), 3, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("c4bd70"), Color("c8d95b"), 4, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color("575832"), Color("30391d"), 2, 1))
	elif deck_style:
		button.add_theme_stylebox_override("normal", _panel_style(Color("11170d"), Color("697337"), 3, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("242e18"), Color("c8d95b"), 4, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.04, 0.055, 0.03, 0.65), Color("30391d"), 2, 1))
	else:
		button.add_theme_stylebox_override("normal", _panel_style(Color("0b1008"), Color("667035"), 2, 1))
		button.add_theme_stylebox_override("pressed", _panel_style(Color("1a2412"), Color("c8d95b"), 3, 1))
		button.add_theme_stylebox_override("disabled", _panel_style(Color("090d07"), Color("30391d"), 2, 1))

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
	approach.add_theme_stylebox_override("normal", _panel_style(Color(0.075, 0.095, 0.035, 0.92), I_AMBER, 2, 3))
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
	enter.add_theme_stylebox_override("normal", _panel_style(Color(0.035, 0.050, 0.025, 0.94), I_AMBER, 2, 3))
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
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.045, 0.065, 0.030, 0.88), I_SUCCESS, 2, 3))
	elif accessible:
		button.pressed.connect(_enter_node.bind(node_id))
		button.add_theme_stylebox_override("normal", _panel_style(Color(0.075, 0.095, 0.040, 0.94), I_AMBER, 2, 3))
		button.add_theme_stylebox_override("pressed", _panel_style(I_PAPER, I_AMBER, 3, 3))
	else:
		button.disabled = true
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.028, 0.040, 0.022, 0.78), I_EDGE, 1, 3))
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

	# Casilla vacía casi invisible: la madera/pata ya está dibujada por battle_table.gd.
	var slot := Button.new()
	slot.text = ""
	slot.focus_mode = Control.FOCUS_NONE
	slot.disabled = not player_side or battle_state.needs_draw()
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		slot.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	if player_side and selected_hand_index >= 0 and battle_state.can_play(selected_hand_index, lane, selected_sacrifices).is_empty():
		slot.text = "COLOCAR"
		slot.add_theme_font_size_override("font_size", 14)
		slot.add_theme_color_override("font_color", MOCK_GLOW)
		slot.add_theme_stylebox_override("normal", _panel_style(Color(0.05, 0.07, 0.035, 0.38), MOCK_EDGE, 2, 1))
	return slot
