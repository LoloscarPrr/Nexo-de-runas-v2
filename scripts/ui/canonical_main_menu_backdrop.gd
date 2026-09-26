class_name CanonicalMainMenuBackdrop
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

	# Oscuridad de cabaña y bosque al fondo.
	draw_rect(Rect2(Vector2.ZERO, s), Color("060805"))
	var window := Rect2(s.x * 0.30, s.y * 0.045, s.x * 0.40, s.y * 0.29)
	draw_rect(window.grow(8), Color("120f08"))
	draw_rect(window, Color("08110b"))
	for i in range(11):
		var x := window.position.x + window.size.x * float(i) / 10.0
		var crown := sin(float(i) * 1.7) * 14.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 28, window.end.y), Vector2(x, window.position.y + 34 + crown), Vector2(x + 30, window.end.y)
		]), Color(0.035, 0.075, 0.040, 0.92))
	_draw_glow(Vector2(s.x * 0.50, s.y * 0.22), 260.0, Color(0.20, 0.32, 0.12, 0.10))

	# Paredes de madera verticales.
	for i in range(16):
		var x := s.x * float(i) / 16.0
		draw_rect(Rect2(x, 0, s.x / 16.0 + 2, s.y * 0.42), Color(0.10 + (i % 3) * 0.008, 0.085, 0.045, 0.48))
		draw_line(Vector2(x, 0), Vector2(x, s.y * 0.42), Color(0, 0, 0, 0.22), 2)

	# Mesa física ocupando la mitad inferior.
	var table := PackedVector2Array([
		Vector2(s.x * 0.08, s.y * 0.39), Vector2(s.x * 0.92, s.y * 0.39),
		Vector2(s.x, s.y), Vector2(0, s.y)
	])
	draw_colored_polygon(table, Color("20160d"))
	for i in range(7):
		var y := lerpf(s.y * 0.44, s.y * 0.96, float(i) / 6.0)
		draw_line(Vector2(s.x * 0.035, y), Vector2(s.x * 0.965, y), Color(0.40, 0.27, 0.12, 0.22), 2)

	# Un libro/mapa físico central bajo las opciones.
	var book := Rect2(s.x * 0.31, s.y * 0.43, s.x * 0.38, s.y * 0.43)
	draw_rect(book.grow(8), Color(0, 0, 0, 0.45))
	draw_rect(book, Color("5e4a2a"))
	draw_rect(book.grow(-7), Color("9b895c"))
	draw_line(Vector2(book.get_center().x, book.position.y + 8), Vector2(book.get_center().x, book.end.y - 8), Color("43331d"), 3)
	for i in range(5):
		var yy := book.position.y + 36 + i * 38
		draw_line(Vector2(book.position.x + 28, yy), Vector2(book.get_center().x - 22, yy), Color(0.20, 0.16, 0.09, 0.30), 1)
		draw_line(Vector2(book.get_center().x + 22, yy), Vector2(book.end.x - 28, yy), Color(0.20, 0.16, 0.09, 0.30), 1)

	# Objetos que evocan los cuatro dominios sin convertir la pantalla en collage.
	_draw_domain_totem(Vector2(s.x * 0.12, s.y * 0.69), Color("65783b"), 0)
	_draw_domain_totem(Vector2(s.x * 0.22, s.y * 0.77), Color("754764"), 1)
	_draw_domain_totem(Vector2(s.x * 0.78, s.y * 0.76), Color("554f86"), 2)
	_draw_domain_totem(Vector2(s.x * 0.88, s.y * 0.68), Color("a45c2b"), 3)

	# Velas y luz cálida.
	_draw_candle(Vector2(s.x * 0.16, s.y * 0.34), 0.0)
	_draw_candle(Vector2(s.x * 0.84, s.y * 0.33), 1.8)
	_draw_candle(Vector2(s.x * 0.73, s.y * 0.56), 3.2)

	# Raíces discretas en el marco.
	_draw_root(PackedVector2Array([Vector2(0, s.y * 0.30), Vector2(s.x * 0.055, s.y * 0.38), Vector2(s.x * 0.025, s.y * 0.55), Vector2(s.x * 0.08, s.y * 0.69)]))
	_draw_root(PackedVector2Array([Vector2(s.x, s.y * 0.24), Vector2(s.x * 0.95, s.y * 0.36), Vector2(s.x * 0.98, s.y * 0.54), Vector2(s.x * 0.93, s.y * 0.70)]))

func _draw_domain_totem(pos: Vector2, color: Color, kind: int) -> void:
	draw_circle(pos + Vector2(3, 5), 29, Color(0, 0, 0, 0.34))
	draw_circle(pos, 27, Color("17120b"))
	draw_arc(pos, 22, 0, TAU, 32, color, 3)
	match kind:
		0:
			draw_line(pos + Vector2(0, -15), pos + Vector2(0, 15), color, 3)
			draw_line(pos + Vector2(-10, 5), pos + Vector2(0, -4), color, 3)
			draw_line(pos + Vector2(10, 5), pos + Vector2(0, -4), color, 3)
		1:
			draw_circle(pos + Vector2(-7, -2), 3, color)
			draw_circle(pos + Vector2(7, -2), 3, color)
			draw_line(pos + Vector2(-10, 8), pos + Vector2(10, 8), color, 3)
		2:
			for a in range(0, 360, 60):
				var r := deg_to_rad(float(a))
				draw_line(pos, pos + Vector2(cos(r), sin(r)) * 16, color, 2)
		3:
			draw_circle(pos, 9, color, false, 3)
			for a in range(0, 360, 45):
				var r := deg_to_rad(float(a))
				draw_line(pos + Vector2(cos(r), sin(r)) * 12, pos + Vector2(cos(r), sin(r)) * 18, color, 3)

func _draw_root(points: PackedVector2Array) -> void:
	draw_polyline(points, Color(0.025, 0.035, 0.02, 0.88), 20, true)
	draw_polyline(points, Color("27321d"), 12, true)

func _draw_glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(7, 0, -1):
		var f := float(i) / 7.0
		var c := color
		c.a *= 1.0 - f * 0.80
		draw_circle(center, radius * f, c)

func _draw_candle(base: Vector2, offset: float) -> void:
	var flicker := sin(phase * 4.1 + offset) * 3.0
	draw_rect(Rect2(base + Vector2(-6, 8), Vector2(12, 34)), Color("79613a"))
	_draw_glow(base + Vector2(flicker * 0.2, 2), 62 + flicker, Color(1.0, 0.58, 0.14, 0.14))
	draw_circle(base + Vector2(flicker * 0.35, 2), 7, Color(1.0, 0.69, 0.22, 0.92))
	draw_circle(base + Vector2(flicker * 0.4, -2), 3.2, Color(1.0, 0.94, 0.63, 0.98))
