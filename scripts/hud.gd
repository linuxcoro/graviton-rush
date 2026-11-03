extends CanvasLayer
## HUD creado por código: puntaje, récord y pantallas de inicio/muerte/pausa.

var w := 720.0
var h := 1280.0
var root: Control
var dim: ColorRect
var score_label: Label
var best_label: Label
var title_label: Label
var subtitle_label: Label
var prompt_label: Label
var last_score := -1
var last_best := -1


func _ready() -> void:
	layer = 10
	root = Control.new()
	root.name = "HudRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	dim = ColorRect.new()
	dim.color = Color(0.01, 0.02, 0.05, 0.64)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dim)

	score_label = _make_label(42, Color(0.30, 0.90, 0.98), HORIZONTAL_ALIGNMENT_LEFT)
	best_label = _make_label(28, Color(0.55, 0.62, 0.75), HORIZONTAL_ALIGNMENT_RIGHT)
	title_label = _make_label(76, Color(0.30, 0.90, 0.98), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle_label = _make_label(26, Color(0.85, 0.90, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label = _make_label(30, Color(1.0, 0.72, 0.16), HORIZONTAL_ALIGNMENT_CENTER)

	title_label.add_theme_constant_override("outline_size", 14)
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.9))
	title_label.add_theme_color_override("font_shadow_color", Color(0.13, 0.83, 0.93, 0.35))


func _make_label(font_size: int, c: Color, align: int) -> Label:
	var l := Label.new()
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", c)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	l.visible = false
	root.add_child(l)
	return l


func resize(size: Vector2) -> void:
	w = size.x
	h = size.y
	dim.position = Vector2.ZERO
	dim.size = size
	score_label.position = Vector2(30.0, 20.0)
	score_label.size = Vector2(w - 60.0, 64.0)
	best_label.position = Vector2(30.0, 20.0)
	best_label.size = Vector2(w - 60.0, 44.0)
	title_label.position = Vector2(0.0, h * 0.25)
	title_label.size = Vector2(w, 110.0)
	subtitle_label.position = Vector2(48.0, h * 0.25 + 118.0)
	subtitle_label.size = Vector2(w - 96.0, 120.0)
	prompt_label.position = Vector2(0.0, h * 0.70)
	prompt_label.size = Vector2(w, 56.0)


func set_score(value: int) -> void:
	if value == last_score:
		return
	last_score = value
	score_label.text = "%d m" % value


func set_best(value: int) -> void:
	if value == last_best:
		return
	last_best = value
	best_label.text = "RÉCORD %d m" % value


func show_ready(best_value: int) -> void:
	dim.visible = true
	score_label.visible = false
	best_label.visible = false
	title_label.visible = true
	title_label.text = "GRAVITON RUSH"
	subtitle_label.visible = true
	subtitle_label.text = "Un toque invierte la gravedad.\nEsquiva picos, bloques y láseres.\nRÉCORD  %d m" % best_value
	prompt_label.visible = true
	prompt_label.text = "TOCA PARA CORRER"


func show_playing() -> void:
	dim.visible = false
	score_label.visible = true
	best_label.visible = true
	title_label.visible = false
	subtitle_label.visible = false
	prompt_label.visible = false


func show_dead(score_value: int, best_value: int) -> void:
	dim.visible = true
	score_label.visible = false
	best_label.visible = false
	title_label.visible = true
	title_label.text = "¡CHOQUE!"
	subtitle_label.visible = true
	subtitle_label.text = "%d m recorridos\nRÉCORD  %d m" % [score_value, best_value]
	prompt_label.visible = true
	prompt_label.text = "TOCA PARA REINTENTAR"


func show_paused(paused: bool) -> void:
	prompt_label.visible = paused
	if paused:
		prompt_label.text = "PAUSA · TOCA PARA SEGUIR"
