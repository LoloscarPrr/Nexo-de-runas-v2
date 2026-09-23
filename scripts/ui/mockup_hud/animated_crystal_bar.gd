extends Control

const GLOW := Color("c4d75a")
const DIM := Color("4d5726")

var filled := 0
var time := 0.0
var flash_strength := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	flash_strength = maxf(0.0, flash_strength - delta * 4.0)
	queue_redraw()

func flash() -> void:
	flash_strength = 1.0

func _draw() -> void:
	var count := 3
	var spacing := size.x / 4.0
	for i in range(count):
		var phase := time * 2.4 + float(i) * 0.85
		var active := i < filled
		var pulse := 0.88 + sin(phase) * 0.08
		var r := minf(size.y * 0.28, 13.0) * (1.0 + flash_strength * 0.12)
		var c := GLOW if active else DIM
		c = c.lerp(Color.WHITE, flash_strength * 0.18 if active else 0.0)
		var center := Vector2(spacing * float(i + 1), size.y * 0.5)
		var pts := PackedVector2Array([
			center + Vector2(0, -r * pulse),
			center + Vector2(r * 0.72 * pulse, 0),
			center + Vector2(0, r * pulse),
			center + Vector2(-r * 0.72 * pulse, 0)
		])
		draw_colored_polygon(pts, c)
		draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color("11170d"), 1.5)
