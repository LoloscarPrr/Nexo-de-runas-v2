extends Button

const EDGE := Color("697337")
const EDGE_DIM := Color("30391d")
const PAPER := Color("74723e")
const DARK := Color("11170d")
const GLOW := Color("c8d95b")

var deck_label := "MAZO"
var count := 0
var mirrored := false
var pulse_active := false
var time := 0.0
var draw_strength := 0.0
var press_strength := 0.0

func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	draw_strength = maxf(0.0, draw_strength - delta * 4.5)
	press_strength = maxf(0.0, press_strength - delta * 8.0)
	var idle := sin(time * TAU / 2.0) * 0.008 if pulse_active and not disabled else 0.0
	scale = Vector2.ONE * (1.0 + idle - press_strength * 0.03)
	queue_redraw()

func animate_draw() -> void:
	draw_strength = 1.0

func _on_down() -> void:
	press_strength = 1.0

func _on_up() -> void:
	press_strength = 0.45

func _draw() -> void:
	var w := maxf(size.x, 1.0)
	var h := maxf(size.y, 1.0)
	var lift := -8.0 * sin(draw_strength * PI)
	var alpha := 0.40 if disabled else 1.0
	var edge := EDGE_DIM if disabled else EDGE
	for i in range(7):
		var dir := -1.0 if mirrored else 1.0
		var off := Vector2(float(i) * 1.5 * dir, -float(i) * 4.0 + lift)
		var rect := Rect2(Vector2(w * 0.12, h * 0.10) + off, Vector2(w * 0.76, h * 0.70))
		draw_rect(rect, Color(PAPER, alpha))
		draw_rect(rect.grow(-4), Color(DARK, alpha), false, 2)
		draw_rect(rect.grow(-7), Color(edge, alpha), false, 1)

	var font := ThemeDB.fallback_font
	var color := Color(GLOW, alpha)
	draw_string(font, Vector2(0, h * 0.86), deck_label, HORIZONTAL_ALIGNMENT_CENTER, w, int(clampf(h * 0.105, 10, 14)), color)
	draw_string(font, Vector2(0, h * 0.98), str(count), HORIZONTAL_ALIGNMENT_CENTER, w, int(clampf(h * 0.14, 12, 18)), color)
