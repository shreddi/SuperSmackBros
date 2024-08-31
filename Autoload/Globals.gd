extends Node

var hit:bool = false

var player1
var player2
@export var p1: PackedScene
@export var p2: PackedScene

func hitstun(mod,duration):
		Engine.time_scale = mod/100
		print(str(mod))
		await get_tree().create_timer(duration*Engine.time_scale).timeout
		Engine.time_scale = 1
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
