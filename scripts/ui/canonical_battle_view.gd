class_name CanonicalBattleView
extends Control

signal exit_requested

const BattleScript = preload("res://scripts/domain/canonical_cpu_battle.gd")
const Catalog = preload("res://scripts/domain/canonical_card_catalog.gd")
const BackdropScript = preload("res://scripts/ui/canonical_forest_battle_backdrop.gd")
const CardScript = preload("res://scripts/ui/canonical_forest_card.gd")
const LaneScript = preload("res://scripts/ui/canonical_forest_lane.gd")
const NexusScript = preload("res://scripts/ui/canonical_forest_nexus.gd")
const DetailScript = preload("res://scripts/ui/canonical_card_detail.gd")

const INK := Color("e5d8a1")
const MUTED := Color("9ba16d")
const GOLD := Color("d3aa4d")
const MOSS := Color("6f8740")
const DANGER := Color("873429")
const SELECT := Color("a9c755")

var battle: CanonicalCpuBattle
var selected_hand_index := -1

var player_lanes: Array = []
var enemy_lanes: Array = []
var hand_area: Control
var energy_label: Label
var essence_label: Label
var status_label: Label
var deck_button: Button
var discard_button: Button
var player_nexus
var enemy_nexus
var end_turn_button: Button
var result_overlay: Control
var card_detail: CanonicalCardDetail
var seal_sockets: Array[Panel] = []
var relic_sockets: Array[Panel] = []

var _vw := 1280.0
var _vh := 720.0
var _board_rect := Rect2()

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	start_battle()

func start_battle() -> void:
	battle = BattleScript.new()
	battle.setup_cpu_starter(Catalog.DOMAIN_FOREST)
	selected_hand_index = -1
	if card_detail != null:
		card_detail.hide_detail()
	if result_overlay != null:
		result_overlay.visible = false
	_refresh()

