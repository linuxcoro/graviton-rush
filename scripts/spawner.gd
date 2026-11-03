extends Node2D
## Genera módulos de obstáculos por delante del jugador y libera los que salen.

const ObstacleScript := preload("res://scripts/obstacle.gd")

var w := 720.0
var h := 1280.0
var floor_y := 1100.0
var ceil_y := 180.0
var rng := RandomNumberGenerator.new()
var obstacles: Array = []
var last_x := 0.0
var last_kind := ""


func configure(size: Vector2, f_y: float, c_y: float) -> void:
	w = maxf(120.0, size.x)
	h = maxf(160.0, size.y)
	floor_y = f_y
	ceil_y = c_y
	rng.randomize()


func reset() -> void:
	clear()
	last_x = w * 1.9
	last_kind = ""


func clear() -> void:
	for o in obstacles:
		if is_instance_valid(o):
			o.queue_free()
	obstacles.clear()


func step(delta: float, travel: float, player_x: float, speed: float) -> void:
	position = Vector2(-travel, 0.0)
	var player_wx: float = travel + player_x
	var guard := 0
	while last_x < player_wx + w * 1.7 and guard < 8:
		_spawn_next(travel, speed)
		guard += 1
	for i in range(obstacles.size() - 1, -1, -1):
		var o = obstacles[i]
		if not is_instance_valid(o):
			obstacles.remove_at(i)
			continue
		o.step(delta)
		if o.position.x + o.width < travel - w * 0.75:
			o.queue_free()
			obstacles.remove_at(i)


func _spawn_next(travel: float, speed: float) -> void:
	var kind: String = _pick_kind(travel)
	var width: float = 280.0
	match kind:
		"spikes_floor", "spikes_ceiling":
			width = rng.randf_range(250.0, 430.0)
		"block_floor", "block_ceiling":
			width = 170.0
		"laser_mid":
			width = 140.0
		"pillars":
			width = clampf(speed * 0.62, 260.0, 420.0) * 2.0
	var gap: float = maxf(340.0, speed * 0.62)
	var x: float = last_x + gap
	var ob = ObstacleScript.new()
	ob.setup(kind, width, floor_y, ceil_y)
	ob.position = Vector2(x, 0.0)
	add_child(ob)
	obstacles.append(ob)
	last_x = x + width
	last_kind = kind


func _pick_kind(travel: float) -> String:
	var meters: float = travel / 100.0
	var pool: Array = [
		"spikes_floor", "spikes_floor",
		"spikes_ceiling", "spikes_ceiling",
		"block_floor", "block_ceiling",
	]
	if meters > 60.0:
		pool.append("laser_mid")
	if meters > 140.0:
		pool.append("pillars")
	if meters > 280.0:
		pool.append("block_floor")
		pool.append("block_ceiling")
	var pick: String = pool[rng.randi_range(0, pool.size() - 1)]
	if pick == last_kind and pool.size() > 1:
		pick = pool[rng.randi_range(0, pool.size() - 1)]
	return pick
