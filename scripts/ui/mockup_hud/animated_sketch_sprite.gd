extends TextureRect

const SketchAtlasScript = preload("res://scripts/ui/mockup_hud/sketch_atlas.gd")

var sketch_key := ""
var float_pixels := 0.0
var sway_degrees := 0.0
var breathe_scale := 0.0
var pulse_glow := false
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
	pivot_offset = size * 0.5
	set_process(true)
	call_deferred("_capture_base")

func _capture_base() -> void:
	_base_position = position
	_base_set = true
	pivot_offset = size * 0.5

func hit() -> void:
	hit_strength = 1.0

func flash() -> void:
	flash_strength = 1.0

func _process(delta: float) -> void:
	time += delta
	hit_strength = maxf(0.0, hit_strength - delta * 6.5)
	flash_strength = maxf(0.0, flash_strength - delta * 3.5)
	if not _base_set:
		return

	var float_y := sin(time * TAU / 1.9) * float_pixels
	var shake_x := sin(time * 72.0) * 4.0 * hit_strength
	position = _base_position + Vector2(shake_x, float_y)
	rotation_degrees = target_rotation_degrees + sin(time * TAU / 2.2) * sway_degrees

	var breathing := 1.0 + sin(time * TAU / 2.3) * breathe_scale
	var flash_pop := 1.0 + flash_strength * 0.035
	scale = Vector2.ONE * breathing * flash_pop

	var alpha := 0.72 if surrender_dim else 1.0
	var glow := 0.04 * sin(time * 2.1) if pulse_glow else 0.0
	var add := 0.10 * flash_strength + glow
	modulate = Color(1.0 + add, 1.0 + add, 1.0 + add * 0.55, alpha)
