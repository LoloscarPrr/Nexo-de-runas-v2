extends TextureRect

const SketchAtlasScript = preload("res://scripts/ui/mockup_hud/sketch_atlas.gd")

## Animador común para los bocetos canónicos extraídos del mockup.
## El movimiento debe sentirse físico: respiración, flotación, deriva y reacción,
## nunca como widgets flotantes independientes del tablero.
var sketch_key := ""
var float_pixels := 0.0
var drift_pixels := Vector2.ZERO
var sway_degrees := 0.0
var breathe_scale := 0.0
var pulse_glow := false
var glow_strength := 0.045
var flicker_strength := 0.0
var phase_offset := 0.0
var pivot_ratio := Vector2(0.5, 0.5)
var target_rotation_degrees := 0.0
var time := 0.0
var hit_strength := 0.0
var flash_strength := 0.0
var surrender_dim := false
var _base_position := Vector2.ZERO
var _base_set := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if not sketch_key.is_empty():
		texture = SketchAtlasScript.texture_for(sketch_key)
	pivot_offset = size * pivot_ratio
	resized.connect(_update_pivot)
	set_process(true)
	call_deferred("_capture_base")

func _capture_base() -> void:
	_base_position = position
	_base_set = true
	_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size * pivot_ratio

func hit() -> void:
	hit_strength = 1.0

func flash() -> void:
	flash_strength = 1.0

func _process(delta: float) -> void:
	time += delta
	hit_strength = maxf(0.0, hit_strength - delta * 5.4)
	flash_strength = maxf(0.0, flash_strength - delta * 2.8)
	if not _base_set:
		return

	var phase := time + phase_offset
	var float_y := sin(phase * TAU / 2.15) * float_pixels
	var drift_x := sin(phase * TAU / 3.7 + 0.65) * drift_pixels.x
	var drift_y := cos(phase * TAU / 3.1 + 1.10) * drift_pixels.y
	var shake_x := sin(time * 76.0 + phase_offset) * 5.0 * hit_strength
	var shake_y := cos(time * 58.0 + phase_offset * 0.7) * 1.8 * hit_strength
	position = _base_position + Vector2(drift_x + shake_x, float_y + drift_y + shake_y)

	var idle_sway := sin(phase * TAU / 2.55) * sway_degrees
	var impact_sway := sin(time * 91.0) * 1.5 * hit_strength
	rotation_degrees = target_rotation_degrees + idle_sway + impact_sway

	var breath_wave := sin(phase * TAU / 2.45)
	var breathing := 1.0 + breath_wave * breathe_scale
	var flash_pop := 1.0 + flash_strength * 0.045
	var hit_squash := 1.0 - hit_strength * 0.018
	scale = Vector2(breathing * flash_pop, breathing * flash_pop * hit_squash)

	var alpha := 0.68 if surrender_dim else 1.0
	var glow_wave := 0.5 + 0.5 * sin(phase * 2.25)
	var glow := glow_strength * glow_wave if pulse_glow else 0.0
	var flicker := 0.0
	if flicker_strength > 0.0:
		flicker = (sin(phase * 13.7) * 0.5 + sin(phase * 31.1) * 0.25) * flicker_strength
	var add := 0.12 * flash_strength + glow + flicker
	modulate = Color(1.0 + add, 1.0 + add, 1.0 + add * 0.55, alpha)
