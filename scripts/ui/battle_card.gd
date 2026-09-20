extends Button

const INK := Color("090c06")
const PAPER := Color("aaa65c")
const PAPER_LIGHT := Color("c1bb70")
const PAPER_DARK := Color("77743f")
const DEEP := Color("0a0d07")
const EDGE := Color("4d5726")
const GLOW := Color("c6da58")

var card: Dictionary = {}
var marked := false
var chosen := false
var current_hp := -1
var _cached_art_id := ""
var _cached_art_texture: Texture2D

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	text = ""
	clip_contents = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	resized.connect(_refresh_pose)
	button_down.connect(_press_pose)
	button_up.connect(_refresh_pose)
	call_deferred("_refresh_pose")

func _refresh_pose() -> void:
	pivot_offset = size * 0.5
	var target_scale := Vector2(1.035, 1.035) if chosen else Vector2.ONE
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", target_scale, 0.08)
	tween.tween_property(self, "rotation", 0.0, 0.08)
	queue_redraw()

func _press_pose() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.975, 0.975), 0.05)

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 24 or h < 36:
		return

	# Sombra y papel envejecido verde/oliva.
	draw_rect(Rect2(5, 6, w - 2, h - 2), Color(0, 0, 0, 0.72))
	draw_rect(Rect2(1, 1, w - 7, h - 7), PAPER_DARK)
	draw_rect(Rect2(4, 4, w - 13, h - 13), PAPER)
	draw_rect(Rect2(7, 7, w - 19, h - 19), INK, false, 2)

	# Cabecera: coste cuadrado + nombre.
	var head_h := clampf(h * 0.16, 30.0, 42.0)
	draw_rect(Rect2(7, 7, head_h - 5, head_h - 5), PAPER_LIGHT)
	draw_rect(Rect2(7, 7, head_h - 5, head_h - 5), INK, false, 2)
	var font := ThemeDB.fallback_font
	var cost := int(card.get("cost_value", 0))
	draw_string(font, Vector2(12, 7 + head_h * 0.72), str(cost), HORIZONTAL_ALIGNMENT_CENTER, head_h - 15, int(clampf(head_h * 0.65, 16, 24)), INK)
	var title_x := head_h + 7.0
	var title_text := str(card.get("name", "CARTA"))
	var title_size := int(clampf(h * 0.058, 10, 15))
	if title_text.length() > 26:
		title_size = maxi(7, title_size - 5)
	elif title_text.length() > 20:
		title_size = maxi(8, title_size - 4)
	elif title_text.length() > 15:
		title_size = maxi(9, title_size - 3)
	draw_string(font, Vector2(title_x, 7 + head_h * 0.69), title_text, HORIZONTAL_ALIGNMENT_CENTER, w - title_x - 15, title_size, INK)

	# Ventana de arte.
	var art_top := head_h + 9.0
	var stat_h := clampf(h * 0.19, 34.0, 48.0)
	var art_bottom := h - stat_h - 8.0
	var art_rect := Rect2(8, art_top, w - 22, art_bottom - art_top)
	draw_rect(art_rect, DEEP)
	draw_rect(art_rect, EDGE, false, 2)
	for i in range(26):
		var px := art_rect.position.x + 5.0 + fmod(float(i * 37), maxf(5.0, art_rect.size.x - 10.0))
		var py := art_rect.position.y + 5.0 + fmod(float(i * 23), maxf(5.0, art_rect.size.y - 10.0))
		draw_rect(Rect2(px, py, 2, 2), Color(0.68, 0.67, 0.34, 0.16))
	_draw_art(art_rect)

	# Faja inferior de estadísticas.
	var stat_y := h - stat_h - 7.0
	draw_rect(Rect2(7, stat_y, w - 19, stat_h), PAPER_LIGHT)
	draw_rect(Rect2(7, stat_y, w - 19, stat_h), INK, false, 2)
	draw_line(Vector2(w * 0.34, stat_y), Vector2(w * 0.34, stat_y + stat_h), INK, 1)
	draw_line(Vector2(w * 0.66, stat_y), Vector2(w * 0.66, stat_y + stat_h), INK, 1)
	var stat_size := int(clampf(stat_h * 0.66, 20, 32))
	draw_string(font, Vector2(10, stat_y + stat_h * 0.76), str(card.get("atk", 0)), HORIZONTAL_ALIGNMENT_LEFT, w * 0.25, stat_size, INK)
	draw_string(font, Vector2(w * 0.70, stat_y + stat_h * 0.76), str(current_hp if current_hp >= 0 else card.get("hp", 1)), HORIZONTAL_ALIGNMENT_RIGHT, w * 0.23, stat_size, INK)
	_draw_seal(Vector2(w * 0.5, stat_y + stat_h * 0.52), minf(15.0, stat_h * 0.32))

	# Selección y sacrificio.
	if chosen:
		draw_rect(Rect2(-2, -2, w + 1, h + 1), GLOW, false, 4)
	if marked:
		draw_rect(Rect2(1, 1, w - 7, h - 7), Color("842c22"), false, 5)
		draw_line(Vector2(14, art_top + 8), Vector2(w - 20, art_bottom - 8), Color("842c22"), 5)
		draw_line(Vector2(w - 20, art_top + 8), Vector2(14, art_bottom - 8), Color("842c22"), 5)

