extends Button

const INK := Color("302217")
var card: Dictionary = {}
var marked := false
var chosen := false
var current_hp := -1

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	text = ""
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())

func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(5, 6, w - 5, h - 6), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(1, 1, w - 7, h - 8), Color("b5a078"))
	draw_rect(Rect2(6, 6, w - 17, h - 18), Color("4a3522"), false, 2)
	for i in range(14):
		var y := 12.0 + float(i) * (h - 30.0) / 14.0
		draw_line(Vector2(9, y), Vector2(w - 14, y + 2), Color(0.25, 0.18, 0.1, 0.09), 1)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(12, 24), str(card.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, w - 27, 15, INK)
	var cost := str(card.get("cost", ""))
	draw_string(font, Vector2(12, 41), cost, HORIZONTAL_ALIGNMENT_LEFT, w - 27, 11, Color("742f24") if card.get("resource") == "blood" else INK)
	# Original ink silhouette; all geometry scales with the physical card.
	draw_set_transform(Vector2(w * 0.5 - 3, h * 0.47), 0, Vector2(w / 145.0, h / 180.0))
	var id := str(card.get("id", ""))
	if id in ["gorrion", "buitre"]:
		draw_colored_polygon(PackedVector2Array([Vector2(-4, 5), Vector2(-45, -27), Vector2(-29, 13), Vector2(-9, 22), Vector2(0, 37), Vector2(10, 19), Vector2(37, 8), Vector2(49, -28), Vector2(8, -5), Vector2(4, -19), Vector2(-5, -15)]), INK)
	elif id == "vibora":
		draw_arc(Vector2(0, 12), 27, -1.0, 4.2, 26, INK, 12, true)
		draw_line(Vector2(17, -10), Vector2(3, -28), INK, 12, true)
		draw_circle(Vector2(2, -28), 10, INK)
	elif id == "rana_toro":
		draw_circle(Vector2(0, 10), 26, INK)
		draw_circle(Vector2(-20, -9), 12, INK)
		draw_circle(Vector2(20, -9), 12, INK)
		for side in [-1, 1]:
			draw_line(Vector2(side * 17, 15), Vector2(side * 38, 31), INK, 9, true)
			draw_circle(Vector2(side * 20, -10), 4, Color("b5a078"))
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-30, -33), Vector2(-10, -18), Vector2(12, -18), Vector2(31, -33), Vector2(27, 8), Vector2(15, 27), Vector2(0, 36), Vector2(-17, 23), Vector2(-28, 7)]), INK)
		draw_line(Vector2(-19, -1), Vector2(-8, 3), Color("b5a078"), 3)
		draw_line(Vector2(9, 3), Vector2(20, -1), Color("b5a078"), 3)
		draw_circle(Vector2(0, 19), 4, Color("b5a078"))
		if id == "ardilla":
			draw_arc(Vector2(29, 9), 16, -2, 2.8, 18, INK, 10, true)
		if id == "alce":
			for side in [-1, 1]:
				draw_line(Vector2(side * 22, -24), Vector2(side * 39, -43), INK, 4)
				draw_line(Vector2(side * 34, -38), Vector2(side * 22, -44), INK, 3)
	draw_set_transform(Vector2.ZERO)
	var seal := str(card.get("seal", "NINGUNO"))
	if seal != "NINGUNO":
		draw_string(font, Vector2(10, h - 39), seal, HORIZONTAL_ALIGNMENT_CENTER, w - 25, 10, INK)
	draw_string(font, Vector2(12, h - 15), str(card.get("atk", 0)), HORIZONTAL_ALIGNMENT_LEFT, 35, 25, INK)
	draw_string(font, Vector2(w - 43, h - 15), str(current_hp if current_hp >= 0 else card.get("hp", 1)), HORIZONTAL_ALIGNMENT_RIGHT, 25, 25, INK)
	if chosen or marked:
		draw_rect(Rect2(2, 2, w - 8, h - 9), Color("a23d2c") if marked else Color("e5c47b"), false, 4)
	if marked:
		draw_line(Vector2(19, 56), Vector2(w - 23, h - 50), Color("8c201a"), 5, true)
		draw_line(Vector2(w - 23, 56), Vector2(19, h - 50), Color("8c201a"), 5, true)
