extends Node
## Deterministic regression harness. Loads the test stage with two fighters,
## feeds both a pseudo-random but seeded input stream, and writes a per-frame
## trace (state, position, velocity, damage...) to a file.
##
## Run with (the fixed FPS keeps physics deterministic):
##   godot --headless --fixed-fps 60 --path . res://tests/trace_runner.tscn \
##       -- --p1=fox --p2=mario --seed=1 --frames=3000 --out=/tmp/trace.txt
##
## Compare traces before and after a refactor; they should be byte-identical.

const ACTIONS := ["right", "left", "up", "down", "shield", "jump", "attack", "special", "strong"]
const FIGHTERS := {"fox": 0, "mario": 1}

var stage
var rng_state: int
var frames := 120
var seed_value := 1
var out_path := "user://trace.txt"
var file: FileAccess
var frame_i := 0
var held := {1: {}, 2: {}}
var visited := {}

func _ready():
	process_physics_priority = -100  # inject input before the fighters tick
	for arg in OS.get_cmdline_user_args():
		var kv = arg.trim_prefix("--").split("=")
		match kv[0]:
			"p1": Globals.player1 = FIGHTERS[kv[1]]
			"p2": Globals.player2 = FIGHTERS[kv[1]]
			"seed": seed_value = int(kv[1])
			"frames": frames = int(kv[1])
			"out": out_path = kv[1]
	rng_state = seed_value * 2654435761 % 4294967296
	stage = load("res://stages/test_stage.tscn").instantiate()
	get_tree().root.add_child.call_deferred(stage)
	file = FileAccess.open(out_path, FileAccess.WRITE)

func _next_rand() -> int:
	rng_state = (rng_state * 1103515245 + 12345) % 2147483648
	return rng_state >> 8

func _physics_process(_delta):
	if stage == null or stage.p1instance == null:
		return
	var players = {1: stage.p1instance, 2: stage.p2instance}
	if frame_i == 0:
		for p in players.values():
			p.stocks = 99
	# New input choice every 6 frames per player.
	if frame_i % 6 == 0:
		for id in players:
			for a in ACTIONS:
				# bias: directions and attacks held more often than shield
				var r = _next_rand() % 100
				var on = r < 35 if a in ["right", "left", "attack"] else r < 18
				held[id][a] = on
			if held[id]["left"] and held[id]["right"]:
				held[id]["left"] = false
	for id in players:
		for a in ACTIONS:
			var name = "%s_%d" % [a, id]
			if held[id][a]:
				Input.action_press(name)
			else:
				Input.action_release(name)
	var line = "%d" % frame_i
	for id in players:
		var p = players[id]
		visited[p.state.text] = true
		line += " | %s %s %.2f,%.2f v%.2f,%.2f %s st%d f%d" % [
			p.state.text, str(p.get_node("State").text), p.position.x, p.position.y,
			p.velocity.x, p.velocity.y, str(p.percentage), p.stocks, p.frame]
	file.store_line(line)
	frame_i += 1
	if frame_i >= frames:
		file.store_line("VISITED " + ",".join(PackedStringArray(visited.keys())))
		file.close()
		print("done: ", out_path, " states=", visited.size())
		get_tree().quit()
