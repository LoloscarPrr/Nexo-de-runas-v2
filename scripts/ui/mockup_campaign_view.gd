extends "res://scripts/ui/immersive_campaign_view.gd"

## Capa visual canónica del mockup.
## Mantiene las reglas de campaña separadas y reemplaza los últimos menús
## planos por objetos/escenas dentro de la misma cabaña del Acto 1.

const MockCardScript = preload("res://scripts/ui/battle_card.gd")
const MockCatalogScript = preload("res://scripts/domain/card_catalog.gd")

const M_INK := Color8(199, 213, 103)
const M_MUTED := Color8(113, 125, 67)
const M_AMBER := Color8(198, 218, 88)
const M_BLOOD := Color8(121, 43, 34)
const M_EDGE := Color8(76, 89, 40)
const M_WOOD := Color8(18, 25, 13)
const M_DANGER := Color8(158, 69, 48)
const M_SUCCESS := Color8(168, 187, 83)

func open_launcher() -> void:
	_clear_screen()
	_add_campaign_backdrop("menu")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	_place(_label("NEXO DE RUNAS", 40, M_INK, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.28, vh * 0.23, vw * 0.40, 58))
	_place(_label("TODO VUELVE AL CICLO.", 14, M_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.31, vh * 0.32, vw * 0.34, 30))

	var button_w := minf(440.0, vw * 0.36)
	var x := vw * 0.5 - button_w * 0.5
	var new_game := _small_button("NUEVA PARTIDA", int(button_w))
	new_game.pressed.connect(_start_new)
	_place(new_game, Rect2(x, vh * 0.59, button_w, 62))

	var continue_button := _small_button("CONTINUAR", int(button_w))
	continue_button.disabled = not has_save()
	continue_button.pressed.connect(_continue_run)
	_place(continue_button, Rect2(x, vh * 0.70, button_w, 62))

	var leave := _small_button("SALIR DEL CICLO", int(button_w))
	leave.pressed.connect(_exit_to_menu)
	_place(leave, Rect2(x, vh * 0.81, button_w, 52))

func _show_battle_reward() -> void:
	_clear_screen()
	_add_campaign_backdrop("reward")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	_place(_label("LA BALANZA CEDE", 34, M_SUCCESS, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.27, 34, vw * 0.46, 48))
	_place(_label("Tres cartas son empujadas sobre la mesa. Toma una.", 14, M_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, 79, vw * 0.50, 30))

	var ids: Array[String] = _reward_choices("battle:%s:%d" % [active_battle_node, state.victories], 3)
	var card_w := 190.0
	var card_h := 260.0
	var gap := minf(88.0, vw * 0.05)
	var total := card_w * 3.0 + gap * 2.0
	var left := (vw - total) * 0.5
	for index in range(ids.size()):
		var card_id: String = ids[index]
		var view := _choice_card_button(card_id, _claim_battle_reward.bind(card_id))
		_place(view, Rect2(left + float(index) * (card_w + gap), vh * 0.285, card_w, card_h))

func _show_defeat() -> void:
	_clear_screen()
	_add_campaign_backdrop("defeat")
	var viewport_size := get_viewport_rect().size
	var vw := maxf(viewport_size.x, 1280.0)
	var vh := maxf(viewport_size.y, 720.0)

	_place(_label("TU VELA SE APAGA", 38, M_DANGER, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.25, vh * 0.25, vw * 0.50, 56))
	_place(_label("La balanza cayó del lado equivocado.", 15, M_MUTED, HORIZONTAL_ALIGNMENT_CENTER), Rect2(vw * 0.28, vh * 0.34, vw * 0.44, 30))

	var button_w := minf(390.0, vw * 0.33)
	var x := vw * 0.5 - button_w * 0.5
	var retry := _small_button("VOLVER A LA MESA", int(button_w))
	retry.pressed.connect(_start_battle.bind(active_battle_node))
	_place(retry, Rect2(x, vh * 0.66, button_w, 58))
	var map_button := _small_button("REGRESAR AL MAPA", int(button_w))
	map_button.pressed.connect(_show_map)
	_place(map_button, Rect2(x, vh * 0.76, button_w, 52))

func _choice_card_button(card_id: String, callback: Callable) -> Button:
	# Una sola representación física de carta para combate, elección y recompensa.
	var view := MockCardScript.new()
	view.card = MockCatalogScript.find_by_id(card_id)
	view.custom_minimum_size = Vector2(190, 260)
	view.pressed.connect(callback)
	return view

func _small_button(text_value: String, width: int) -> Button:
	# Tablilla de madera/papel oscuro; evita el aspecto de botón móvil genérico.
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 44)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", M_INK)
	button.add_theme_color_override("font_hover_color", Color8(222, 232, 125))
	button.add_theme_color_override("font_pressed_color", Color8(247, 229, 184))
	button.add_theme_color_override("font_disabled_color", Color8(73, 82, 45))
	button.add_theme_stylebox_override("normal", _panel_style(Color(0.040, 0.058, 0.030, 0.92), M_EDGE, 2, 2))
	button.add_theme_stylebox_override("hover", _panel_style(Color(0.075, 0.10, 0.040, 0.96), M_AMBER, 2, 2))
	button.add_theme_stylebox_override("pressed", _panel_style(Color(0.15, 0.065, 0.040, 0.97), M_BLOOD, 3, 2))
	button.add_theme_stylebox_override("disabled", _panel_style(Color(0.025, 0.037, 0.020, 0.78), Color8(45, 54, 30), 1, 2))
	return button
