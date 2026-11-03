extends Node2D
## Módulo de obstáculos: se dibuja por código y expone sus rects letales.

var kind := "spikes_floor"
var width := 260.0
var floor_y := 1100.0
var ceil_y := 180.0
var rects: Array = []
var pulse_time := 0.0
var active := true
var ready_done := false

const AMBER := Color(1.0, 0.72, 0.16)
const LASER := Color(1.0, 0.35, 0.55)

func setup(p_kind: String, p_width: float, f_y: float, c_y: float) -> void:
	kind = p_kind
	width = p_width
	floor_y = f_y
	ceil_y = c_y
	rects.clear()
	var mid: float = (floor_y + ceil_y) * 0.5
	match kind:
		"spikes_floor":
			rects.append(Rect2(0.0, floor_y - 70.0, width, 70.0))
		"spikes_ceiling":
			rects.append(Rect2(0.0, ceil_y, width, 70.0))
		"block_floor":
			rects.append(Rect2(0.0, floor_y - 175.0, width, 175.0))
		"block_ceiling":
			rects.append(Rect2(0.0, ceil_y, width, 175.0))
		"laser_mid":
			rects.append(Rect2(0.0, mid - 92.0, width, 184.0))
		"pillars":
			var half: float = width * 0.5
			rects.append(Rect2(0.0, floor_y - 235.0, half, 235.0))
			rects.append(Rect2(half, ceil_y, half, 235.0))
	ready_done = true
	queue_redraw()


func lethal_rects() -> Array:
	if kind == "laser_mid" and not active:
		return []
	return rects


func step(delta: float) -> void:
	if kind != "laser_mid":
		return
	pulse_time += delta
	var cycle: float = fmod(pulse_time, 2.0)
	active = cycle > 0.62 and cycle < 1.52
	queue_redraw()


func _draw() -> void:
	if not ready_done:
		return
	match kind:
		"spikes_floor":
			_draw_spikes(floor_y, -1.0)
		"spikes_ceiling":
			_draw_spikes(ceil_y, 1.0)
		"block_floor":
			_draw_solid(Rect2(0.0, floor_y - 175.0, width, 175.0))
		"block_ceiling":
			_draw_solid(Rect2(0.0, ceil_y, width, 175.0))
		"laser_mid":
			_draw_laser()
		"pillars":
			var half: float = width * 0.5
			_draw_solid(Rect2(0.0, floor_y - 235.0, half, 235.0))
			_draw_solid(Rect2(half, ceil_y, half, 235.0))


func _draw_spikes(base_y: float, dir: float) -> void:
	var hgt := 70.0
	var spacing := 42.0
	var count: int = int(maxf(1.0, width / spacing))
	var glow_y: float = base_y - hgt if dir < 0.0 else base_y
	draw_rect(Rect2(0.0, glow_y, width, hgt), Color(AMBER.r, AMBER.g, AMBER.b, 0.05))
	for i in count:
		var x: float = float(i) * spacing
		var pts := PackedVector2Array([
			Vector2(x, base_y),
			Vector2(x + spacing * 0.5, base_y + dir * hgt),
			Vector2(x + spacing, base_y),
		])
		draw_colored_polygon(pts, Color(AMBER.r, AMBER.g, AMBER.b, 0.92))
		var outline := PackedVector2Array([pts[0], pts[1], pts[2], pts[0]])
		draw_polyline(outline, Color(1.0, 1.0, 1.0, 0.35), 2.0)


func _draw_solid(r: Rect2) -> void:
	draw_rect(Rect2(r.position.x - 7.0, r.position.y - 7.0, r.size.x + 14.0, r.size.y + 14.0), Color(AMBER.r, AMBER.g, AMBER.b, 0.08))
	draw_rect(r, Color(0.05, 0.07, 0.14))
	draw_rect(r, AMBER, false, 3.0)
	var x: float = r.position.x + 8.0
	while x < r.position.x + r.size.x - 12.0:
		draw_rect(Rect2(x, r.position.y + 10.0, 8.0, r.size.y - 20.0), Color(AMBER.r, AMBER.g, AMBER.b, 0.16))
		x += 26.0
	draw_line(Vector2(r.position.x, r.position.y + r.size.y), Vector2(r.position.x + r.size.x, r.position.y + r.size.y), Color(1.0, 1.0, 1.0, 0.35), 2.0)


func _draw_laser() -> void:
	var mid: float = (floor_y + ceil_y) * 0.5
	var a: float = 0.9 if active else 0.16
	draw_rect(Rect2(0.0, mid - 92.0, width, 184.0), Color(LASER.r, LASER.g, LASER.b, 0.08 * a))
	draw_line(Vector2(0.0, mid - 92.0), Vector2(width, mid - 92.0), Color(LASER.r, LASER.g, LASER.b, a), 4.0)
	draw_line(Vector2(0.0, mid + 92.0), Vector2(width, mid + 92.0), Color(LASER.r, LASER.g, LASER.b, a), 4.0)
	for i in 5:
		var x: float = width * (0.1 + 0.2 * float(i))
		draw_line(Vector2(x, mid - 92.0), Vector2(x, mid + 92.0), Color(1.0, 1.0, 1.0, 0.30 * a), 2.0)
