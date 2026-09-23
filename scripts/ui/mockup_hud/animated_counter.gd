extends Control

const GLOW := Color("c4d75a")
const MUTED := Color("59612f")

var text_value := ""
var time := 0.0
var pop_strength := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	pop_strength = maxf(0.0, pop_strength - delta * 5.0)
	queue_redraw()

func animate_change() -> void:
	pop_strength = 1.0

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var pulse_scale := 1.0 + pop_strength * 0.18
	var fs := int(clampf(size.y * 0.48 * pulse_scale, 12.0, 26.0))
	var color := GLOW.lerp(Color.WHITE, pop_strength * 0.22)
	draw_string(font, Vector2(0, size.y * 0.72), text_value, HORIZONTAL_ALIGNMENT_CENTER, size.x, fs, color)
