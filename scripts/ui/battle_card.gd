extends Button

const ResourcePaletteScript = preload("res://scripts/ui/mockup_hud/resource_palette.gd")

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

	# Coste arriba a la izquierda. Sangre/Huesos conservan la lectura clásica;
	# Energía y Mox reciben acentos funcionales propios del mockup.
	var cost_rect := Rect2(7, 7, cost_box, cost_box)
	var resource := str(card.get("resource", "none"))
	var cost_fill := PAPER_LIGHT
	if resource == "energy":
		cost_fill = ResourcePaletteScript.ENERGY.darkened(0.18)
	elif resource == "mox":
		cost_fill = Color("353a28")
	draw_rect(cost_rect, cost_fill)
	draw_rect(cost_rect, INK, false, 2)
	var cost_value := int(card.get("cost_value", 0))
	var cost_size := int(clampf(head_h * 0.62, 15, 24))
	if resource == "mox":
		_draw_mox_cost(cost_rect)
	else:
		draw_string(font, Vector2(10, 7 + head_h * 0.72), str(cost_value), HORIZONTAL_ALIGNMENT_CENTER, cost_box - 6, cost_size, INK)
		if resource == "energy":
			# Dos cortes rectos refuerzan el código visual mecánico/rúnico.
			draw_line(cost_rect.position + Vector2(5, cost_rect.size.y - 7), cost_rect.position + Vector2(cost_rect.size.x - 5, cost_rect.size.y - 7), Color(0.04,0.08,0.09,0.65), 2)

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
	draw_line(Vector2(w * 0.27, stat_y), Vector2(w * 0.27, stat_y + stat_h), INK, 1)
	draw_line(Vector2(w * 0.73, stat_y), Vector2(w * 0.73, stat_y + stat_h), INK, 1)

	var attack_value := current_atk if current_atk >= 0 else int(card.get("atk", 0))
	var health_value := current_hp if current_hp >= 0 else int(card.get("hp", 1))
	var stat_size := int(clampf(stat_h * 0.66, 19, 31))
	draw_string(font, Vector2(9, stat_y + stat_h * 0.76), str(attack_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.20, stat_size, INK)
	draw_string(font, Vector2(w * 0.78, stat_y + stat_h * 0.76), str(health_value), HORIZONTAL_ALIGNMENT_CENTER, w * 0.15, stat_size, INK)

	_draw_sigils(Rect2(w * 0.28, stat_y + 1, w * 0.44, stat_h - 2))

	if chosen:
		draw_rect(Rect2(-1, -1, w - 4, h - 4), GLOW, false, 4)
	if marked:
		draw_rect(Rect2(1, 1, w - 7, h - 7), BLOOD_MARK, false, 5)
		draw_line(Vector2(13, art_top + 7), Vector2(w - 20, art_bottom - 7), BLOOD_MARK, 5)
		draw_line(Vector2(w - 20, art_top + 7), Vector2(13, art_bottom - 7), BLOOD_MARK, 5)

func _draw_mox_cost(rect: Rect2) -> void:
	var requirements: Array[String] = []
	var raw = card.get("mox_requirements", [])
	if raw is String:
		var single := str(raw).to_lower()
		if not single.is_empty():
			requirements.append(single)
	elif raw is Array:
		for item in raw:
			var color := str(item).to_lower()
			if not color.is_empty() and not requirements.has(color):
				requirements.append(color)
	if requirements.is_empty():
		requirements.append("blue")
	var count := mini(requirements.size(), 3)
	var r := minf(rect.size.x, rect.size.y) * (0.18 if count > 1 else 0.26)
	for i in range(count):
		var x := rect.position.x + rect.size.x * (float(i + 1) / float(count + 1))
		var center := Vector2(x, rect.get_center().y)
		var points := PackedVector2Array([
			center + Vector2(0, -r),
			center + Vector2(r * 0.72, 0),
			center + Vector2(0, r),
			center + Vector2(-r * 0.72, 0)
		])
		var color := ResourcePaletteScript.mox_color(requirements[i], true)
		draw_colored_polygon(points, color)
		draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), INK, 1.5)

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
	var ink := INK
	var paper := PAPER_LIGHT
	var lw := maxf(2.0, r * 0.18)
	match code:
		"TOUCH_OF_DEATH":
			draw_circle(pos + Vector2(0, -r * 0.08), r * 0.58, ink, false, lw)
			draw_circle(pos + Vector2(-r * 0.22, -r * 0.12), r * 0.11, ink)
			draw_circle(pos + Vector2(r * 0.22, -r * 0.12), r * 0.11, ink)
			draw_line(pos + Vector2(-r * 0.28, r * 0.18), pos + Vector2(r * 0.28, r * 0.18), ink, lw)
			draw_line(pos + Vector2(-r * 0.18, r * 0.20), pos + Vector2(-r * 0.18, r * 0.58), ink, lw)
			draw_line(pos + Vector2(r * 0.18, r * 0.20), pos + Vector2(r * 0.18, r * 0.58), ink, lw)
		"LEADER":
			draw_line(pos + Vector2(0, r), pos + Vector2(0, -r * 0.85), ink, lw)
			draw_line(pos + Vector2(0, -r * 0.10), pos + Vector2(-r * 0.72, -r * 0.58), ink, lw)
			draw_line(pos + Vector2(0, -r * 0.10), pos + Vector2(r * 0.72, -r * 0.58), ink, lw)
			draw_circle(pos + Vector2(0, -r * 0.9), r * 0.12, ink)
		"AMORPHOUS":
			draw_arc(pos, r * 0.70, 0.2, 5.2, 20, ink, lw)
			draw_arc(pos + Vector2(r * 0.12, -r * 0.08), r * 0.34, 1.1, 5.9, 14, ink, lw)
			draw_circle(pos + Vector2(-r * 0.45, r * 0.22), r * 0.10, ink)
		"ANT_SPAWNER":
			draw_circle(pos, r * 0.24, ink)
			draw_circle(pos + Vector2(0, -r * 0.48), r * 0.18, ink)
			draw_circle(pos + Vector2(0, r * 0.48), r * 0.22, ink)
			for side in [-1.0, 1.0]:
				draw_line(pos + Vector2(side * r * 0.18, -r * 0.10), pos + Vector2(side * r * 0.75, -r * 0.50), ink, lw)
				draw_line(pos + Vector2(side * r * 0.20, r * 0.10), pos + Vector2(side * r * 0.78, r * 0.05), ink, lw)
				draw_line(pos + Vector2(side * r * 0.18, r * 0.28), pos + Vector2(side * r * 0.72, r * 0.62), ink, lw)
		"AIRBORNE":
			draw_line(pos, pos + Vector2(0, r * 0.85), ink, lw)
			draw_line(pos, pos + Vector2(-r * 0.86, -r * 0.56), ink, lw)
			draw_line(pos, pos + Vector2(r * 0.86, -r * 0.56), ink, lw)
			draw_line(pos + Vector2(-r * 0.86, -r * 0.56), pos + Vector2(-r * 0.45, r * 0.05), ink, lw)
			draw_line(pos + Vector2(r * 0.86, -r * 0.56), pos + Vector2(r * 0.45, r * 0.05), ink, lw)
		"DAM_BUILDER":
			for y in [-0.48, 0.0, 0.48]:
				draw_line(pos + Vector2(-r * 0.9, y * r), pos + Vector2(r * 0.9, y * r), ink, lw)
			draw_line(pos + Vector2(-r * 0.55, -r * 0.9), pos + Vector2(-r * 0.05, r * 0.9), ink, lw)
			draw_line(pos + Vector2(r * 0.05, -r * 0.9), pos + Vector2(r * 0.55, r * 0.9), ink, lw)
		"BEES_WITHIN":
			draw_circle(pos, r * 0.30, ink, false, lw)
			draw_line(pos + Vector2(-r * 0.25, -r * 0.12), pos + Vector2(r * 0.25, -r * 0.12), ink, lw)
			draw_line(pos + Vector2(-r * 0.25, r * 0.12), pos + Vector2(r * 0.25, r * 0.12), ink, lw)
			draw_arc(pos + Vector2(-r * 0.45, -r * 0.12), r * 0.42, -1.2, 1.2, 10, ink, lw)
			draw_arc(pos + Vector2(r * 0.45, -r * 0.12), r * 0.42, 1.95, 4.35, 10, ink, lw)
			draw_line(pos + Vector2(0, r * 0.30), pos + Vector2(0, r * 0.92), ink, lw)
		"WORTHY_SACRIFICE":
			draw_circle(pos, r * 0.55, ink, false, lw)
			draw_line(pos + Vector2(0, -r), pos + Vector2(0, r), ink, lw)
			draw_line(pos + Vector2(-r, 0), pos + Vector2(r, 0), ink, lw)
			draw_circle(pos, r * 0.12, ink)
		"GUARDIAN":
			draw_arc(pos, r * 0.82, PI, TAU, 18, ink, lw)
			draw_line(pos + Vector2(-r * 0.82, 0), pos + Vector2(-r * 0.55, r * 0.70), ink, lw)
			draw_line(pos + Vector2(r * 0.82, 0), pos + Vector2(r * 0.55, r * 0.70), ink, lw)
			draw_line(pos + Vector2(-r * 0.55, r * 0.70), pos + Vector2(r * 0.55, r * 0.70), ink, lw)
			draw_circle(pos + Vector2(0, r * 0.1), r * 0.16, ink)
		"MIGHTY_LEAP":
			draw_arc(pos + Vector2(0, r * 0.12), r * 0.70, PI, TAU, 16, ink, lw)
			draw_line(pos + Vector2(-r * 0.70, r * 0.12), pos + Vector2(0, -r * 0.95), ink, lw)
			draw_line(pos + Vector2(r * 0.70, r * 0.12), pos + Vector2(0, -r * 0.95), ink, lw)
			draw_line(pos + Vector2(-r * 0.48, r * 0.62), pos + Vector2(r * 0.48, r * 0.62), ink, lw)
		"MANY_LIVES":
			draw_arc(pos, r * 0.72, -2.4, 2.4, 22, ink, lw)
			draw_line(pos + Vector2(r * 0.5, -r * 0.54), pos + Vector2(r * 0.9, -r * 0.62), ink, lw)
			draw_line(pos + Vector2(r * 0.5, -r * 0.54), pos + Vector2(r * 0.66, -r * 0.18), ink, lw)
			draw_circle(pos, r * 0.22, ink, false, lw)
		"UNKILLABLE":
			draw_arc(pos, r * 0.72, 0.2, 5.8, 24, ink, lw)
			draw_line(pos + Vector2(r * 0.58, -r * 0.44), pos + Vector2(r * 0.92, -r * 0.52), ink, lw)
			draw_line(pos + Vector2(r * 0.58, -r * 0.44), pos + Vector2(r * 0.70, -r * 0.10), ink, lw)
			draw_line(pos + Vector2(-r * 0.16, -r * 0.45), pos + Vector2(r * 0.18, r * 0.45), ink, lw)
		"CORPSE_EATER":
			draw_arc(pos + Vector2(0, -r * 0.12), r * 0.60, 0, PI, 14, ink, lw)
			draw_line(pos + Vector2(-r * 0.6, -r * 0.12), pos + Vector2(-r * 0.32, r * 0.72), ink, lw)
			draw_line(pos + Vector2(r * 0.6, -r * 0.12), pos + Vector2(r * 0.32, r * 0.72), ink, lw)
			draw_line(pos + Vector2(-r * 0.32, r * 0.72), pos + Vector2(r * 0.32, r * 0.72), ink, lw)
			draw_circle(pos + Vector2(-r * 0.22, -r * 0.16), r * 0.10, ink)
			draw_circle(pos + Vector2(r * 0.22, -r * 0.16), r * 0.10, ink)
		"SPRINTER":
			draw_line(pos + Vector2(-r, -r * 0.50), pos + Vector2(r * 0.35, -r * 0.50), ink, lw)
			draw_line(pos + Vector2(-r, 0), pos + Vector2(r * 0.55, 0), ink, lw)
			draw_line(pos + Vector2(-r, r * 0.50), pos + Vector2(r * 0.35, r * 0.50), ink, lw)
			draw_line(pos + Vector2(r * 0.55, 0), pos + Vector2(r * 0.15, -r * 0.35), ink, lw)
			draw_line(pos + Vector2(r * 0.55, 0), pos + Vector2(r * 0.15, r * 0.35), ink, lw)
		"FLEDGLING":
			draw_arc(pos + Vector2(0, r * 0.15), r * 0.55, PI, TAU, 16, ink, lw)
			draw_circle(pos + Vector2(0, -r * 0.50), r * 0.14, ink)
			draw_line(pos + Vector2(0, -r * 0.34), pos + Vector2(0, r * 0.92), ink, lw)
			draw_line(pos + Vector2(-r * 0.44, r * 0.38), pos + Vector2(0, r * 0.92), ink, lw)
			draw_line(pos + Vector2(r * 0.44, r * 0.38), pos + Vector2(0, r * 0.92), ink, lw)
		"FECUNDITY":
			draw_circle(pos + Vector2(-r * 0.32, 0), r * 0.48, ink, false, lw)
			draw_circle(pos + Vector2(r * 0.32, 0), r * 0.48, ink, false, lw)
			draw_line(pos + Vector2(-r * 0.08, -r * 0.62), pos + Vector2(r * 0.08, r * 0.62), ink, lw)
		"FROZEN_AWAY":
			for a in range(0, 360, 60):
				var rad := deg_to_rad(float(a))
				draw_line(pos, pos + Vector2(cos(rad), sin(rad)) * r * 0.92, ink, lw)
			draw_circle(pos, r * 0.22, ink, false, lw)
		"BONE_KING":
			draw_circle(pos + Vector2(-r * 0.55, 0), r * 0.22, ink, false, lw)
			draw_circle(pos + Vector2(r * 0.55, 0), r * 0.22, ink, false, lw)
			draw_line(pos + Vector2(-r * 0.38, -r * 0.16), pos + Vector2(r * 0.38, r * 0.16), ink, lw * 1.5)
			draw_line(pos + Vector2(-r * 0.38, r * 0.16), pos + Vector2(r * 0.38, -r * 0.16), ink, lw * 1.5)
			draw_line(pos + Vector2(-r * 0.18, -r * 0.72), pos + Vector2(0, -r * 0.98), ink, lw)
			draw_line(pos + Vector2(0, -r * 0.98), pos + Vector2(r * 0.18, -r * 0.72), ink, lw)
		"WATERBORNE":
			draw_arc(pos + Vector2(0, r * 0.15), r * 0.78, PI, TAU, 18, ink, lw)
			draw_line(pos + Vector2(-r * 0.88, r * 0.18), pos + Vector2(-r * 0.35, r * 0.58), ink, lw)
			draw_line(pos + Vector2(-r * 0.35, r * 0.58), pos + Vector2(r * 0.15, r * 0.18), ink, lw)
			draw_line(pos + Vector2(r * 0.15, r * 0.18), pos + Vector2(r * 0.82, r * 0.62), ink, lw)
		"STEEL_TRAP":
			draw_line(pos + Vector2(-r * 0.90, -r * 0.55), pos + Vector2(0, r * 0.10), ink, lw)
			draw_line(pos + Vector2(r * 0.90, -r * 0.55), pos + Vector2(0, r * 0.10), ink, lw)
			draw_line(pos + Vector2(-r * 0.90, r * 0.55), pos + Vector2(0, -r * 0.10), ink, lw)
			draw_line(pos + Vector2(r * 0.90, r * 0.55), pos + Vector2(0, -r * 0.10), ink, lw)
			draw_circle(pos, r * 0.18, ink)
		"HOARDER":
			draw_rect(Rect2(pos - Vector2(r * 0.55, r * 0.68), Vector2(r * 0.82, r * 1.20)), ink, false, lw)
			draw_rect(Rect2(pos - Vector2(r * 0.18, r * 0.45), Vector2(r * 0.82, r * 1.20)), ink, false, lw)
			draw_line(pos + Vector2(-r * 0.8, r * 0.72), pos + Vector2(r * 0.8, r * 0.72), ink, lw)
		"BIFURCATED_STRIKE":
			draw_line(pos + Vector2(0, r), pos, ink, lw)
			draw_line(pos, pos + Vector2(-r * 0.82, -r), ink, lw)
			draw_line(pos, pos + Vector2(r * 0.82, -r), ink, lw)
			draw_circle(pos, r * 0.12, ink)
		"TRIFURCATED_STRIKE":
			draw_line(pos + Vector2(0, r), pos + Vector2(0, -r), ink, lw)
			draw_line(pos, pos + Vector2(-r * 0.82, -r), ink, lw)
			draw_line(pos, pos + Vector2(r * 0.82, -r), ink, lw)
			draw_circle(pos, r * 0.12, ink)
		"BURROWER":
			draw_arc(pos + Vector2(0, r * 0.22), r * 0.72, PI, TAU, 18, ink, lw)
			draw_line(pos + Vector2(-r * 0.72, r * 0.22), pos + Vector2(-r * 0.38, r * 0.72), ink, lw)
			draw_line(pos + Vector2(r * 0.72, r * 0.22), pos + Vector2(r * 0.38, r * 0.72), ink, lw)
			draw_circle(pos + Vector2(-r * 0.24, 0), r * 0.10, ink)
			draw_circle(pos + Vector2(r * 0.24, 0), r * 0.10, ink)
		"HEFTY":
			draw_line(pos + Vector2(-r, 0), pos + Vector2(r * 0.55, 0), ink, lw * 1.5)
			draw_line(pos + Vector2(r * 0.55, 0), pos + Vector2(r * 0.05, -r * 0.48), ink, lw * 1.5)
			draw_line(pos + Vector2(r * 0.55, 0), pos + Vector2(r * 0.05, r * 0.48), ink, lw * 1.5)
			draw_rect(Rect2(pos.x - r * 0.78, pos.y - r * 0.72, r * 0.35, r * 1.44), ink, false, lw)
		"TRINKET_BEARER":
			draw_rect(Rect2(pos - Vector2(r * 0.62, r * 0.46), Vector2(r * 1.24, r * 0.92)), ink, false, lw)
			draw_arc(pos + Vector2(0, -r * 0.46), r * 0.35, PI, TAU, 12, ink, lw)
			draw_circle(pos, r * 0.10, ink)
		"SHARP_QUILLS":
			draw_circle(pos, r * 0.22, ink, false, lw)
			for angle in range(0, 360, 45):
				var a := deg_to_rad(float(angle))
				draw_line(pos + Vector2(cos(a), sin(a)) * r * 0.30, pos + Vector2(cos(a), sin(a)) * r, ink, lw)
		"RABBIT_HOLE":
			draw_arc(pos + Vector2(0, r * 0.24), r * 0.66, PI, TAU, 18, ink, lw)
			draw_line(pos + Vector2(-r * 0.66, r * 0.24), pos + Vector2(-r * 0.42, r * 0.82), ink, lw)
			draw_line(pos + Vector2(r * 0.66, r * 0.24), pos + Vector2(r * 0.42, r * 0.82), ink, lw)
			draw_line(pos + Vector2(-r * 0.22, -r * 0.46), pos + Vector2(-r * 0.35, -r), ink, lw)
			draw_line(pos + Vector2(r * 0.22, -r * 0.46), pos + Vector2(r * 0.35, -r), ink, lw)
		"STINKY":
			for x in [-0.55, 0.0, 0.55]:
				var px: float = pos.x + float(x) * r
				draw_arc(Vector2(px, pos.y), r * 0.36, -1.35, 1.35, 10, ink, lw)
		"LOOSE_TAIL":
			draw_arc(pos, r * 0.72, -2.4, 2.2, 20, ink, lw)
			draw_line(pos + Vector2(r * 0.50, r * 0.48), pos + Vector2(r * 0.92, r * 0.78), ink, lw)
			draw_line(pos + Vector2(r * 0.55, r * 0.48), pos + Vector2(r * 0.86, r * 0.28), ink, lw)
		"BELLIST":
			draw_arc(pos + Vector2(0, -r * 0.05), r * 0.62, PI, TAU, 16, ink, lw)
			draw_line(pos + Vector2(-r * 0.62, -r * 0.05), pos + Vector2(-r * 0.38, r * 0.62), ink, lw)
			draw_line(pos + Vector2(r * 0.62, -r * 0.05), pos + Vector2(r * 0.38, r * 0.62), ink, lw)
			draw_line(pos + Vector2(-r * 0.38, r * 0.62), pos + Vector2(r * 0.38, r * 0.62), ink, lw)
			draw_circle(pos + Vector2(0, r * 0.80), r * 0.12, ink)
		"REPULSIVE":
			draw_circle(pos, r * 0.76, ink, false, lw)
			draw_line(pos + Vector2(-r * 0.55, -r * 0.55), pos + Vector2(r * 0.55, r * 0.55), ink, lw * 1.4)
		"STAT_ANTS":
			draw_circle(pos, r * 0.22, ink)
			draw_circle(pos + Vector2(0, -r * 0.44), r * 0.16, ink)
			draw_circle(pos + Vector2(0, r * 0.44), r * 0.18, ink)
			for side in [-1.0, 1.0]:
				draw_line(pos + Vector2(side * r * 0.14, -r * 0.08), pos + Vector2(side * r * 0.72, -r * 0.50), ink, lw)
				draw_line(pos + Vector2(side * r * 0.16, r * 0.10), pos + Vector2(side * r * 0.72, r * 0.42), ink, lw)
		"STAT_BELL":
			draw_arc(pos + Vector2(0, -r * 0.05), r * 0.64, PI, TAU, 16, ink, lw)
			draw_line(pos + Vector2(-r * 0.64, -r * 0.05), pos + Vector2(-r * 0.40, r * 0.66), ink, lw)
			draw_line(pos + Vector2(r * 0.64, -r * 0.05), pos + Vector2(r * 0.40, r * 0.66), ink, lw)
			draw_line(pos + Vector2(-r * 0.40, r * 0.66), pos + Vector2(r * 0.40, r * 0.66), ink, lw)
			draw_line(pos + Vector2(0, r * 0.66), pos + Vector2(0, r), ink, lw)
		"STAT_CARDS_IN_HAND":
			draw_rect(Rect2(pos - Vector2(r * 0.72, r * 0.74), Vector2(r * 0.95, r * 1.28)), ink, false, lw)
			draw_rect(Rect2(pos - Vector2(r * 0.38, r * 0.50), Vector2(r * 0.95, r * 1.28)), ink, false, lw)
			draw_rect(Rect2(pos - Vector2(r * 0.04, r * 0.26), Vector2(r * 0.95, r * 1.28)), ink, false, lw)
		"STAT_MIRROR":
			draw_rect(Rect2(pos - Vector2(r * 0.60, r * 0.82), Vector2(r * 1.20, r * 1.64)), ink, false, lw)
			draw_line(pos + Vector2(0, -r * 0.70), pos + Vector2(0, r * 0.70), ink, lw)
			draw_line(pos + Vector2(-r * 0.45, 0), pos + Vector2(r * 0.45, 0), ink, lw)
		_:
			# Último recurso deliberadamente rúnico, no un símbolo Unicode/emoji.
			draw_circle(pos, r * 0.72, ink, false, lw)
			draw_line(pos + Vector2(-r * 0.55, r * 0.55), pos + Vector2(r * 0.55, -r * 0.55), ink, lw)

func _get_full_card_texture(card_id: String) -> Texture2D:
	if _cached_full_id == card_id:
		return _cached_full_texture
	_cached_full_id = card_id
	_cached_full_texture = null
	var path := "res://assets/card_full/%s.png" % card_id
	if ResourceLoader.exists(path):
		_cached_full_texture = load(path) as Texture2D
	return _cached_full_texture
