extends Node2D

@export var p1: PackedScene
@export var p2: PackedScene
@onready var p1card = $CanvasLayer/Control/HBoxContainer/P1Card
@onready var p2card = $CanvasLayer/Control/HBoxContainer/P2Card
var p1instance
var p2instance 

const Roster = preload("res://characters/roster.gd")

func _ready():

	# Load the chosen fighters (Globals holds roster indices from the select screen)
	var p1_entry := Roster.entry(Globals.player1, 0)
	var p2_entry := Roster.entry(Globals.player2, 1)
	p1 = load(p1_entry.scene)
	p1card.set_portrait(load(p1_entry.portrait))
	p2 = load(p2_entry.scene)
	p2card.set_portrait(load(p2_entry.portrait))

	# Instantiate and add Player 1 character to the scene
	p1instance = p1.instantiate()
	add_child(p1instance)
	p1instance.position = Vector2(-384, -100)  # Set position for Player 1

	# Instantiate and add Player 2 character to the scene
	p2instance = p2.instantiate()
	add_child(p2instance)  # This should be p2instance, not p1instance
	p2instance.position = Vector2(384, -100)  # Set position for Player 2

	# Optional: set a unique ID to distinguish players if needed
	p1instance.id = 1
	p2instance.id = 2
	p1instance.stocks = 5
	p2instance.stocks = 5
	
	# After adding p1instance and p2instance to the scene
	p1instance.add_to_group("player1")
	p2instance.add_to_group("player2")


func _process(delta):
	p1card.set_stocks(p1instance.stocks)
	p2card.set_stocks(p2instance.stocks)
	p1card.set_percent(int(round(p1instance.percentage)))
	p2card.set_percent(int(round(p2instance.percentage)))

	if p1instance.stocks < 1 or p2instance.stocks < 1:
		get_tree().change_scene_to_file('res://ui/character_select/character_select.tscn')
