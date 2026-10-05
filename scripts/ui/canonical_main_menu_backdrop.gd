class_name CanonicalMainMenuBackdrop
extends Control

## Escena vertical del menú principal. Puramente decorativa: Guardián/Nexo,
## raíces, velas, runas, profundidad y altar inferior. No contiene reglas.

var phase := 0.0

const NIGHT := Color("050a06")
const NIGHT_GREEN := Color("09150d")
const BARK := Color("1d1209")
const BARK_LIGHT := Color("3c2511")
const ROOT_DARK := Color("241407")
const ROOT_LIGHT := Color("6f431d")
const MOSS := Color("2d4e2b")
const VINE := Color("4b6737")
const FIRE := Color("ff9a3f")
const BONE := Color("b9ad82")
const BONE_DARK := Color("554b34")
const EYE := Color("70ef54")
const RUNE := Color("70f05b")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 1.0 or s.y <= 1.0:
		return

	_draw_depth_gradient(s)
	_draw_tree_column(Rect2(0, 0, s.x * 0.065, s.y), false)
	_draw_tree_column(Rect2(s.x * 0.935, 0, s.x * 0.065, s.y), true)

	# El Guardián baja hacia el centro y gana escala. Sus astas invaden el espacio
	# del encabezado para integrarlo a la escena en lugar de parecer un icono.
	var guardian_center := Vector2(s.x * 0.50, s.y * 0.315)
	var guardian_scale := minf(s.x * 0.43, 320.0)
	_draw_glow(guardian_center + Vector2(0, 20), s.x * 0.44, Color(0.19, 0.60, 0.14, 0.12))
	_draw_glow(guardian_center + Vector2(-38, 14), s.x * 0.26, Color(0.26, 0.72, 0.18, 0.055))
	_draw_glow(guardian_center + Vector2(54, -18), s.x * 0.22, Color(0.18, 0.50, 0.13, 0.05))
	_draw_broken_nexus_ring(guardian_center + Vector2(0, 18), minf(s.x * 0.34, 255.0))
	_draw_guardian(guardian_center, guardian_scale)

	# Vegetación superior: asimétrica, cruza parcialmente por detrás del Guardián.
	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.015, s.y * 0.10), Vector2(s.x * 0.14, s.y * 0.15), Vector2(s.x * 0.25, s.y * 0.12), Vector2(s.x * 0.36, s.y * 0.19)
	]))
	_draw_vine(PackedVector2Array([
		Vector2(s.x * 0.985, s.y * 0.12), Vector2(s.x * 0.83, s.y * 0.18), Vector2(s.x * 0.74, s.y * 0.14), Vector2(s.x * 0.63, s.y * 0.20)
	]))

	# Velas y faroles sin espejo perfecto: parecen parte del santuario, no HUD.
	_draw_candle_cluster(Vector2(s.x * 0.13, s.y * 0.37), 0.92, 0.0)
	_draw_candle_cluster(Vector2(s.x * 0.86, s.y * 0.34), 0.76, 17.0)
	_draw_candle_cluster(Vector2(s.x * 0.09, s.y * 0.77), 1.15, -12.0)
	_draw_candle_cluster(Vector2(s.x * 0.91, s.y * 0.83), 0.86, 11.0)
	_draw_lantern(Vector2(s.x * 0.065, s.y * 0.50), s.x * 0.017)
	_draw_lantern(Vector2(s.x * 0.94, s.y * 0.56), s.x * 0.015)

	_draw_lower_sanctuary(s)

	# Viñeta leve: sólo bordes. El centro queda legible y abierto.
	draw_rect(Rect2(0, 0, s.x, s.y * 0.065), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(0, s.y * 0.975, s.x, s.y * 0.025), Color(0, 0, 0, 0.18))

func _draw_depth_gradient(s: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, s), NIGHT)
	for band in range(18):
		var t := float(band) / 17.0
		var y := s.y * t
		var shade := Color(
			lerpf(NIGHT_GREEN.r, 0.085, t),
			lerpf(NIGHT_GREEN.g, 0.065, t),
			lerpf(NIGHT_GREEN.b, 0.028, t),
			0.13
		)
		draw_rect(Rect2(0, y, s.x, s.y / 18.0 + 1.0), shade)

