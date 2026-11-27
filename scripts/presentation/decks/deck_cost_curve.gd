class_name DeckCostCurve
extends Control

var distribution: Array = [0, 0, 0, 0, 0, 0, 0]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func set_distribution(value: Array) -> void:
	distribution = value.duplicate()
	queue_redraw()

func _draw() -> void:
	var step := size.x / 7.0
	var maximum := maxi(int(distribution.max()), 1)
	var base := size.y - 23.0
	for cost in range(7):
		var center := (cost + 0.5) * step
		var height := float(distribution[cost]) / maximum * maxf(base - 26.0, 1.0)
		draw_line(Vector2(center - step * 0.30, base), Vector2(center + step * 0.30, base), Color("755426"), 2.0)
		if height > 0.0:
			draw_rect(Rect2(center - step * 0.22, base - height, step * 0.44, height), Color("78b94e"))
		draw_string(ThemeDB.fallback_font, Vector2(center - step * 0.4, base - height - 5), str(distribution[cost]), HORIZONTAL_ALIGNMENT_CENTER, step * 0.8, 20, Color("eadca8"))
		draw_string(ThemeDB.fallback_font, Vector2(center - step * 0.4, size.y - 2), "6+" if cost == 6 else str(cost), HORIZONTAL_ALIGNMENT_CENTER, step * 0.8, 19, Color("d5a94f"))
