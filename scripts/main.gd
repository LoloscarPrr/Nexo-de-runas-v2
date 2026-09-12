extends Control

## Punto de entrada visible de Nexo de Runas V2.
## Esta fase corrige la pantalla gris, fuerza landscape y restaura la navegación base.

const BG := Color8(10, 10, 9)
const PANEL := Color8(28, 25, 20)
const PANEL_ALT := Color8(19, 18, 16)
const INK := Color8(223, 214, 188)
const MUTED := Color8(157, 146, 121)
const ACCENT := Color8(181, 137, 69)
const ACCENT_DARK := Color8(87, 61, 31)
const BORDER := Color8(109, 87, 51)

var menu_box: VBoxContainer
var detail_box: VBoxContainer
var detail_title: Label
var detail_body: Label

func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	_build_ui()
	set_process(false)

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var frame := MarginContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_constant_override("margin_left", 72)
	frame.add_theme_constant_override("margin_right", 72)
	frame.add_theme_constant_override("margin_top", 48)
	frame.add_theme_constant_override("margin_bottom", 48)
	add_child(frame)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER, 3, 14))
	frame.add_child(panel)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left", 54)
	inner.add_theme_constant_override("margin_right", 54)
	inner.add_theme_constant_override("margin_top", 34)
	inner.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(inner)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 18)
	inner.add_child(root_box)

	var eyebrow := Label.new()
	eyebrow.text = "NEXO // PROTOCOLO DE RUNAS"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_color_override("font_color", MUTED)
	eyebrow.add_theme_font_size_override("font_size", 18)
	root_box.add_child(eyebrow)

	var title := Label.new()
	title.text = "NEXO DE RUNAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", INK)
	title.add_theme_font_size_override("font_size", 54)
	root_box.add_child(title)

	var rule := HSeparator.new()
	rule.add_theme_constant_override("separation", 12)
	root_box.add_child(rule)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(center)

	menu_box = VBoxContainer.new()
	menu_box.custom_minimum_size = Vector2(620, 0)
	menu_box.add_theme_constant_override("separation", 14)
	center.add_child(menu_box)

	var prompt := Label.new()
	prompt.text = "ELIGE TU PRÓXIMO MOVIMIENTO"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override("font_color", ACCENT)
	prompt.add_theme_font_size_override("font_size", 20)
	menu_box.add_child(prompt)

	menu_box.add_child(_menu_button("CONSTRUCTOR DE MAZO", "deck"))
	menu_box.add_child(_menu_button("BATALLA VS CPU", "cpu"))
	menu_box.add_child(_menu_button("BATALLA LOCAL", "local"))

	var note := Label.new()
	note.text = "V2 · GODOT 4.3 · ANDROID HORIZONTAL"
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_color_override("font_color", MUTED)
	note.add_theme_font_size_override("font_size", 15)
	menu_box.add_child(note)

	detail_box = VBoxContainer.new()
	detail_box.custom_minimum_size = Vector2(720, 0)
	detail_box.add_theme_constant_override("separation", 22)
	detail_box.visible = false
	center.add_child(detail_box)

	detail_title = Label.new()
	detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_title.add_theme_color_override("font_color", INK)
	detail_title.add_theme_font_size_override("font_size", 34)
	detail_box.add_child(detail_title)

	detail_body = Label.new()
	detail_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_body.add_theme_color_override("font_color", MUTED)
	detail_body.add_theme_font_size_override("font_size", 20)
	detail_box.add_child(detail_body)

	var back := _styled_button("VOLVER")
	back.pressed.connect(_show_menu)
	detail_box.add_child(back)

	var footer := Label.new()
	footer.text = "La próxima vertical slice añade cartas manipulables y combate real."
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", MUTED)
	footer.add_theme_font_size_override("font_size", 14)
	root_box.add_child(footer)

func _menu_button(text: String, section: String) -> Button:
	var button := _styled_button(text)
	button.pressed.connect(_open_section.bind(section))
	return button

func _styled_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(620, 68)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _panel_style(PANEL_ALT, BORDER, 2, 8))
	button.add_theme_stylebox_override("hover", _panel_style(Color8(38, 31, 22), ACCENT, 2, 8))
	button.add_theme_stylebox_override("pressed", _panel_style(ACCENT_DARK, ACCENT, 2, 8))
	return button

func _panel_style(color: Color, border_color: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

func _open_section(section: String) -> void:
	menu_box.visible = false
	detail_box.visible = true

	match section:
		"deck":
			detail_title.text = "CONSTRUCTOR DE MAZO"
			detail_body.text = "Acceso restaurado.\n\nLa siguiente fase incorporará los cuatro estilos, colección visual y cartas arrastrables con ataque, salud, coste y sello."
		"cpu":
			detail_title.text = "BATALLA VS CPU"
			detail_body.text = "Acceso restaurado.\n\nEste modo será la primera batalla jugable para validar reglas y recursos antes de depender de la red local."
		"local":
			detail_title.text = "BATALLA LOCAL"
			detail_body.text = "Acceso restaurado.\n\nLa conexión Wi‑Fi se habilitará después de estabilizar el combate contra CPU, usando el mismo motor de reglas."
		_:
			detail_title.text = "NEXO DE RUNAS"
			detail_body.text = "Sección no disponible."

func _show_menu() -> void:
	detail_box.visible = false
	menu_box.visible = true
