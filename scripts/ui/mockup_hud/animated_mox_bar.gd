extends Control

const Palette = preload("res://scripts/ui/mockup_hud/resource_palette.gd")

var green_active := false
var orange_active := false
var blue_active := false
var flash_strength := 0.0
var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	flash_strength = maxf(0.0, flash_strength - delta * 3.4)
	queue_redraw()

func flash() -> void:
	flash_strength = 1.0

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, h * 0.27), "MOX", HORIZONTAL_ALIGNMENT_LEFT, w, int(clampf(h * 0.20, 9, 13)), Palette.OLIVE_GLOW)

	var colors := ["green", "orange", "blue"]
	var states := [green_active, orange_active, blue_active]
	var y := h * 0.67
	var spacing := w / 4.0
	var r := minf(h * 0.24, w * 0.085)
	for i in range(3):
		var active: bool = bool(states[i])
		var center := Vector2(spacing * float(i + 1), y)
		var pulse := 1.0 + (0.05 * sin(time * 2.0 + float(i)) if active else 0.0)
		var rr := r * pulse * (1.0 + flash_strength * 0.08)
		var color := Palette.mox_color(colors[i], active)
		if active:
			color = color.lerp(Color.WHITE, flash_strength * 0.12)
		var points := PackedVector2Array([
			center + Vector2(0, -rr),
			center + Vector2(rr * 0.68, -rr * 0.12),
			center + Vector2(rr * 0.42, rr * 0.72),
			center + Vector2(0, rr),
			center + Vector2(-rr * 0.42, rr * 0.72),
			center + Vector2(-rr * 0.68, -rr * 0.12)
		])
		draw_colored_polygon(points, color)
		draw_polyline(PackedVector2Array([points[0],points[1],points[2],points[3],points[4],points[5],points[0]]), Palette.DEEP, 2.0)
		# Facetas internas para que el código visual sea "cristal", no celda.
		draw_line(center + Vector2(0,-rr*0.8), center + Vector2(0,rr*0.75), Color(0,0,0,0.30), 1.0)
		draw_line(center, center + Vector2(rr*0.52,-rr*0.10), Color(1,1,1,0.10 if active else 0.03), 1.0)
