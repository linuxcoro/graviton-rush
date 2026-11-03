extends Node2D
## Jugador: corre pegado a una superficie y un toque invierte la gravedad.

const FLIP_TIME := 0.36
const FLIP_COOLDOWN := 0.10
const RADIUS := 34.0

var screen_x := 0.0
var floor_y := 1100.0
var ceil_y := 180.0
var y := 0.0
var vy := 0.0
var gravity := 15000.0
var gravity_dir := 1.0
var cooldown := 0.0
var surface := 1
var configured := false
var color := Color(0.13, 0.83, 0.93)
var spin := 0.0
var spin_target := 0.0
var squash := 1.0
var trail: Array = []


func configure(px: float, f_y: float, c_y: float) -> void:
	screen_x = px
	floor_y = f_y
	ceil_y = c_y
	var d: float = maxf(80.0, (floor_y - RADIUS) - (ceil_y + RADIUS))
	gravity = 2.0 * d / (FLIP_TIME * FLIP_TIME)
	if not configured:
		configured = true
		reset()
	else:
		y = clampf(y, ceil_y + RADIUS, floor_y - RADIUS)
		position = Vector2(screen_x, y)


func reset() -> void:
	y = floor_y - RADIUS
	vy = 0.0
	gravity_dir = 1.0
	cooldown = 0.0
	surface = 1
	color = Color(0.13, 0.83, 0.93)
	spin = 0.0
	spin_target = 0.0
	squash = 1.0
	trail.clear()
	position = Vector2(screen_x, y)
	queue_redraw()


func flip() -> bool:
	if cooldown > 0.0:
		return false
	gravity_dir = -gravity_dir
	cooldown = FLIP_COOLDOWN
	spin_target += PI
	if gravity_dir < 0.0:
		color = Color(0.96, 0.45, 0.71)
	else:
		color = Color(0.13, 0.83, 0.93)
	return true


func step(delta: float) -> void:
	if not configured:
		return
	cooldown = maxf(0.0, cooldown - delta)
	vy += gravity_dir * gravity * delta
	y += vy * delta
	var top: float = ceil_y + RADIUS
	var bottom: float = floor_y - RADIUS
	if y >= bottom:
		if vy > 320.0:
			squash = 1.4
		y = bottom
		vy = 0.0
		surface = 1
	elif y <= top:
		if vy < -320.0:
			squash = 1.4
		y = top
		vy = 0.0
		surface = -1
	squash = lerpf(squash, 1.0, clampf(delta * 9.0, 0.0, 1.0))
	spin = lerp_angle(spin, spin_target, clampf(delta * 11.0, 0.0, 1.0))
	position = Vector2(screen_x, y)
	trail.push_front(Vector2(screen_x, y))
	if trail.size() > 10:
		trail.resize(10)
	queue_redraw()


func _draw() -> void:
	if not configured:
		return
	var n: int = trail.size()
	for i in n:
		var p: Vector2 = trail[i] - position
		var k: float = float(n - i) / float(n)
		draw_circle(p, RADIUS * 0.85 * k, Color(color.r, color.g, color.b, 0.14 * k))
	draw_circle(Vector2.ZERO, RADIUS * 1.95, Color(color.r, color.g, color.b, 0.10))
	draw_circle(Vector2.ZERO, RADIUS * 1.4, Color(color.r, color.g, color.b, 0.16))
	var sx: float = 1.0 / maxf(squash, 0.55)
	draw_set_transform(Vector2.ZERO, spin, Vector2(sx, squash))
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_circle(Vector2.ZERO, RADIUS * 0.62, Color(0.97, 0.99, 1.0, 0.95))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_arc(Vector2.ZERO, RADIUS + 5.0, 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.5), 3.0)
