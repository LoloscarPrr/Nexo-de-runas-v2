extends Control

const Palette = preload("res://scripts/ui/mockup_hud/resource_palette.gd")

var current := 1
var maximum := 1
var flash_strength := 0.0
var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	flash_strength = maxf(0.0, flash_strength - delta * 3.6)
	queue_redraw()

func flash() -> void:
	flash_strength = 1.0

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	var font := ThemeDB.fallback_font
	var label_h := h * 0.34
	draw_string(font, Vector2(0, label_h * 0.78), "ENERGÍA", HORIZONTAL_ALIGNMENT_LEFT, w, int(clampf(label_h * 0.65, 9, 13)), Palette.ENERGY)

	var cap := 6
	var gap := maxf(2.0, w * 0.012)
	var top := label_h + 2.0
	var cell_h := h - top - 3.0
	var cell_w := (w - gap * float(cap - 1)) / float(cap)
	for i in range(cap):
		var rect := Rect2(float(i) * (cell_w + gap), top, cell_w, cell_h)
		var unlocked := i < maximum
		var filled := i < current
		var base := Palette.ENERGY_DIM if unlocked else Color("17242a")
		if filled:
			var pulse := 0.93 + sin(time * 2.2 + float(i) * 0.4) * 0.05
			base = Palette.ENERGY.lerp(Color.WHITE, flash_strength * 0.14) * pulse
		draw_rect(rect, Color("071011"))
		draw_rect(rect.grow(-2), base)
		draw_rect(rect, Palette.OLIVE_EDGE, false, 1.0)
		if unlocked:
			# Corte rúnico: evita que parezca una batería sci-fi limpia.
			draw_line(rect.position + Vector2(cell_w * 0.25, cell_h * 0.72), rect.position + Vector2(cell_w * 0.74, cell_h * 0.25), Color(0,0,0,0.28), 1.0)
