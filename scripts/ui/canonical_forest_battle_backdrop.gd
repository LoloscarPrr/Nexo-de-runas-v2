class_name CanonicalForestBattleBackdrop
extends Control

var phase := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var s := size
	if s.x <= 0.0 or s.y <= 0.0:
		return

	# Bosque oscuro: fondo, niebla y luz ritual.
	draw_rect(Rect2(Vector2.ZERO, s), Color("07100a"))
	_draw_glow(Vector2(s.x * 0.17, s.y * 0.22), 180.0, Color(0.26, 0.42, 0.16, 0.10))
	_draw_glow(Vector2(s.x * 0.82, s.y * 0.18), 150.0, Color(0.54, 0.35, 0.10, 0.08))
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.50), 340.0, Color(0.20, 0.30, 0.10, 0.08))

	# Mesa física en perspectiva.
	var table := PackedVector2Array([
		Vector2(s.x * 0.10, s.y * 0.12),
		Vector2(s.x * 0.90, s.y * 0.12),
		Vector2(s.x * 0.985, s.y * 0.92),
		Vector2(s.x * 0.015, s.y * 0.92)
	])
	draw_colored_polygon(table, Color("17180f"))
	for i in range(8):
		var y := lerpf(s.y * 0.16, s.y * 0.88, float(i) / 7.0)
		draw_line(Vector2(s.x * 0.055, y), Vector2(s.x * 0.945, y), Color(0.37, 0.30, 0.16, 0.14), 2.0)

	# Marco de raíces y ramas.
	_draw_root(PackedVector2Array([
		Vector2(0, s.y * 0.18), Vector2(s.x * 0.06, s.y * 0.22), Vector2(s.x * 0.03, s.y * 0.34),
		Vector2(s.x * 0.09, s.y * 0.43), Vector2(s.x * 0.05, s.y * 0.62), Vector2(s.x * 0.12, s.y * 0.78)
	]), Color("27351a"), 18.0)
	_draw_root(PackedVector2Array([
		Vector2(s.x, s.y * 0.14), Vector2(s.x * 0.94, s.y * 0.25), Vector2(s.x * 0.97, s.y * 0.38),
		Vector2(s.x * 0.91, s.y * 0.54), Vector2(s.x * 0.96, s.y * 0.70), Vector2(s.x * 0.89, s.y * 0.86)
	]), Color("2c3218"), 17.0)

	# Runas suaves alrededor del tablero.
	for i in range(7):
		var x := s.x * (0.30 + 0.065 * i)
		var pulse := 0.55 + sin(phase * 1.6 + float(i)) * 0.18
		var c := Color(0.55, 0.67, 0.25, 0.18 * pulse)
		draw_circle(Vector2(x, s.y * 0.46), 13.0, c)
		draw_line(Vector2(x - 6, s.y * 0.46), Vector2(x + 6, s.y * 0.46), Color(c.r, c.g, c.b, c.a * 1.5), 2.0)

	# Velas rituales en las esquinas.
	_draw_candle(Vector2(s.x * 0.12, s.y * 0.12), 0.0)
	_draw_candle(Vector2(s.x * 0.88, s.y * 0.10), 1.7)
	_draw_candle(Vector2(s.x * 0.93, s.y * 0.72), 3.1)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(6, 0, -1):
		var factor := float(i) / 6.0
		var c := color
		c.a *= (1.0 - factor * 0.78)
		draw_circle(center, radius * factor, c)

func _draw_root(points: PackedVector2Array, color: Color, width: float) -> void:
	draw_polyline(points, Color(0.03, 0.05, 0.02, 0.75), width + 7.0, true)
	draw_polyline(points, color, width, true)

func _draw_candle(base: Vector2, offset: float) -> void:
	var flicker := sin(phase * 4.0 + offset) * 3.0
	draw_rect(Rect2(base + Vector2(-5, 7), Vector2(10, 30)), Color("80683e"))
	_draw_glow(base + Vector2(flicker * 0.2, 2), 54.0 + flicker, Color(0.96, 0.60, 0.16, 0.12))
	draw_circle(base + Vector2(flicker * 0.35, 2), 7.0, Color(1.0, 0.72, 0.24, 0.90))
	draw_circle(base + Vector2(flicker * 0.45, -2), 3.4, Color(1.0, 0.93, 0.60, 0.95))
