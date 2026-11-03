extends Node2D
## Orquestador de Graviton Rush: estados, entrada, puntaje y guardado.
## Todo el juego se construye por código; Main.tscn solo aporta este nodo.

const SAVE_PATH := "user://graviton_rush_save.json"
const BASE_SPEED := 560.0
const MAX_SPEED := 1000.0
const SPEED_PER_METER := 0.28
const DEATH_LOCK := 0.55

enum State { READY, PLAYING, DEAD }

var state: int = State.READY
var screen_size := Vector2(720.0, 1280.0)
var pad := 150.0
var floor_y := 1100.0
var ceil_y := 180.0
var player_x := 158.0

var travel := 0.0
var speed := BASE_SPEED
var best := 0
var runs := 0
var dead_timer := 0.0
var app_paused := false
var dust_acc := 0.0

var player = null
var world = null
var spawner = null
var effects = null
var hud = null


func _ready() -> void:
	_load_save()
	world = preload("res://scripts/world.gd").new()
	add_child(world)
	spawner = preload("res://scripts/spawner.gd").new()
	add_child(spawner)
	player = preload("res://scripts/player.gd").new()
	add_child(player)
	effects = preload("res://scripts/effects.gd").new()
	add_child(effects)
	hud = preload("res://scripts/hud.gd").new()
	add_child(hud)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_apply_layout()
	_reset_run()


func _process(delta: float) -> void:
	var t: float = minf(delta, 0.033)
	if app_paused:
		effects.step(t)
		return
	if state == State.PLAYING:
		speed = minf(MAX_SPEED, BASE_SPEED + (travel / 100.0) * SPEED_PER_METER)
		travel += speed * t
		player.step(t)
		spawner.step(t, travel, player_x, speed)
		_check_collisions()
		hud.set_score(_score())
		dust_acc += t
		if dust_acc >= 0.06:
			dust_acc = 0.0
			effects.emit_dust(player.position, -player.surface)
	elif state == State.DEAD:
		dead_timer += t
	effects.step(t)
	world.step(t, travel, speed)
	position = effects.shake_offset


func _unhandled_input(event: InputEvent) -> void:
	var tapped := false
	if event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		tapped = mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventKey:
		var k := event as InputEventKey
		tapped = k.pressed and not k.echo and (k.keycode == KEY_SPACE or k.keycode == KEY_ENTER)
	if tapped:
		_tap()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT or what == MainLoop.NOTIFICATION_APPLICATION_PAUSED:
		if state == State.PLAYING:
			app_paused = true
			hud.show_paused(true)
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN or what == MainLoop.NOTIFICATION_APPLICATION_RESUMED:
		if app_paused:
			app_paused = false
			hud.show_paused(false)


func _tap() -> void:
	if app_paused:
		app_paused = false
		hud.show_paused(false)
		return
	match state:
		State.READY:
			_start_run()
		State.PLAYING:
			if player.flip():
				effects.emit_burst(player.position, player.color, 14)
				effects.shake(2.0)
		State.DEAD:
			if dead_timer >= DEATH_LOCK:
				_start_run()


func _score() -> int:
	return int(travel / 100.0)


func _check_collisions() -> void:
	var wx: float = travel + player_x
	var pr := Rect2(wx - 26.0, player.position.y - 26.0, 52.0, 52.0)
	for o in spawner.obstacles:
		if not is_instance_valid(o):
			continue
		if o.position.x > wx + 220.0:
			continue
		for r in o.lethal_rects():
			var wr := Rect2(o.position.x + r.position.x, r.position.y, r.size.x, r.size.y)
			if wr.intersects(pr):
				_die()
				return


func _die() -> void:
	if state != State.PLAYING:
		return
	state = State.DEAD
	dead_timer = 0.0
	var sc: int = _score()
	runs += 1
	if sc > best:
		best = sc
	_save()
	effects.emit_burst(player.position, Color(1.0, 0.36, 0.42), 46)
	effects.shake(13.0)
	hud.set_best(best)
	hud.show_dead(sc, best)


func _start_run() -> void:
	travel = 0.0
	speed = BASE_SPEED
	dead_timer = 0.0
	app_paused = false
	dust_acc = 0.0
	player.configure(player_x, floor_y, ceil_y)
	player.reset()
	spawner.reset()
	effects.reset()
	state = State.PLAYING
	hud.set_score(0)
	hud.set_best(best)
	hud.show_playing()


func _reset_run() -> void:
	travel = 0.0
	speed = BASE_SPEED
	dead_timer = 0.0
	app_paused = false
	dust_acc = 0.0
	player.configure(player_x, floor_y, ceil_y)
	player.reset()
	spawner.reset()
	effects.reset()
	state = State.READY
	hud.set_score(0)
	hud.set_best(best)
	hud.show_ready(best)


func _apply_layout() -> void:
	var s: Vector2 = get_viewport_rect().size
	if s.x < 120.0 or s.y < 160.0:
		s = Vector2(720.0, 1280.0)
	screen_size = s
	pad = clampf(s.y * 0.12, 90.0, 260.0)
	floor_y = s.y - pad
	ceil_y = pad
	player_x = s.x * 0.22
	if world != null:
		world.configure(s, floor_y, ceil_y)
	if spawner != null:
		spawner.configure(s, floor_y, ceil_y)
	if player != null:
		player.configure(player_x, floor_y, ceil_y)
	if effects != null:
		effects.configure(s)
	if hud != null:
		hud.resize(s)


func _on_viewport_resized() -> void:
	var was_playing: bool = state == State.PLAYING
	_apply_layout()
	if was_playing:
		_start_run()
	elif state == State.READY:
		_reset_run()


func _load_save() -> void:
	best = 0
	runs = 0
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text: String = f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		best = int(data.get("best", 0))
		runs = int(data.get("runs", 0))


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"best": best, "runs": runs}))
	f.close()
