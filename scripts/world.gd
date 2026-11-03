extends Node2D
## Fondo neón: gradiente, estrellas con parallax, skyline, grid y líneas de piso/techo.

var w := 720.0
var h := 1280.0
var floor_y := 1100.0
var ceil_y := 180.0
var stars: Array = []
var travel := 0.0
var speed := 560.0
var rng := RandomNumberGenerator.new()
var configured := false


func configure(size: Vector2, f_y: float, c_y: float) -> void:
	w = maxf(120.0, size.x)
	h = maxf(160.0, size.y)
	floor_y = f_y
	ceil_y = c_y
	rng.seed = 20261103
	stars.clear()
	for i in 70:
		stars.append(Vector2(rng.randf() * w, rng.randf() * h))
	configured = true
	queue_redraw()


func step(delta: float, t: float, sp: float) -> void:
	travel = t
	speed = sp
	queue_redraw()


func _draw() -> void:
	if not configured:
		return
	var top := Color(0.016, 0.020, 0.050)
	var bottom := Color(0.050, 0.070, 0.170)
	var bands := 26
	var band_h: float = h / float(bands)
	for i in bands:
		var k: float = float(i) / float(bands)
		draw_rect(Rect2(0.0, band_h * float(i), w, band_h + 1.0), top.lerp(bottom, k))
	for s in stars:
		var sx: float = fposmod(s.x - travel * 0.05, w)
		var tw: float = 0.35 + 0.5 * absf(sin(travel * 0.002 + s.y))
		draw_circle(Vector2(sx, s.y), 1.7, Color(0.70, 0.90, 1.0, 0.55 * tw))
	var layer_w := 128.0
	var offset: float = fposmod(travel * 0.18, layer_w)
	var cols: int = int(w / layer_w) + 2
	for j in range(-1, cols):
		var bx: float = float(j) * layer_w - offset
		var bh: float = 70.0 + 120.0 * absf(sin(float(j) * 1.71))
		draw_rect(Rect2(bx, floor_y - 210.0 - bh, layer_w - 20.0, bh + 210.0), Color(0.035, 0.060, 0.140))
		draw_line(Vector2(bx + 10.0, floor_y - 210.0 - bh), Vector2(bx + 10.0, floor_y - 210.0), Color(0.10, 0.55, 0.65, 0.25), 2.0)
	var gx: float = fposmod(travel * 0.55, 64.0)
	for k in 14:
		var x: float = float(k) * 64.0 - gx
		draw_line(Vector2(x, floor_y), Vector2(x - 150.0, h), Color(0.10, 0.55, 0.65, 0.14), 2.0)
	for k in 40:
		var y: float = float(k) * (h / 40.0)
		draw_line(Vector2(0.0, y), Vector2(w, y), Color(1.0, 1.0, 1.0, 0.012), 1.0)
	_draw_neon(floor_y, Color(0.13, 0.83, 0.93), true)
	_draw_neon(ceil_y, Color(0.96, 0.45, 0.71), false)


func _draw_neon(y: float, c: Color, downward: bool) -> void:
	var sgn: float = 1.0 if downward else -1.0
	draw_rect(Rect2(0.0, y + minf(0.0, sgn * 18.0), w, 18.0), Color(c.r, c.g, c.b, 0.05))
	draw_rect(Rect2(0.0, y + minf(0.0, sgn * 6.0), w, 6.0), Color(c.r, c.g, c.b, 0.22))
	draw_line(Vector2(0.0, y), Vector2(w, y), c, 3.0)
