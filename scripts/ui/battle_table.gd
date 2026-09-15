extends Control

var balance := 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("0b0907"))
	# Cabin boards and converging tabletop create depth without expensive lighting.
	for i in range(17):
		var x := float(i) * 80.0
		draw_line(Vector2(x, 0), Vector2(x, 210), Color("211910"), 3)
	draw_colored_polygon(PackedVector2Array([Vector2(165, 74), Vector2(1050, 74), Vector2(1330, 720), Vector2(-50, 720)]), Color("33251a"))
	for i in range(11):
		var x := float(i) * 118.0
		draw_line(Vector2(180 + x * 0.7, 76), Vector2(x - 20, 720), Color("160f0b"), 4)
	for i in range(160):
		var y := 95.0 + fmod(float(i * 71), 620.0)
		var x := 30.0 + fmod(float(i * 173), 1180.0)
		draw_line(Vector2(x, y), Vector2(x + 23 + i % 61, y + 2), Color(0.64, 0.43, 0.23, 0.09), 1)
	draw_rect(Rect2(275, 98, 650, 367), Color(0.03, 0.02, 0.01, 0.45))
	# Opponent, barely visible behind the right edge of the table.
	draw_colored_polygon(PackedVector2Array([Vector2(972, 319), Vector2(995, 222), Vector2(1043, 184), Vector2(1175, 191), Vector2(1247, 328)]), Color("100e0b"))
	draw_circle(Vector2(1106, 150), 67, Color("14130f"))
	draw_colored_polygon(PackedVector2Array([Vector2(1039, 125), Vector2(1049, 79), Vector2(1090, 55), Vector2(1155, 79), Vector2(1177, 136), Vector2(1138, 108), Vector2(1082, 101)]), Color("080806"))
	for eye in [Vector2(1078, 147), Vector2(1130, 147)]:
		draw_circle(eye, 12, Color(0.77, 0.41, 0.13, 0.07))
		draw_circle(eye, 4, Color("d09950"))
		draw_circle(eye + Vector2(1, 0), 2, Color("22150b"))
	draw_line(Vector2(1085, 187), Vector2(1126, 181), Color("3c2e1e"), 2)
	# Brass balance: the beam moves with actual battle damage.
	var brass := Color("a9854d")
	var tilt := float(clampi(balance, -5, 5)) * 7.0
	draw_line(Vector2(139, 228), Vector2(139, 377), brass, 8, true)
	draw_line(Vector2(102, 382), Vector2(177, 382), brass, 9, true)
	var left := Vector2(67, 257 - tilt)
	var right := Vector2(210, 257 + tilt)
	draw_line(left, right, brass, 5, true)
	draw_circle(Vector2(139, 257), 9, brass)
	for point in [left, right]:
		draw_line(point, point + Vector2(-26, 56), brass, 1.5, true)
		draw_line(point, point + Vector2(26, 56), brass, 1.5, true)
		draw_colored_polygon(PackedVector2Array([point + Vector2(-31, 56), point + Vector2(31, 56), point + Vector2(18, 69), point + Vector2(-18, 69)]), brass)
	# Candle wax, flame and faint warm glow.
	for radius in range(8, 90, 8):
		draw_circle(Vector2(1020, 360), float(radius), Color(0.9, 0.48, 0.1, 0.012))
	draw_rect(Rect2(1010, 366, 20, 52), Color("b9a27a"))
	draw_colored_polygon(PackedVector2Array([Vector2(1015, 366), Vector2(1020, 344), Vector2(1027, 363), Vector2(1021, 371)]), Color("f1c071"))
