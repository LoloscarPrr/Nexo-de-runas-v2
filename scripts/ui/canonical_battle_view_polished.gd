class_name CanonicalBattleViewPolished
extends CanonicalBattleView

## Ajustes de composición derivados de la prueba real en teléfono.
## Mantiene íntegro el motor y las interacciones del CanonicalBattleView base.

func _build_board() -> void:
	var board_frame := _panel(Color(0.045, 0.047, 0.025, 0.44), Color(0.34, 0.40, 0.17, 0.72), 2, 18)
	_place(board_frame, _board_rect)
	var inner := _panel(Color(0.10, 0.075, 0.035, 0.28), Color(0.46, 0.34, 0.14, 0.33), 1, 14)
	board_frame.add_child(inner)
	inner.position = Vector2(9, 9)
	inner.size = Vector2(_board_rect.size.x - 18, _board_rect.size.y - 18)

	var label_top := _label("SENDA DEL GUARDIÁN", 8, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	board_frame.add_child(label_top)
	label_top.position = Vector2(20, 7)
	label_top.size = Vector2(_board_rect.size.x - 40, 16)

	player_lanes.clear()
	enemy_lanes.clear()
	var gap := clampf(_board_rect.size.x * 0.018, 12.0, 19.0)
	var lane_w := (_board_rect.size.x - gap * 5.0) / 4.0
	var lane_h := 144.0
	for lane in range(4):
		var x := _board_rect.position.x + gap + float(lane) * (lane_w + gap)
		var enemy_slot := LaneScript.new()
		enemy_slot.set_lane(lane, false)
		enemy_slot.disabled = true
		enemy_lanes.append(enemy_slot)
		_place(enemy_slot, Rect2(x, 104, lane_w, lane_h))

		var player_slot := LaneScript.new()
		player_slot.set_lane(lane, true)
		var lane_index := lane
		player_slot.pressed.connect(func(): _on_player_lane_pressed(lane_index))
		player_lanes.append(player_slot)
		_place(player_slot, Rect2(x, 282, lane_w, lane_h))

	# Separador rúnico entre ambas filas. Sustituye el texto inferior que se
	# superponía a las cartas en la build probada en teléfono.
	for lane in range(4):
		var rx := _board_rect.position.x + gap + lane_w * 0.5 + float(lane) * (lane_w + gap)
		var rune := _label("◆", 13, Color(0.54, 0.64, 0.25, 0.52), HORIZONTAL_ALIGNMENT_CENTER)
		_place(rune, Rect2(rx - 18, 254, 36, 22))

func _build_support_rail(right_w: float) -> void:
	var x := _vw - right_w - 15
	var title := _plaque("VÍNCULOS DEL NEXO", 9)
	_place(title, Rect2(x, 80, right_w - 6, 34))

	deck_button = _stack_button("MAZO", 0)
	deck_button.pressed.connect(_show_deck_info)
	_place(deck_button, Rect2(x + 8, 125, (right_w - 30) * 0.5, 98))
	discard_button = _stack_button("DESCARTE", 0)
	discard_button.pressed.connect(_show_discard_info)
	_place(discard_button, Rect2(x + 18 + (right_w - 30) * 0.5, 125, (right_w - 30) * 0.5, 98))

	var seal_title := _label("SELLOS ACTIVOS", 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(seal_title, Rect2(x + 8, 232, right_w - 20, 18))
	for i in range(3):
		var p := _rune_socket()
		_place(p, Rect2(x + 18 + i * ((right_w - 48) / 3.0), 258, 42, 42))

	var relic_title := _label("RELIQUIAS", 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(relic_title, Rect2(x + 8, 312, right_w - 20, 18))
	for i in range(2):
		var p := _relic_socket()
		_place(p, Rect2(x + 27 + i * ((right_w - 68) / 2.0), 338, 58, 48))

	var turn_mark := _plaque("TU TURNO", 10)
	_place(turn_mark, Rect2(x + 22, 414, right_w - 44, 35))
	end_turn_button = _wood_button("FINALIZAR\nTURNO", 15)
	end_turn_button.add_theme_color_override("font_color", Color("ffe3a0"))
	end_turn_button.add_theme_stylebox_override("normal", _style(Color("38210e"), Color("b77e2b"), 3, 10))
	end_turn_button.add_theme_stylebox_override("pressed", _style(Color("4b180e"), DANGER, 3, 10))
	end_turn_button.pressed.connect(_on_end_turn)
	_place(end_turn_button, Rect2(x + 10, 464, right_w - 20, 110))

	var hint := _label("Toca una carta y después\nun carril iluminado", 8, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(hint, Rect2(x + 10, 586, right_w - 20, 40))

func _rebuild_hand() -> void:
	for child in hand_area.get_children():
		child.queue_free()
	var count := battle.hand.size()
	if count <= 0:
		return
	# Un poco más pequeñas que en v2: mejora lectura del conjunto y deja aire
	# inferior incluso con cinco o más cartas.
	var card_w := 132.0
	var card_h := 184.0
	var available := hand_area.size.x
	var step := card_w + 8.0
	if count > 1:
		step = minf(step, (available - card_w) / float(count - 1))
		step = maxf(76.0, step)
	var total := card_w + step * float(count - 1)
	var start_x := maxf(0.0, (available - total) * 0.5)
	for i in range(count):
		var card := Catalog.find_by_id(battle.hand[i])
		var view := CardScript.new()
		view.configure(card, -1, -1, i == selected_hand_index, false, true)
		var index := i
		view.pressed.connect(func(): _on_hand_card_pressed(index))
		hand_area.add_child(view)
		view.position = Vector2(start_x + float(i) * step, -8.0 if i == selected_hand_index else 6.0)
		view.size = Vector2(card_w, card_h)
		view.z_index = 20 if i == selected_hand_index else i
