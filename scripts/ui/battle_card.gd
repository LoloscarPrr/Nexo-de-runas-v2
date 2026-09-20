extends Button

const INK := Color("090c06")
const PAPER := Color("aaa65c")
const PAPER_LIGHT := Color("c1bb70")
const PAPER_DARK := Color("77743f")
const DEEP := Color("0a0d07")
const EDGE := Color("4d5726")
const GLOW := Color("c6da58")
const BLOOD_MARK := Color("842c22")

var card: Dictionary = {}
var marked := false
var chosen := false
var current_hp := -1
var current_atk := -1
var _cached_full_id := ""
var _cached_full_texture: Texture2D

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

	# Marco canónico. Siempre se reconstruye desde datos mecánicos para que
	# el valor visible coincida con lo que la carta realmente hace.
	draw_rect(Rect2(5, 6, w - 3, h - 3), Color(0, 0, 0, 0.74))
	draw_rect(Rect2(1, 1, w - 7, h - 7), PAPER_DARK)
	draw_rect(Rect2(4, 4, w - 13, h - 13), PAPER)
	draw_rect(Rect2(7, 7, w - 19, h - 19), INK, false, 2)

	var font := ThemeDB.fallback_font
	var head_h := clampf(h * 0.155, 28.0, 41.0)
	var cost_box := head_h - 5.0

	# Coste arriba a la izquierda.
	draw_rect(Rect2(7, 7, cost_box, cost_box), PAPER_LIGHT)
	draw_rect(Rect2(7, 7, cost_box, cost_box), INK, false, 2)
	var cost_value := int(card.get("cost_value", 0))
	var cost_size := int(clampf(head_h * 0.62, 15, 24))
	draw_string(font, Vector2(10, 7 + head_h * 0.72), str(cost_value), HORIZONTAL_ALIGNMENT_CENTER, cost_box - 6, cost_size, INK)

	# Nombre centrado, reduciendo tamaño en nombres largos.
	var title_x := head_h + 6.0
	var title_text := str(card.get("name", "CARTA"))
	var title_size := int(clampf(h * 0.052, 9, 15))
	if title_text.length() > 24:
		title_size = maxi(7, title_size - 4)
	elif title_text.length() > 18:
		title_size = maxi(8, title_size - 3)
	elif title_text.length() > 13:
		title_size = maxi(9, title_size - 2)
	draw_string(font, Vector2(title_x, 7 + head_h * 0.68), title_text, HORIZONTAL_ALIGNMENT_CENTER, w - title_x - 14, title_size, INK)

	# Ilustración de Nexo: se extrae SOLO la zona central de la carta
	# normalizada. Misma región para las 94, sin inclinación ni desplazamiento.
	var art_top := head_h + 8.0
	var stat_h := clampf(h * 0.19, 34.0, 48.0)
	var art_bottom := h - stat_h - 8.0
	var art_rect := Rect2(8, art_top, w - 22, art_bottom - art_top)
	draw_rect(art_rect, DEEP)
	_draw_nexo_art(art_rect)
	draw_rect(art_rect, EDGE, false, 2)

	# Faja inferior: ATQ real / sello(s) / VIDA actual.
	var stat_y := h - stat_h - 7.0
	draw_rect(Rect2(7, stat_y, w - 19, stat_h), PAPER_LIGHT)
	draw_rect(Rect2(7, stat_y, w - 19, stat_h), INK, false, 2)
	draw_line(Vector2(w * 0.31, stat_y), Vector2(w * 0.31, stat_y + stat_h), INK, 1)
	draw_line(Vector2(w * 0.69, stat_y), Vector2(w * 0.69, stat_y + stat_h), INK, 1)

	var attack_value := current_atk if current_atk >= 0 else int(card.get("atk", 0))
	var health_value := current_hp if current_hp >= 0 else int(card.get("hp", 1))
	var stat_size := int(clampf(stat_h * 0.66, 19, 31))
	draw_string(font, Vector2(9, stat_y + stat_h * 0.76), str(attack_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.25, stat_size, INK)
	draw_string(font, Vector2(w * 0.73, stat_y + stat_h * 0.76), str(health_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.20, stat_size, INK)

	_draw_sigils(Rect2(w * 0.32, stat_y + 2, w * 0.36, stat_h - 4))

	if chosen:
		draw_rect(Rect2(-1, -1, w - 4, h - 4), GLOW, false, 4)
	if marked:
		draw_rect(Rect2(1, 1, w - 7, h - 7), BLOOD_MARK, false, 5)
		draw_line(Vector2(13, art_top + 7), Vector2(w - 20, art_bottom - 7), BLOOD_MARK, 5)
		draw_line(Vector2(w - 20, art_top + 7), Vector2(13, art_bottom - 7), BLOOD_MARK, 5)

func _draw_nexo_art(rect: Rect2) -> void:
	var texture := _get_full_card_texture(str(card.get("id", "")))
	if texture == null:
		_draw_missing_art(rect)
		return
	var source_size := texture.get_size()
	# Las 94 imágenes tienen el mismo lienzo. El área central evita volver a
	# mostrar nombre/coste/estadísticas horneados en la lámina.
	var src := Rect2(
		source_size.x * 0.055,
		source_size.y * 0.185,
		source_size.x * 0.89,
		source_size.y * 0.565
	)
	var src_aspect := src.size.x / src.size.y
	var dst := rect.grow(-2)
	var dst_size := dst.size
	var dst_aspect := dst.size.x / dst.size.y
	if src_aspect > dst_aspect:
		dst_size.y = dst.size.x / src_aspect
	else:
		dst_size.x = dst.size.y * src_aspect
	var dst_pos := dst.position + (dst.size - dst_size) * 0.5
	draw_texture_rect_region(texture, Rect2(dst_pos, dst_size), src, Color.WHITE, false, true)
	# Integración leve con el tablero sin borrar detalle.
	draw_rect(rect.grow(-2), Color(0.035, 0.055, 0.02, 0.06))
	for y in range(int(rect.position.y) + 2, int(rect.end.y), 4):
		draw_line(Vector2(rect.position.x + 2, float(y)), Vector2(rect.end.x - 2, float(y)), Color(0, 0, 0, 0.055), 1)

func _draw_missing_art(rect: Rect2) -> void:
	var c := Color("8d8b48")
	var center := rect.get_center()
	draw_circle(center, minf(rect.size.x, rect.size.y) * 0.22, c, false, 3)
	draw_line(center + Vector2(-18, -18), center + Vector2(18, 18), c, 3)
	draw_line(center + Vector2(18, -18), center + Vector2(-18, 18), c, 3)

func _draw_sigils(rect: Rect2) -> void:
	var sigils: Array = Array(card.get("sigils", []))
	var stat := str(card.get("special_stat", "NONE"))
	if sigils.is_empty() and stat != "NONE":
		sigils = ["STAT_" + stat]
	if sigils.is_empty():
		return
	var shown := mini(sigils.size(), 2)
	var radius := minf(rect.size.y * 0.30, rect.size.x / float(shown) * 0.28)
	for i in range(shown):
		var x := rect.position.x + rect.size.x * (float(i + 1) / float(shown + 1))
		var pos := Vector2(x, rect.get_center().y)
		_draw_sigil_symbol(str(sigils[i]), pos, radius)

func _draw_sigil_symbol(code: String, pos: Vector2, r: float) -> void:
	var c := INK
	match code:
		"AIRBORNE":
			draw_line(pos + Vector2(-r, r * 0.35), pos + Vector2(r, -r * 0.35), c, 3)
			draw_line(pos + Vector2(-r * 0.65, -r * 0.35), pos + Vector2(r * 0.65, r * 0.35), c, 3)
		"MIGHTY_LEAP":
			draw_arc(pos, r * 0.72, PI, TAU, 14, c, 3)
			draw_line(pos + Vector2(-r * 0.7, 0), pos + Vector2(0, -r * 0.95), c, 2)
			draw_line(pos + Vector2(0, -r * 0.95), pos + Vector2(r * 0.7, 0), c, 2)
		"TOUCH_OF_DEATH":
			draw_circle(pos, r * 0.72, c)
			draw_circle(pos + Vector2(-r * 0.25, -r * 0.08), r * 0.13, PAPER_LIGHT)
			draw_circle(pos + Vector2(r * 0.25, -r * 0.08), r * 0.13, PAPER_LIGHT)
			draw_rect(Rect2(pos.x - r * 0.22, pos.y + r * 0.26, r * 0.44, r * 0.20), PAPER_LIGHT)
		"SHARP_QUILLS":
			for angle in range(0, 360, 45):
				var a := deg_to_rad(float(angle))
				draw_line(pos + Vector2(cos(a), sin(a)) * r * 0.22, pos + Vector2(cos(a), sin(a)) * r, c, 3)
		"LEADER":
			draw_line(pos + Vector2(0, -r), pos + Vector2(0, r), c, 3)
			draw_line(pos, pos + Vector2(-r * 0.8, -r * 0.45), c, 3)
			draw_line(pos, pos + Vector2(r * 0.8, -r * 0.45), c, 3)
		"MANY_LIVES":
			draw_circle(pos, r * 0.72, c, false, 3)
			draw_arc(pos, r * 0.42, -PI * 0.35, PI * 1.35, 14, c, 3)
		"UNKILLABLE":
			draw_arc(pos, r * 0.75, 0, TAU, 20, c, 3)
			draw_line(pos + Vector2(r * 0.45, -r * 0.6), pos + Vector2(r * 0.85, -r * 0.7), c, 3)
		"SPRINTER", "HEFTY":
			for y in [-0.45, 0.0, 0.45]:
				draw_line(pos + Vector2(-r, y * r), pos + Vector2(r, y * r - r * 0.25), c, 3)
		"BURROWER", "RABBIT_HOLE":
			draw_arc(pos, r * 0.78, PI, TAU, 18, c, 4)
			draw_line(pos + Vector2(-r * 0.75, 0), pos + Vector2(r * 0.75, 0), c, 3)
		"BIFURCATED_STRIKE":
			draw_line(pos + Vector2(0, r), pos + Vector2(0, 0), c, 3)
			draw_line(pos, pos + Vector2(-r * 0.8, -r), c, 3)
			draw_line(pos, pos + Vector2(r * 0.8, -r), c, 3)
		"TRIFURCATED_STRIKE":
			draw_line(pos + Vector2(0, r), pos + Vector2(0, -r), c, 3)
			draw_line(pos, pos + Vector2(-r * 0.85, -r), c, 3)
			draw_line(pos, pos + Vector2(r * 0.85, -r), c, 3)
		"FLEDGLING":
			draw_arc(pos, r * 0.60, 0, TAU, 16, c, 3)
			draw_line(pos + Vector2(-r * 0.6, r * 0.7), pos + Vector2(r * 0.6, r * 0.7), c, 3)
		"STINKY":
			for x in [-0.55, 0.0, 0.55]:
				var px := pos.x + x * r
				draw_arc(Vector2(px, pos.y), r * 0.35, -PI * 0.5, PI * 0.5, 8, c, 2)
		"WORTHY_SACRIFICE":
			draw_circle(pos, r * 0.62, c, false, 3)
			draw_line(pos + Vector2(0, -r), pos + Vector2(0, r), c, 3)
			draw_line(pos + Vector2(-r * 0.7, 0), pos + Vector2(r * 0.7, 0), c, 3)
		"STAT_ANTS":
			draw_circle(pos, r * 0.32, c)
			draw_circle(pos + Vector2(-r * 0.38, -r * 0.25), r * 0.18, c)
			draw_circle(pos + Vector2(r * 0.38, -r * 0.25), r * 0.18, c)
			draw_line(pos + Vector2(-r * 0.2, r * 0.2), pos + Vector2(-r * 0.65, r * 0.75), c, 2)
			draw_line(pos + Vector2(r * 0.2, r * 0.2), pos + Vector2(r * 0.65, r * 0.75), c, 2)
		"STAT_BELL":
			draw_arc(pos, r * 0.7, PI, TAU, 14, c, 3)
			draw_line(pos + Vector2(-r * 0.7, 0), pos + Vector2(-r * 0.5, r * 0.75), c, 3)
			draw_line(pos + Vector2(r * 0.7, 0), pos + Vector2(r * 0.5, r * 0.75), c, 3)
			draw_line(pos + Vector2(-r * 0.5, r * 0.75), pos + Vector2(r * 0.5, r * 0.75), c, 3)
		"STAT_CARDS_IN_HAND":
			draw_rect(Rect2(pos - Vector2(r * 0.65, r * 0.8), Vector2(r * 1.05, r * 1.35)), c, false, 2)
			draw_rect(Rect2(pos - Vector2(r * 0.35, r * 0.55), Vector2(r * 1.05, r * 1.35)), c, false, 2)
		"STAT_MIRROR":
			draw_rect(Rect2(pos - Vector2(r * 0.55, r * 0.8), Vector2(r * 1.1, r * 1.6)), c, false, 3)
			draw_line(pos + Vector2(0, -r * 0.7), pos + Vector2(0, r * 0.7), c, 2)
		_:
			# Runa genérica para sellos menos frecuentes; evita texto ilegible.
			draw_rect(Rect2(pos - Vector2(r * 0.62, r * 0.62), Vector2(r * 1.24, r * 1.24)), c, false, 3)
			draw_line(pos + Vector2(-r * 0.45, r * 0.45), pos + Vector2(r * 0.45, -r * 0.45), c, 2)

func _get_full_card_texture(card_id: String) -> Texture2D:
	if _cached_full_id == card_id:
		return _cached_full_texture
	_cached_full_id = card_id
	_cached_full_texture = null
	var path := "res://assets/card_full/%s.png" % card_id
	if ResourceLoader.exists(path):
		_cached_full_texture = load(path) as Texture2D
	return _cached_full_texture