func _draw_broken_nexus_ring(center: Vector2, radius: float) -> void:
	var pulse := 0.80 + sin(phase * 1.55) * 0.12
	var arcs := [
		Vector2(-2.92, -1.48),
		Vector2(-1.18, -0.18),
		Vector2(0.12, 1.12),
		Vector2(1.42, 2.62)
	]
	for layer in range(4):
		var rr := radius * (0.69 + float(layer) * 0.09)
		for pair in arcs:
			draw_arc(center, rr, pair.x, pair.y, 28, Color(RUNE.r, RUNE.g, RUNE.b, (0.045 + layer * 0.018) * pulse), 2.0)
	for spoke in range(7):
		var angle := -2.55 + float(spoke) * 0.82 + sin(phase * 0.18 + spoke) * 0.03
		var a := center + Vector2(cos(angle), sin(angle)) * radius * 0.64
		var b := center + Vector2(cos(angle), sin(angle)) * radius * (0.82 + 0.03 * float(spoke % 2))
		draw_line(a, b, Color(RUNE.r, RUNE.g, RUNE.b, 0.13 * pulse), 1.8)
	for idx in range(5):
		var angle2 := -2.1 + float(idx) * 1.05
		var p := center + Vector2(cos(angle2), sin(angle2)) * radius * 0.77
		_draw_small_rune(p, 9.0 + float(idx % 2) * 2.0, 0.22 * pulse)

func _draw_guardian(center: Vector2, scale: float) -> void:
	var k := scale / 170.0

	# Copa/masa vegetal por detrás del cráneo.
	for offset in [Vector2(-62, 10), Vector2(60, 4), Vector2(-44, 43), Vector2(42, 46), Vector2(0, 58), Vector2(-7, 21)]:
		var p: Vector2 = center + offset * k
		draw_circle(p, 42.0 * k, Color(0.06, 0.18, 0.07, 0.56))
		draw_circle(p, 29.0 * k, Color(0.13, 0.34, 0.13, 0.35))

	# Astas más largas y gruesas, con bifurcaciones irregulares.
	for direction in [-1.0, 1.0]:
		var dir := float(direction)
		var root := center + Vector2(25.0 * dir, -45.0) * k
		var p1 := center + Vector2(75.0 * dir, -102.0) * k
		var p2 := center + Vector2(116.0 * dir, -162.0) * k
		var p3 := center + Vector2(148.0 * dir, -222.0) * k
		draw_polyline(PackedVector2Array([root, p1, p2, p3]), Color("5c3819"), 11.0 * k, true)
		draw_polyline(PackedVector2Array([root, p1, p2]), Color("a8773c"), 2.4 * k, true)
		draw_line(p1, p1 + Vector2(16.0 * dir, -58.0) * k, Color("5c3819"), 7.0 * k)
		draw_line(p2, p2 + Vector2(31.0 * dir, -44.0) * k, Color("5c3819"), 6.2 * k)
		if direction < 0:
			draw_line(p2 + Vector2(2, 4) * k, p2 + Vector2(-17, -35) * k, Color("5c3819"), 5.0 * k)
		else:
			draw_line(p1 + Vector2(1, -4) * k, p1 + Vector2(30, -31) * k, Color("5c3819"), 5.0 * k)

	var skull := PackedVector2Array([
		center + Vector2(-45, -62) * k,
		center + Vector2(-25, -82) * k,
		center + Vector2(0, -90) * k,
		center + Vector2(25, -82) * k,
		center + Vector2(45, -62) * k,
		center + Vector2(36, -3) * k,
		center + Vector2(18, 58) * k,
		center + Vector2(0, 96) * k,
		center + Vector2(-18, 58) * k,
		center + Vector2(-36, -3) * k
	])
	draw_colored_polygon(skull, Color(BONE.r, BONE.g, BONE.b, 0.88))
	var outline := skull.duplicate()
	outline.append(skull[0])
	draw_polyline(outline, Color(BONE_DARK.r, BONE_DARK.g, BONE_DARK.b, 0.96), 4.8 * k, true)

	# Ranura central como eco del Guardián de batalla.
	draw_line(center + Vector2(0, -14) * k, center + Vector2(0, 48) * k, Color(0.22, 0.21, 0.16, 0.72), 2.2 * k)
	draw_line(center + Vector2(-13, 16) * k, center + Vector2(13, 16) * k, Color(0.22, 0.21, 0.16, 0.50), 1.6 * k)

	for eye_x in [-20.0, 20.0]:
		var eye_center := center + Vector2(eye_x, -37) * k
		draw_circle(eye_center, 12.5 * k, Color(0.025, 0.035, 0.02, 0.94))
		_draw_glow(eye_center, 20.0 * k, Color(EYE.r, EYE.g, EYE.b, 0.14))
		draw_circle(eye_center, 5.3 * k, EYE)