func _draw_art(rect: Rect2) -> void:
	var id := str(card.get("id", ""))
	var texture := _get_art_texture(id)
	if texture != null:
		var source_size := texture.get_size()
		# Mantén la ilustración completa, recta y centrada. Nunca hacemos crop agresivo:
		# calculamos un rectángulo de destino centrado conservando proporción.
		var target_aspect := rect.size.x / rect.size.y
		var source_aspect := source_size.x / source_size.y
		var draw_size := rect.size
		if source_aspect > target_aspect:
			draw_size.y = rect.size.x / source_aspect
		else:
			draw_size.x = rect.size.y * source_aspect
		var draw_pos := rect.position + (rect.size - draw_size) * 0.5
		var centered_rect := Rect2(draw_pos, draw_size)
		draw_texture_rect(texture, centered_rect, false, Color.WHITE)
		# Un filtro muy leve integra el arte sin borrar el detalle original de Nexo.
		draw_rect(rect, Color(0.05, 0.075, 0.025, 0.08))
		for y in range(int(rect.position.y) + 2, int(rect.end.y), 4):
			draw_line(Vector2(rect.position.x, float(y)), Vector2(rect.end.x, float(y)), Color(0, 0, 0, 0.08), 1)
		draw_rect(rect, EDGE, false, 2)
		return

	# Fallback procedural únicamente si un asset no está disponible.
	var center := rect.position + rect.size * Vector2(0.5, 0.54)
	var sx := rect.size.x / 150.0
	var sy := rect.size.y / 135.0
	draw_set_transform(center, 0.0, Vector2(sx, sy))
	var ink := Color("97954f")
	var glow := Color("d1df63")

	if id in ["gorrion", "buitre"]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-4, 6), Vector2(-43, -28), Vector2(-29, 15), Vector2(-9, 24),
			Vector2(1, 39), Vector2(12, 20), Vector2(39, 8), Vector2(47, -25),
			Vector2(10, -7), Vector2(5, -21), Vector2(-5, -16)
		]), ink)
		draw_circle(Vector2(5, -18), 3.5, glow)
	elif id == "rana_toro":
		draw_circle(Vector2(0, 12), 29, ink)
		draw_circle(Vector2(-22, -8), 13, ink)
		draw_circle(Vector2(22, -8), 13, ink)
		draw_circle(Vector2(-20, -10), 3, DEEP)
		draw_circle(Vector2(20, -10), 3, DEEP)
		for side in [-1.0, 1.0]:
			draw_line(Vector2(side * 18, 18), Vector2(side * 42, 34), ink, 10)
	elif id == "vibora":
		draw_arc(Vector2(0, 10), 31, -1.1, 4.5, 24, ink, 12)
		draw_circle(Vector2(6, -28), 11, ink)
		draw_circle(Vector2(10, -31), 2.5, glow)
	elif id == "topo":
		draw_colored_polygon(PackedVector2Array([Vector2(-40, 24), Vector2(-27, -15), Vector2(0, -30), Vector2(32, -12), Vector2(42, 22), Vector2(0, 37)]), ink)
		draw_circle(Vector2(-10, -12), 3, glow)
		draw_circle(Vector2(12, -12), 3, glow)
	elif id == "puercoespin":
		draw_colored_polygon(PackedVector2Array([Vector2(-43, 18), Vector2(-29, -25), Vector2(-18, -12), Vector2(-9, -34), Vector2(1, -13), Vector2(15, -31), Vector2(20, -8), Vector2(40, 3), Vector2(29, 31), Vector2(-20, 34)]), ink)
		draw_circle(Vector2(23, -3), 3, glow)
	elif id == "alce":
		draw_colored_polygon(PackedVector2Array([Vector2(-24, -12), Vector2(-10, -28), Vector2(12, -28), Vector2(25, -9), Vector2(19, 27), Vector2(0, 39), Vector2(-19, 27)]), ink)
		for side in [-1.0, 1.0]:
			draw_line(Vector2(side * 17, -24), Vector2(side * 37, -46), ink, 4)
			draw_line(Vector2(side * 31, -39), Vector2(side * 19, -49), ink, 3)
			draw_line(Vector2(side * 34, -41), Vector2(side * 43, -34), ink, 3)
		draw_circle(Vector2(-7, -11), 2.5, glow)
		draw_circle(Vector2(7, -11), 2.5, glow)
	elif id == "ardilla":
		draw_circle(Vector2(-3, 5), 24, ink)
		draw_circle(Vector2(3, -22), 13, ink)
		draw_arc(Vector2(30, 5), 24, -2.4, 2.0, 18, ink, 12)
		draw_circle(Vector2(7, -24), 2.5, glow)
	else:
		draw_colored_polygon(PackedVector2Array([
			Vector2(-34, -29), Vector2(-15, -15), Vector2(10, -17), Vector2(34, -31),
			Vector2(28, 7), Vector2(16, 27), Vector2(0, 38), Vector2(-18, 26), Vector2(-30, 8)
		]), ink)
		draw_circle(Vector2(-9, -2), 3, glow)
		draw_circle(Vector2(10, -2), 3, glow)
		draw_line(Vector2(-40, 27), Vector2(-21, 17), ink, 8)
		draw_line(Vector2(41, 26), Vector2(23, 17), ink, 8)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _get_art_texture(card_id: String) -> Texture2D:
	if _cached_art_id == card_id:
		return _cached_art_texture
	_cached_art_id = card_id
	_cached_art_texture = null
	var path := "res://assets/card_art/%s.png" % card_id
	if ResourceLoader.exists(path):
		_cached_art_texture = load(path) as Texture2D
	return _cached_art_texture

