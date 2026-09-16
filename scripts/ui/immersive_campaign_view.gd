extends "res://scripts/ui/campaign_view.gd"

const ImmersiveTableScript = preload("res://scripts/ui/battle_table.gd")
const ImmersiveCardScript = preload("res://scripts/ui/battle_card.gd")
const ImmersiveCatalogScript = preload("res://scripts/domain/card_catalog.gd")

const I_INK := Color8(232, 218, 180)
const I_MUTED := Color8(157, 139, 105)
const I_AMBER := Color8(188, 126, 57)
const I_BONE := Color8(207, 195, 158)
const I_EDGE := Color8(78, 55, 31)
const I_WOOD := Color8(37, 27, 18)

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
	var lane_width := clampf((vw - 515.0 - side_gap * 3.0) / 4.0, 150.0, 178.0)
	var lane_height := 170.0
	var board_width := lane_width * 4.0 + side_gap * 3.0
	var board_left := (vw - board_width) * 0.5
	var right_x := vw - 252.0

	_place(_label("LA MESA  /  TURNO %02d" % battle_state.turn, 20, I_INK, HORIZONTAL_ALIGNMENT_LEFT), Rect2(board_left, 30, board_width, 36))
	var leave := _small_button("‹ MAPA", 120)
	leave.pressed.connect(_show_map)
	_place(leave, Rect2(28, 27, 120, 44))

	# Left side: the scale and resources read as objects beside the table.
	_place(_label("BALANZA", 14, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(43, 193, 194, 28))
	_place(_label("%+d / 5" % battle_state.scale, 23, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(49, 405, 182, 34))
	_place(_label("HUESOS  %d" % battle_state.bones, 18, I_BONE, HORIZONTAL_ALIGNMENT_CENTER), Rect2(38, 452, 202, 34))
	var blood_cost: int = battle_state.blood_cost_for(selected_hand_index)
	var blood_text := "SANGRE  %d / %d" % [selected_sacrifices.size(), blood_cost] if blood_cost > 0 else "SANGRE  —"
	_place(_label(blood_text, 16, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(32, 489, 214, 34))

	# Guardian panel hugs the actual right edge on wide Android displays.
	_place(_label("EL GUARDIÁN", 14, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(right_x, 238, 228, 28))
	if battle_state.enemy_queue_index < battle_state.enemy_queue.size():
		var next_card := ImmersiveCatalogScript.find_by_id(battle_state.enemy_queue[battle_state.enemy_queue_index])
		_place(_label("SE ACERCA\n%s" % str(next_card.get("name", "")), 13, I_AMBER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(right_x, 274, 228, 50))

	# Four physical lanes. On wider phones they grow slightly but never become comically large.
	for lane in range(4):
		var x := board_left + float(lane) * (lane_width + side_gap)
		var enemy = battle_state.enemy_lanes[lane]
		_place(_immersive_slot(enemy, false, lane), Rect2(x, 104, lane_width, lane_height))
		var player = battle_state.player_lanes[lane]
		var player_slot := _immersive_slot(player, true, lane)
		player_slot.pressed.connect(_on_player_lane_pressed.bind(lane))
		_place(player_slot, Rect2(x, 294, lane_width, lane_height))
	_place(_label("SU LADO          ·          CUATRO CARRILES          ·          TU LADO", 11, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(board_left, 273, board_width, 20))

	var status_text: String = battle_state.last_message
	_place(_label(status_text, 15, I_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(board_left - 4, 468, board_width + 8, 51))

	# Draw piles stay separated and visible at all times.
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

	# Hand: larger cards, direct touch selection and a small physical lift from BattleCard.
	var hand_scroll := ScrollContainer.new()
	hand_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hand_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_place(hand_scroll, Rect2(board_left - 2, 526, board_width + 4, maxf(182.0, vh - 536.0)))
	var hand_row := HBoxContainer.new()
	hand_row.add_theme_constant_override("separation", 10)
	hand_scroll.add_child(hand_row)
	for index in range(battle_state.hand.size()):
		var card := ImmersiveCardScript.new()
		card.card = ImmersiveCatalogScript.find_by_id(battle_state.hand[index])
		card.chosen = index == selected_hand_index
		card.custom_minimum_size = Vector2(138, 178)
		card.disabled = battle_state.needs_draw()
		card.pressed.connect(_select_hand.bind(index))
		hand_row.add_child(card)
	if battle_state.hand.is_empty():
		hand_row.add_child(_label("Tu mano está vacía.", 16, I_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	if selected_hand_index >= 0:
		hand_scroll.set_deferred("scroll_horizontal", maxi(0, selected_hand_index * 148 - int(board_width * 0.4)))

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