func _draw_lower_sanctuary(s: Vector2) -> void:
	var altar_y := s.y * 0.70
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.87), s.x * 0.48, Color(0.95, 0.40, 0.10, 0.060))
	_draw_glow(Vector2(s.x * 0.52, s.y * 0.91), s.x * 0.28, Color(0.20, 0.70, 0.16, 0.045))

	draw_colored_polygon(PackedVector2Array([
		Vector2(s.x * 0.05, altar_y), Vector2(s.x * 0.95, altar_y), Vector2(s.x, s.y), Vector2(0, s.y)
	]), Color("171008"))
	draw_line(Vector2(s.x * 0.045, altar_y), Vector2(s.x * 0.955, altar_y), Color(0.60, 0.40, 0.17, 0.50), 3.0)

	# Perspectiva del piso hacia un punto de fuga central.
	var vanishing := Vector2(s.x * 0.50, s.y * 0.72)
	for x_fraction in [0.04, 0.19, 0.34, 0.66, 0.81, 0.96]:
		draw_line(Vector2(s.x * x_fraction, s.y), vanishing, Color(0.50, 0.28, 0.10, 0.16), 2.0)
	for i in range(5):
		var yy := altar_y + (s.y - altar_y) * float(i + 1) / 6.0
		draw_line(Vector2(s.x * 0.03, yy), Vector2(s.x * 0.97, yy), Color(0.50, 0.30, 0.12, 0.12), 2.0)

	# Raíces gruesas en primer plano, con trayectorias diferentes a cada lado.
	_draw_root(PackedVector2Array([
		Vector2(-8, s.y * 0.98), Vector2(s.x * 0.12, s.y * 0.90), Vector2(s.x * 0.23, s.y * 0.83), Vector2(s.x * 0.39, s.y * 0.77)
	]), 16.0)
	_draw_root(PackedVector2Array([
		Vector2(s.x + 8, s.y * 0.96), Vector2(s.x * 0.84, s.y * 0.89), Vector2(s.x * 0.73, s.y * 0.84), Vector2(s.x * 0.59, s.y * 0.76)
	]), 18.0)
	_draw_root(PackedVector2Array([
		Vector2(s.x * 0.17, s.y + 4), Vector2(s.x * 0.29, s.y * 0.92), Vector2(s.x * 0.43, s.y * 0.86)
	]), 11.0)

	# Piedras y runas del suelo: dispersión irregular, no tres iconos alineados.
	_draw_stone(Vector2(s.x * 0.15, s.y * 0.87), Vector2(54, 28), -0.16)
	_draw_stone(Vector2(s.x * 0.76, s.y * 0.92), Vector2(68, 32), 0.12)
	_draw_stone(Vector2(s.x * 0.47, s.y * 0.96), Vector2(46, 24), -0.08)
	_draw_floor_rune(Vector2(s.x * 0.24, s.y * 0.91), 27.0, -0.14)
	_draw_floor_rune(Vector2(s.x * 0.58, s.y * 0.88), 32.0, 0.10)
	_draw_floor_rune(Vector2(s.x * 0.84, s.y * 0.84), 22.0, -0.05)

func _draw_tree_column(rect: Rect2, mirror: bool) -> void:
	draw_rect(rect, BARK)
	draw_rect(rect.grow(-5), BARK_LIGHT)
	var x := rect.end.x - 5.0 if mirror else rect.position.x + 5.0
	for i in range(8):
		var yy := rect.position.y + rect.size.y * (0.055 + float(i) * 0.124)
		var length := rect.size.x * (0.48 + 0.13 * float(i % 3))
		var branch_end := Vector2(rect.position.x - length, yy - 26.0 - float(i % 2) * 13.0) if mirror else Vector2(rect.end.x + length, yy - 26.0 - float(i % 2) * 13.0)
		draw_line(Vector2(x, yy), branch_end, BARK_LIGHT, 5.0)