func _build_ui() -> void:
	_vw = maxf(get_viewport_rect().size.x, 1280.0)
	_vh = maxf(get_viewport_rect().size.y, 720.0)

	var backdrop := BackdropScript.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var vignette := ColorRect.new()
	vignette.color = Color(0.0, 0.0, 0.0, 0.10)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	var left_w := clampf(_vw * 0.13, 170.0, 205.0)
	var right_w := clampf(_vw * 0.145, 205.0, 236.0)
	_board_rect = Rect2(left_w + 26.0, 76.0, _vw - left_w - right_w - 58.0, 382.0)

	var exit := _wood_button("VOLVER", 14)
	exit.pressed.connect(func(): emit_signal("exit_requested"))
	_place(exit, Rect2(18, 18, 112, 43))

	var title := _label("BOSQUE SALVAJE", 25, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_place(title, Rect2(_vw * 0.5 - 220, 16, 440, 38))
	var subtitle := _label("EL NEXO RESPIRA ENTRE RAÍCES", 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(subtitle, Rect2(_vw * 0.5 - 210, 48, 420, 20))

	_build_nexus_rail(left_w)
	_build_board()
	_build_hand()
	_build_support_rail(right_w)

	status_label = _label("", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(status_label, Rect2(_board_rect.position.x + 70, 456, _board_rect.size.x - 140, 30))

	card_detail = DetailScript.new()
	add_child(card_detail)

	result_overlay = _build_result_overlay()
	result_overlay.visible = false
	add_child(result_overlay)

func _build_nexus_rail(left_w: float) -> void:
	var enemy_name := _plaque("GUARDIÁN DEL BOSQUE", 12)
	_place(enemy_name, Rect2(20, 74, left_w - 24, 39))

	enemy_nexus = NexusScript.new()
	enemy_nexus.caption = "NEXO RIVAL"
	enemy_nexus.hostile = true
	_place(enemy_nexus, Rect2(16, 108, left_w - 16, 174))

	player_nexus = NexusScript.new()
	player_nexus.caption = "TU NEXO"
	_place(player_nexus, Rect2(16, 286, left_w - 16, 178))

	# El panel izquierdo queda dedicado sólo a los recursos de turno. Los Sellos y
	# Reliquias viven físicamente a la derecha para evitar información duplicada.
	var resources := _panel(Color(0.055, 0.05, 0.028, 0.82), Color(0.35, 0.42, 0.18, 0.76), 2, 12)
	_place(resources, Rect2(22, 488, left_w - 28, 150))
	var cap := _label("RUNAS DEL VIAJERO", 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	resources.add_child(cap)
	cap.position = Vector2(8, 8)
	cap.size = Vector2(resources.size.x - 16, 22)

	energy_label = _label("", 14, INK, HORIZONTAL_ALIGNMENT_LEFT)
	resources.add_child(energy_label)
	energy_label.position = Vector2(14, 42)
	energy_label.size = Vector2(resources.size.x - 28, 34)

	essence_label = _label("", 14, INK, HORIZONTAL_ALIGNMENT_LEFT)
	resources.add_child(essence_label)
	essence_label.position = Vector2(14, 80)
	essence_label.size = Vector2(resources.size.x - 28, 34)

	var inspect_hint := _label("TOCA UNA CARTA JUGADA\nPARA INSPECCIONARLA", 8, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	inspect_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resources.add_child(inspect_hint)
	inspect_hint.position = Vector2(8, 116)
	inspect_hint.size = Vector2(resources.size.x - 16, 28)

func _build_board() -> void:
	var board_frame := _panel(Color(0.045, 0.047, 0.025, 0.44), Color(0.34, 0.40, 0.17, 0.72), 2, 18)
	_place(board_frame, _board_rect)
	var inner := _panel(Color(0.10, 0.075, 0.035, 0.28), Color(0.46, 0.34, 0.14, 0.33), 1, 14)
	board_frame.add_child(inner)
	inner.position = Vector2(9, 9)
	inner.size = Vector2(_board_rect.size.x - 18, _board_rect.size.y - 18)

	var label_top := _label("SENDA DEL GUARDIÁN", 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	board_frame.add_child(label_top)
	label_top.position = Vector2(20, 8)
	label_top.size = Vector2(_board_rect.size.x - 40, 18)

	player_lanes.clear()
	enemy_lanes.clear()
	var gap := clampf(_board_rect.size.x * 0.018, 12.0, 19.0)
	var lane_w := (_board_rect.size.x - gap * 5.0) / 4.0
	var lane_h := 150.0

	for lane in range(4):
		var x := _board_rect.position.x + gap + float(lane) * (lane_w + gap)
		var lane_index := lane

		var enemy_slot := LaneScript.new()
		enemy_slot.set_lane(lane, false)
		enemy_slot.pressed.connect(func(): _on_enemy_lane_pressed(lane_index))
		enemy_lanes.append(enemy_slot)
		_place(enemy_slot, Rect2(x, 103, lane_w, lane_h))

		var player_slot := LaneScript.new()
		player_slot.set_lane(lane, true)
		player_slot.pressed.connect(func(): _on_player_lane_pressed(lane_index))
		player_lanes.append(player_slot)
		_place(player_slot, Rect2(x, 285, lane_w, lane_h + 7))

	for lane in range(4):
		var rx := _board_rect.position.x + gap + lane_w * 0.5 + float(lane) * (lane_w + gap)
		var rune := _label("◆", 15, Color(0.54, 0.64, 0.25, 0.58), HORIZONTAL_ALIGNMENT_CENTER)
		_place(rune, Rect2(rx - 20, 258, 40, 25))

func _build_hand() -> void:
	var shelf := _panel(Color(0.055, 0.045, 0.025, 0.58), Color(0.37, 0.29, 0.12, 0.48), 1, 12)
	_place(shelf, Rect2(_board_rect.position.x + 10, 490, _board_rect.size.x - 20, 218))
	var cap := _label("MANO", 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	shelf.add_child(cap)
	cap.position = Vector2(8, 3)
	cap.size = Vector2(shelf.size.x - 16, 18)

	hand_area = Control.new()
	hand_area.clip_contents = false
	shelf.add_child(hand_area)
	hand_area.position = Vector2(8, 17)
	hand_area.size = Vector2(shelf.size.x - 16, 198)

func _build_support_rail(right_w: float) -> void:
	var x := _vw - right_w - 15
	var title := _plaque("VÍNCULOS DEL NEXO", 10)
	_place(title, Rect2(x, 82, right_w - 6, 36))

	deck_button = _stack_button("MAZO", 0)
	deck_button.pressed.connect(_show_deck_info)
	_place(deck_button, Rect2(x + 8, 132, (right_w - 30) * 0.5, 104))

	discard_button = _stack_button("DESCARTE", 0)
	discard_button.pressed.connect(_show_discard_info)
	_place(discard_button, Rect2(x + 18 + (right_w - 30) * 0.5, 132, (right_w - 30) * 0.5, 104))

	seal_sockets.clear()
	relic_sockets.clear()

	var seal_title := _label("SELLOS ACTIVOS", 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(seal_title, Rect2(x + 8, 250, right_w - 20, 20))
	for i in range(3):
		var p := _rune_socket()
		_place(p, Rect2(x + 18 + i * ((right_w - 50) / 3.0), 274, 46, 46))
		seal_sockets.append(p)

	var relic_title := _label("RELIQUIAS ACTIVAS", 10, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	_place(relic_title, Rect2(x + 8, 334, right_w - 20, 20))
	for i in range(2):
		var p := _relic_socket()
		_place(p, Rect2(x + 30 + i * ((right_w - 74) / 2.0), 360, 62, 52))
		relic_sockets.append(p)

	var turn_mark := _plaque("TU TURNO", 11)
	_place(turn_mark, Rect2(x + 22, 438, right_w - 44, 37))

	end_turn_button = _wood_button("FINALIZAR\nTURNO", 16)
	end_turn_button.add_theme_color_override("font_color", Color("ffe3a0"))
	end_turn_button.add_theme_stylebox_override("normal", _style(Color("38210e"), Color("b77e2b"), 3, 10))
	end_turn_button.add_theme_stylebox_override("pressed", _style(Color("4b180e"), DANGER, 3, 10))
	end_turn_button.pressed.connect(_on_end_turn)
	_place(end_turn_button, Rect2(x + 10, 490, right_w - 20, 118))

	var hint := _label("Selecciona en la mano\ny toca un carril", 9, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(hint, Rect2(x + 10, 622, right_w - 20, 44))

func _refresh() -> void:
	if battle == null:
		return
	player_nexus.set_integrity(battle.player_integrity)
	enemy_nexus.set_integrity(battle.enemy_integrity)
	var energy_denominator := 12 if battle.energy_current > 6 else 6
	energy_label.text = "ENERGÍA   %d/%d" % [battle.energy_current, energy_denominator]
	essence_label.text = "INSTINTO   %d/%d" % [battle.essence_current, battle.essence_max()]
	deck_button.text = "MAZO\n%d" % battle.draw_pile.size()
	discard_button.text = "DESCARTE\n%d" % battle.discard_pile.size()
	status_label.text = battle.last_message if not battle.last_message.is_empty() else "Elige una carta. Los espacios válidos responderán con luz."

	for lane in range(4):
		var player_target := _is_valid_target_lane(lane)
		player_lanes[lane].set_unit(battle.player_lanes[lane], player_target)
		enemy_lanes[lane].set_unit(battle.enemy_lanes[lane], false)

	_rebuild_hand()
	_refresh_sockets()
	if battle.result != "ongoing":
		_show_result()

func _is_valid_target_lane(lane: int) -> bool:
	if selected_hand_index < 0 or selected_hand_index >= battle.hand.size():
		return false
	var card := Catalog.find_by_id(battle.hand[selected_hand_index])
	var card_type := str(card.get("type", ""))
	if card_type == Catalog.TYPE_CREATURE:
		return battle.player_lanes[lane] == null
	if card_type == Catalog.TYPE_RITE:
		var card_id := str(card.get("id", ""))
		if card_id == "crecimiento_violento":
			return battle.player_lanes[lane] != null
	return false

func _rebuild_hand() -> void:
	for child in hand_area.get_children():
		child.queue_free()
	var count := battle.hand.size()
	if count <= 0:
		return

	# La mano respira: con pocas cartas crecen; al llenarse se solapan suavemente.
	var card_w := 154.0
	var card_h := 194.0
	if count <= 2:
		card_w = 170.0
		card_h = 198.0
	elif count == 3:
		card_w = 162.0
		card_h = 198.0
	elif count >= 6:
		card_w = 136.0
		card_h = 188.0

	var available := hand_area.size.x
	var step := card_w + 10.0
	if count > 1:
		step = minf(step, (available - card_w) / float(count - 1))
		step = maxf(card_w * 0.58, step)
	var total := card_w + step * float(count - 1)
	var start_x := maxf(0.0, (available - total) * 0.5)

	for i in range(count):
		var card := Catalog.find_by_id(battle.hand[i])
		var view := CardScript.new()
		view.configure(card, -1, -1, i == selected_hand_index, false, true)
		var index := i
		view.pressed.connect(func(): _on_hand_card_pressed(index))
		hand_area.add_child(view)
		view.position = Vector2(start_x + float(i) * step, -14.0 if i == selected_hand_index else 3.0)
		view.size = Vector2(card_w, card_h)
		view.z_index = 30 if i == selected_hand_index else i

func _refresh_sockets() -> void:
	for i in range(seal_sockets.size()):
		var active := i < battle.active_seals.size()
		seal_sockets[i].modulate = Color.WHITE if active else Color(0.68, 0.68, 0.68, 0.72)
	for i in range(relic_sockets.size()):
		var active := i < battle.active_relics.size()
		relic_sockets[i].modulate = Color.WHITE if active else Color(0.68, 0.68, 0.68, 0.72)

func _on_hand_card_pressed(index: int) -> void:
	if index < 0 or index >= battle.hand.size():
		return
	var card := Catalog.find_by_id(battle.hand[index])
	var card_type := str(card.get("type", ""))

	if card_type == Catalog.TYPE_RELIC or card_type == Catalog.TYPE_SEAL:
		if battle.play_card(index):
			selected_hand_index = -1
			battle.last_message = "%s quedó vinculado al Nexo." % str(card.get("name", "La carta"))
		else:
			selected_hand_index = index
		_refresh()
		return

	if card_type == Catalog.TYPE_RITE and ["llamado_de_la_manada", "vision_prohibida"].has(str(card.get("id", ""))):
		if battle.play_card(index):
			battle.last_message = "%s responde al llamado." % str(card.get("name", "El rito"))
		selected_hand_index = -1
		_refresh()
		return

	selected_hand_index = -1 if selected_hand_index == index else index
	battle.last_message = "Seleccionada: %s" % str(card.get("name", "")) if selected_hand_index >= 0 else "Selección cancelada."
	_refresh()

func _on_player_lane_pressed(lane: int) -> void:
	# Sin carta seleccionada, tocar una criatura abre su ficha grande.
	if selected_hand_index < 0 or selected_hand_index >= battle.hand.size():
		if battle.player_lanes[lane] != null:
			_show_unit_detail(battle.player_lanes[lane])
		else:
			battle.last_message = "El carril %d está vacío." % (lane + 1)
			_refresh()
		return

	var card := Catalog.find_by_id(battle.hand[selected_hand_index])
	var card_type := str(card.get("type", ""))
	var success := false
	if card_type == Catalog.TYPE_CREATURE:
		success = battle.play_card(selected_hand_index, lane)
	elif card_type == Catalog.TYPE_RITE:
		success = battle.play_card(selected_hand_index, -1, lane)
	if success:
		selected_hand_index = -1
		battle.last_message = "La senda acepta tu jugada."
	_refresh()

func _on_enemy_lane_pressed(lane: int) -> void:
	if battle.enemy_lanes[lane] != null:
		_show_unit_detail(battle.enemy_lanes[lane])
	else:
		battle.last_message = "No hay criatura rival en el carril %d." % (lane + 1)
		_refresh()

func _show_unit_detail(unit: Dictionary) -> void:
	if card_detail == null or unit == null:
		return
	var card := Catalog.find_by_id(str(unit.get("id", "")))
	if card.is_empty():
		return
	card_detail.show_card(card, int(unit.get("attack", 0)), int(unit.get("hp", 0)), bool(unit.get("ready", false)))

func _on_end_turn() -> void:
	if battle.result != "ongoing":
		return
	selected_hand_index = -1
	if card_detail != null:
		card_detail.hide_detail()
	end_turn_button.disabled = true
	var before_player := battle.player_integrity
	var before_enemy := battle.enemy_integrity
	battle.advance_round()
	end_turn_button.disabled = false
	if battle.result == "ongoing":
		var delta_player := before_player - battle.player_integrity
		var delta_enemy := before_enemy - battle.enemy_integrity
		if delta_player > 0:
			battle.last_message = "El Nexo recibió %d de daño. Turno %d." % [delta_player, battle.turn]
		elif delta_enemy > 0:
			battle.last_message = "El Guardián perdió %d de Integridad. Turno %d." % [delta_enemy, battle.turn]
		else:
			battle.last_message = "Turno %d · la Energía Rúnica vuelve a fluir." % battle.turn
	_refresh()

func _show_deck_info() -> void:
	battle.last_message = "Mazo: %d cartas. Su orden permanece oculto." % battle.draw_pile.size()
	_refresh()

func _show_discard_info() -> void:
	if battle.discard_pile.is_empty():
		battle.last_message = "El Descarte está vacío."
	else:
		var names: Array[String] = []
		for card_id in battle.discard_pile:
			var card := Catalog.find_by_id(card_id)
			names.append(str(card.get("name", card_id)))
		battle.last_message = "Descarte: " + ", ".join(names)
	_refresh()

func _show_result() -> void:
	if card_detail != null:
		card_detail.hide_detail()
	result_overlay.visible = true
	var title: Label = result_overlay.get_node("Tablet/Title")
	var detail: Label = result_overlay.get_node("Tablet/Detail")
	if battle.result == "victory":
		title.text = "VICTORIA"
		detail.text = "Las raíces del Bosque reclamaron el Nexo rival."
	else:
		title.text = "DERROTA"
		detail.text = "Tu Nexo se quebró. El bosque guarda memoria de la caída."

func _build_result_overlay() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.008, 0.80)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)
	var tablet := _panel(Color("171209"), Color("9d7d39"), 4, 8)
	tablet.name = "Tablet"
	overlay.add_child(tablet)
	tablet.position = Vector2(_vw * 0.5 - 305, _vh * 0.5 - 155)
	tablet.size = Vector2(610, 310)
	var inner := _panel(Color(0.16, 0.12, 0.055, 0.70), Color(0.35, 0.42, 0.18, 0.80), 2, 6)
	tablet.add_child(inner)
	inner.position = Vector2(12, 12)
	inner.size = Vector2(586, 286)
	var title := _label("VICTORIA", 39, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	title.name = "Title"
	tablet.add_child(title)
	title.position = Vector2(30, 30)
	title.size = Vector2(550, 60)
	var detail := _label("", 15, INK, HORIZONTAL_ALIGNMENT_CENTER)
	detail.name = "Detail"
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tablet.add_child(detail)
	detail.position = Vector2(65, 104)
	detail.size = Vector2(480, 70)
	var retry := _wood_button("REINICIAR", 15)
	retry.pressed.connect(start_battle)
	tablet.add_child(retry)
	retry.position = Vector2(80, 214)
	retry.size = Vector2(190, 58)
	var leave := _wood_button("VOLVER AL MENÚ", 15)
	leave.pressed.connect(func(): emit_signal("exit_requested"))
	tablet.add_child(leave)
	leave.position = Vector2(340, 214)
	leave.size = Vector2(190, 58)
	return overlay

func _stack_button(label_text: String, count: int) -> Button:
	var b := Button.new()
	b.text = "%s\n%d" % [label_text, count]
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_stylebox_override("normal", _style(Color("19150d"), Color("79652f"), 2, 5))
	b.add_theme_stylebox_override("hover", _style(Color("221b0e"), GOLD, 3, 5))
	b.add_theme_stylebox_override("pressed", _style(Color("2b190d"), SELECT, 3, 5))
	return b

func _plaque(text_value: String, font_size: int) -> Panel:
	var p := _panel(Color(0.06, 0.052, 0.028, 0.88), Color(0.39, 0.43, 0.19, 0.78), 2, 6)
	var l := _label(text_value, font_size, INK, HORIZONTAL_ALIGNMENT_CENTER)
	p.add_child(l)
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return p

func _rune_socket() -> Panel:
	return _panel(Color(0.08, 0.09, 0.04, 0.86), Color(0.42, 0.51, 0.20, 0.80), 2, 18)

func _relic_socket() -> Panel:
	return _panel(Color(0.10, 0.075, 0.035, 0.92), Color(0.55, 0.42, 0.16, 0.85), 2, 6)

func _wood_button(text_value: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_disabled_color", Color(0.45, 0.42, 0.30, 0.75))
	button.add_theme_stylebox_override("normal", _style(Color("17120b"), Color("66712f"), 2, 7))
	button.add_theme_stylebox_override("hover", _style(Color("21190d"), GOLD, 3, 7))
	button.add_theme_stylebox_override("pressed", _style(Color("2c180d"), SELECT, 3, 7))
	button.add_theme_stylebox_override("disabled", _style(Color("100e09"), Color("3a3d20"), 2, 7))
	return button

func _panel(color: Color, border: Color, width: int, radius: int) -> Panel:
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", _style(color, border, width, radius))
	return panel

func _label(text_value: String, font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _place(control: Control, rect: Rect2) -> void:
	add_child(control)
	control.position = rect.position
	control.size = rect.size
	control.set_deferred("size", rect.size)

func _style(color: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
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
