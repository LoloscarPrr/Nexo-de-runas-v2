extends Button

const SketchAtlasScript = preload("res://scripts/ui/mockup_hud/sketch_atlas.gd")

var sketch_key := ""
var pulse_active := false
var time := 0.0
var press_strength := 0.0
var _art: TextureRect

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
	_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not sketch_key.is_empty():
		_art.texture = SketchAtlasScript.texture_for(sketch_key)
	add_child(_art)
	pivot_offset = size * 0.5
	resized.connect(_sync_pivot)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	set_process(true)

func _sync_pivot() -> void:
	pivot_offset = size * 0.5

func _process(delta: float) -> void:
	time += delta
	press_strength = move_toward(press_strength, 0.0, delta * 8.0)
	var pulse := 1.0
	if pulse_active and not disabled:
		pulse += sin(time * TAU / 1.25) * 0.018
	scale = Vector2.ONE * pulse * (1.0 - press_strength * 0.035)
	modulate = Color(0.46, 0.48, 0.35, 0.58) if disabled else Color.WHITE

func _on_down() -> void:
	press_strength = 1.0

func _on_up() -> void:
	press_strength = 0.45