func _draw_candle_cluster(center: Vector2, scale: float, skew: float) -> void:
	var offsets := PackedVector2Array([
		Vector2(-31, 9), Vector2(-14, -12), Vector2(4, 7), Vector2(22, -18), Vector2(39, 11)
	])
	for i in range(offsets.size()):
		var item := offsets[i] + Vector2(skew * (float(i) - 2.0) * 0.12, 0)
		var p := center + item * scale
		var candle_h := (28.0 + absf(item.y) * 0.48 + float((i * 7) % 9)) * scale
		draw_rect(Rect2(p.x - 4.5 * scale, p.y - candle_h, 9.0 * scale, candle_h), Color("c89a64"))
		var flicker := sin(phase * (3.6 + float(i) * 0.1) + p.x * 0.011) * 2.4 * scale
		_draw_glow(Vector2(p.x, p.y - candle_h - 6 * scale), 28.0 * scale, Color(1.0, 0.50, 0.12, 0.10))
		draw_circle(Vector2(p.x + flicker, p.y - candle_h - 6 * scale), 4.7 * scale, FIRE)
		draw_circle(Vector2(p.x + flicker * 0.5, p.y - candle_h - 7 * scale), 1.9 * scale, Color("fff2b0"))

func _draw_lantern(center: Vector2, radius: float) -> void:
	_draw_glow(center, radius * 5.4, Color(1.0, 0.45, 0.10, 0.10))
	var body := Rect2(center.x - radius * 0.72, center.y - radius * 1.45, radius * 1.44, radius * 2.55)
	draw_rect(body, Color("2b1b0d"))
	draw_rect(body.grow(-2), Color("713a16"), false, 2.0)
	draw_circle(center, radius * 0.60, Color(FIRE.r, FIRE.g, FIRE.b, 0.88))
	draw_circle(center, radius * 0.27, Color("fff0a8"))

func _draw_vine(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, VINE, 4.0, true)
	for i in range(points.size()):
		var p := points[i]
		var leaf_offset := Vector2(8 if i % 2 == 0 else -8, -4 if i % 3 else 3)
		draw_circle(p + leaf_offset, 5.0, MOSS)

func _draw_root(points: PackedVector2Array, width: float) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, ROOT_DARK, width + 5.0, true)
	draw_polyline(points, ROOT_LIGHT, width, true)
	draw_polyline(points, Color(0.58, 0.35, 0.15, 0.50), maxf(1.5, width * 0.14), true)

func _draw_stone(center: Vector2, stone_size: Vector2, rotation_hint: float) -> void:
	var w := stone_size.x * 0.5
	var h := stone_size.y * 0.5
	var skew := rotation_hint * 22.0
	var poly := PackedVector2Array([
		center + Vector2(-w, 2 + skew),
		center + Vector2(-w * 0.45, -h),
		center + Vector2(w * 0.55, -h * 0.82),
		center + Vector2(w, 1 - skew),
		center + Vector2(w * 0.35, h),
		center + Vector2(-w * 0.62, h * 0.82)
	])
	draw_colored_polygon(poly, Color("251b12"))
	var outline := poly.duplicate()
	outline.append(poly[0])
	draw_polyline(outline, Color(0.42, 0.29, 0.15, 0.55), 2.0, true)

func _draw_floor_rune(center: Vector2, radius: float, rotation_hint: float) -> void:
	_draw_glow(center, radius * 2.3, Color(RUNE.r, RUNE.g, RUNE.b, 0.055))
	draw_arc(center, radius, rotation_hint, TAU + rotation_hint, 24, Color(RUNE.r, RUNE.g, RUNE.b, 0.25), 2.0)
	var a := center + Vector2(cos(rotation_hint - 0.55), sin(rotation_hint - 0.55)) * radius * 0.72
	var b := center + Vector2(cos(rotation_hint + 2.25), sin(rotation_hint + 2.25)) * radius * 0.72
	draw_line(a, b, Color(RUNE.r, RUNE.g, RUNE.b, 0.28), 2.2)
	var c := center + Vector2(cos(rotation_hint + 0.95), sin(rotation_hint + 0.95)) * radius * 0.55
	var d := center + Vector2(cos(rotation_hint + 3.95), sin(rotation_hint + 3.95)) * radius * 0.55
	draw_line(c, d, Color(RUNE.r, RUNE.g, RUNE.b, 0.22), 1.8)

func _draw_small_rune(center: Vector2, radius: float, alpha: float) -> void:
	var pts := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.72, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.72, 0),
		center + Vector2(0, -radius)
	])
	draw_polyline(pts, Color(RUNE.r, RUNE.g, RUNE.b, alpha), 1.8, true)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var f := float(i) / 7.0
		var c := color
		c.a *= 1.0 - f * 0.76
		draw_circle(center, radius * f, c)
