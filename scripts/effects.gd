extends Node2D
## Pool de partículas livianas (máx. 180) + sacudida de pantalla.

const MAX_PARTICLES := 180

var particles: Array = []
var shake_time := 0.0
var shake_duration := 0.22
var shake_amount := 0.0
var shake_offset := Vector2.ZERO
var rng := RandomNumberGenerator.new()


func configure(_size: Vector2) -> void:
	rng.randomize()


func reset() -> void:
	particles.clear()
	shake_time = 0.0
	shake_amount = 0.0
	shake_offset = Vector2.ZERO
	queue_redraw()


func shake(amount: float) -> void:
	shake_amount = maxf(shake_amount, amount)
	shake_time = shake_duration


func emit_dust(pos: Vector2, dir: int) -> void:
	_spawn(
		pos + Vector2(rng.randf_range(-14.0, 14.0), 6.0),
		Vector2(rng.randf_range(-210.0, -50.0), rng.randf_range(-40.0, 40.0) * float(dir)),
		Color(0.45, 0.85, 1.0),
		0.40,
		3.2
	)


func emit_burst(pos: Vector2, c: Color, count: int) -> void:
	for i in count:
		var ang: float = rng.randf() * TAU
		var sp: float = rng.randf_range(90.0, 460.0)
		_spawn(pos, Vector2(cos(ang), sin(ang)) * sp, c, rng.randf_range(0.28, 0.80), rng.randf_range(2.5, 6.5))


func _spawn(pos: Vector2, vel: Vector2, c: Color, life: float, size: float) -> void:
	if particles.size() >= MAX_PARTICLES:
		particles.pop_front()
	particles.append({"p": pos, "v": vel, "life": life, "max": life, "c": c, "s": size})
	queue_redraw()


func step(delta: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		var p: Dictionary = particles[i]
		p["life"] -= delta
		if p["life"] <= 0.0:
			particles.remove_at(i)
			continue
		p["v"] += Vector2(0.0, 900.0) * delta
		p["p"] += p["v"] * delta
		p["v"] *= 0.985
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		var k: float = shake_time / shake_duration
		if k > 0.0:
			shake_offset = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)) * shake_amount * k
		else:
			shake_amount = 0.0
			shake_offset = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	for p in particles:
		var k: float = clampf(p["life"] / p["max"], 0.0, 1.0)
		var c: Color = p["c"]
		draw_circle(p["p"], p["s"] * (0.35 + 0.85 * k), Color(c.r, c.g, c.b, 0.9 * k))
