extends Button

const SketchAtlasScript = preload("res://scripts/ui/mockup_hud/sketch_atlas.gd")

var sketch_key := ""
var pulse_active := false
var time := 0.0
var press_strength := 0.0
var _art: TextureRect
var _base_position := Vector2.ZERO
var _base_set := false

func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	_art = TextureRect.new()
	_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if not sketch_key.is_empty():
		_art.texture = SketchAtlasScript.texture_for(sketch_key)
	add_child(_art)
	pivot_offset = size * 0.5
	resized.connect(_sync_pivot)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(true)
	call_deferred("_sync_pivot")
	call_deferred("_capture_base")

func _capture_base() -> void:
	_base_position = position
	_base_set = true

func _sync_pivot() -> void:
	pivot_offset = size * 0.5
	if _art != null:
		_art.position = Vector2.ZERO
		_art.size = size

func _process(delta: float) -> void:
	time += delta
	press_strength = move_toward(press_strength, 0.0, delta * 8.0)
	var pulse := 1.0
	var lift := 0.0
	var sway := 0.0
	if pulse_active and not disabled:
		pulse += sin(time * TAU / 1.35) * 0.022
		lift = sin(time * TAU / 1.8) * 1.4
		sway = sin(time * TAU / 2.7) * 0.35
	scale = Vector2.ONE * pulse * (1.0 - press_strength * 0.045)
	rotation_degrees = sway + sin(time * 34.0) * press_strength * 0.35
	if _base_set:
		position = _base_position + Vector2(0, lift + press_strength * 2.0)
	if disabled:
		modulate = Color(0.46, 0.48, 0.35, 0.58)
	else:
		var glow := 0.025 + (0.025 * (0.5 + 0.5 * sin(time * 4.2)) if pulse_active else 0.0)
		modulate = Color(1.0 + glow, 1.0 + glow, 1.0 + glow * 0.55, 1.0)

func _on_down() -> void:
	press_strength = 1.0

func _on_up() -> void:
	press_strength = 0.45
