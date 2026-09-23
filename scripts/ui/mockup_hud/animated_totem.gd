extends Control

const GLOW := Color("c4d75a")
const BG := Color("070a06")

var time := 0.0
var pulse := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	pulse = maxf(0.0, pulse - delta * 2.8)
	queue_redraw()

func flash() -> void:
	pulse = 1.0

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	var float_y := sin(time * TAU / 1.8) * 2.5
	var pos := Vector2(w * 0.5, h * 0.46 + float_y)
	var factor := minf(w / 110.0, h / 120.0)
	var glow := GLOW.lerp(Color.WHITE, pulse * 0.20)
	var radius := 34.0 * factor

	draw_circle(pos, radius, glow)
	draw_circle(pos + Vector2(-12, -2) * factor, 7 * factor, BG)
	draw_circle(pos + Vector2(12, -2) * factor, 7 * factor, BG)
	draw_rect(Rect2(pos.x - 11 * factor, pos.y + 15 * factor, 22 * factor, 13 * factor), BG)
	for angle in range(0, 360, 45):
		var a := deg_to_rad(float(angle))
		var p1 := pos + Vector2(cos(a), sin(a)) * 39.0 * factor
		var p2 := pos + Vector2(cos(a), sin(a)) * (55.0 + pulse * 5.0) * factor
		draw_line(p1, p2, glow, maxf(2.0, 5.0 * factor))
