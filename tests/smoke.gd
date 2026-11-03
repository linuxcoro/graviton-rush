extends SceneTree
## Smoke test headless de la lógica del juego (sin render).
## Se ejecuta en CI como paso informativo:  godot --headless --path . --script res://tests/smoke.gd

var game = null
var fails := 0


func _initialize() -> void:
	_run()


func _check(condition: bool, label: String) -> void:
	if condition:
		print("  ok   - ", label)
	else:
		fails += 1
		print("  FAIL - ", label)


func _run() -> void:
	print("GRAVITON RUSH · smoke test")
	await process_frame
	var packed = load("res://scenes/Main.tscn")
	_check(packed != null, "carga Main.tscn")
	if packed == null:
		_finish()
		return
	game = packed.instantiate()
	root.add_child(game)
	await process_frame
	_check(game != null and game.player != null and game.hud != null, "nodos del juego creados")
	_check(game.state == 0, "arranca en READY")

	game._tap()
	_check(game.state == 1, "el toque inicia la partida")
	var dir0: float = game.player.gravity_dir
	game._tap()
	_check(game.player.gravity_dir == -dir0, "el toque invierte la gravedad")

	for i in 90:
		game._process(1.0 / 60.0)
	_check(game.travel > 100.0, "el mundo avanza")
	_check(game.spawner.obstacles.size() > 0, "hay obstáculos generados")

	game._die()
	_check(game.state == 2, "el choque termina la partida")
	_check(game.best >= 0, "récord disponible")
	game.dead_timer = 1.0
	game._tap()
	_check(game.state == 1, "el toque reinicia la partida")
	_check(game.player.gravity_dir == 1.0, "la gravedad se resetea al reintentar")
	_finish()


func _finish() -> void:
	if fails == 0:
		print("SMOKE OK")
		quit(0)
	else:
		print("SMOKE FAIL (", fails, " fallas)")
		quit(1)