func _draw_seal(pos: Vector2, radius: float) -> void:
	var seal := str(card.get("seal", "NINGUNO"))
	var c := INK
	if seal == "AÉREO":
		draw_line(pos + Vector2(-radius, 5), pos + Vector2(radius, -5), c, 4)
		draw_line(pos + Vector2(-radius * 0.7, -5), pos + Vector2(radius * 0.7, 5), c, 3)
	elif seal == "TOQUE MORTAL":
		draw_circle(pos, radius * 0.72, c)
		draw_circle(pos + Vector2(-radius * 0.25, -radius * 0.1), radius * 0.13, PAPER_LIGHT)
		draw_circle(pos + Vector2(radius * 0.25, -radius * 0.1), radius * 0.13, PAPER_LIGHT)
	elif seal == "ESPINAS":
		for angle in range(0, 360, 60):
			var a := deg_to_rad(float(angle))
			draw_line(pos, pos + Vector2(cos(a), sin(a)) * radius, c, 3)
	elif seal == "MADRIGUERA":
		draw_arc(pos, radius * 0.8, PI, TAU, 16, c, 4)
	elif seal == "CORREDOR":
		for y in [-6.0, 0.0, 6.0]:
			draw_line(pos + Vector2(-radius, y), pos + Vector2(radius, y - 4), c, 3)
	elif seal == "SACRIFICIO":
		draw_circle(pos, radius * 0.65, c, false, 3)
		draw_line(pos + Vector2(0, -radius), pos + Vector2(0, radius), c, 3)
	else:
		draw_rect(Rect2(pos - Vector2(radius * 0.55, radius * 0.55), Vector2(radius * 1.1, radius * 1.1)), c, false, 3)
