extends Control

var balance := 0
var ambience_time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	ambience_time += delta
	queue_redraw()

func _draw() -> void:
	var w := maxf(size.x, 1280.0)
	var h := maxf(size.y, 720.0)
	var horizon := 76.0
	draw_rect(Rect2(0, 0, w, h), Color("090705"))
	draw_rect(Rect2(0, 0, w, 190), Color("110d09"))
	for i in range(int(w / 78.0) + 2):
		var x := float(i) * 78.0
		draw_line(Vector2(x, 0), Vector2(x, 210), Color("241a11"), 3)
	draw_colored_polygon(PackedVector2Array([Vector2(w * 0.14, horizon), Vector2(w * 0.82, horizon), Vector2(w + 90, h + 10), Vector2(-90, h + 10)]), Color("332419"))
	for i in range(13):
		var t := float(i) / 12.0
		draw_line(Vector2(lerpf(w * 0.14, w * 0.82, t), horizon), Vector2(lerpf(-70.0, w + 70.0, t), h), Color("17100b"), 4)
	for i in range(100):
		var y := 104.0 + fmod(float(i * 71), maxf(1.0, h - 118.0))
		var x := 24.0 + fmod(float(i * 173), maxf(1.0, w - 48.0))
		draw_line(Vector2(x, y), Vector2(minf(w - 10.0, x + 22.0 + float(i % 69)), y + 2), Color(0.7, 0.47, 0.24, 0.075), 1)
	var board_width := minf(790.0, maxf(690.0, w - 510.0))
	var board_left := (w - board_width) * 0.5
	draw_rect(Rect2(board_left - 16, 92, board_width + 32, 384), Color(0.025, 0.018, 0.012, 0.48))
	draw_rect(Rect2(board_left - 5, 101, board_width + 10, 366), Color(0.38, 0.26, 0.14, 0.08), false, 2)

	var gx := w - 140.0
	draw_colored_polygon(PackedVector2Array([Vector2(gx - 112, 327), Vector2(gx - 94, 224), Vector2(gx - 46, 185), Vector2(gx + 54, 192), Vector2(gx + 112, 331)]), Color("0e0c09"))
	draw_circle(Vector2(gx, 151), 68, Color("12110d"))
	draw_colored_polygon(PackedVector2Array([Vector2(gx - 66, 128), Vector2(gx - 56, 80), Vector2(gx - 16, 56), Vector2(gx + 48, 80), Vector2(gx + 70, 138), Vector2(gx + 31, 108), Vector2(gx - 25, 101)]), Color("060604"))
	var eye_glow := 0.72 + sin(ambience_time * 1.7) * 0.13
	for eye in [Vector2(gx - 27, 148), Vector2(gx + 25, 148)]:
		draw_circle(eye, 12, Color(0.77, 0.41, 0.13, 0.07))
		draw_circle(eye, 4, Color(0.82, 0.59, 0.31, eye_glow))
		draw_circle(eye + Vector2(1, 0), 2, Color("21150b"))
	draw_line(Vector2(gx - 20, 188), Vector2(gx + 20, 182), Color("3b2c1d"), 2)

	var brass := Color("aa8750")
	var tilt := float(clampi(balance, -5, 5)) * 7.0
	var sx := 139.0
	draw_line(Vector2(sx, 228), Vector2(sx, 381), brass, 8, true)
	draw_line(Vector2(sx - 39, 386), Vector2(sx + 39, 386), brass, 9, true)
	var left := Vector2(sx - 72, 257 - tilt)
	var right := Vector2(sx + 72, 257 + tilt)
	draw_line(left, right, brass, 5, true)
	draw_circle(Vector2(sx, 257), 9, brass)
	for point in [left, right]:
		draw_line(point, point + Vector2(-26, 56), brass, 1.5, true)
		draw_line(point, point + Vector2(26, 56), brass, 1.5, true)
		draw_colored_polygon(PackedVector2Array([point + Vector2(-31, 56), point + Vector2(31, 56), point + Vector2(18, 69), point + Vector2(-18, 69)]), brass)

	var cx := w - 355.0
	var wobble := sin(ambience_time * 5.7) * 3.2 + sin(ambience_time * 2.3) * 1.8
	for radius in range(18, 128, 10):
		draw_circle(Vector2(cx, 356), float(radius), Color(0.92, 0.48, 0.10, 0.012))
	draw_rect(Rect2(cx - 11, 366, 22, 58), Color("b8a178"))
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 6 + wobble * 0.25, 363), Vector2(cx + wobble, 340), Vector2(cx + 8 + wobble * 0.15, 361), Vector2(cx + 1, 370)]), Color("efbd70"))
	draw_rect(Rect2(0, 0, 26, h), Color(0, 0, 0, 0.38))
	draw_rect(Rect2(w - 26, 0, 26, h), Color(0, 0, 0, 0.38))
