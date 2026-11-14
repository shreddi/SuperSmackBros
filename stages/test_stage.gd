extends Node2D

@export var p1: PackedScene
@export var p2: PackedScene
@onready var p1card = $CanvasLayer/Control/HBoxContainer/P1Card
@onready var p2card = $CanvasLayer/Control/HBoxContainer/P2Card
var p1instance
var p2instance 

# Enum for Fighters
enum Fighters {
	FUX,
	MARTYO
}

func _ready():

	# Load the correct character for Player 1
	p1 = load('res://characters/fux/fux.tscn')
	match Globals.player1:
		Fighters.FUX:
			p1 = load('res://characters/fux/fux.tscn')
			p1card.set_portrait(preload("res://characters/fux/charselect.png"))
		Fighters.MARTYO:
			p1 = load('res://characters/martyo/martyo.tscn')
			p1card.set_portrait(preload("res://characters/martyo/sprites/portrait.png"))
	
	# Load the correct character for Player 2
	p2 = load('res://characters/martyo/martyo.tscn')	
	match Globals.player2:
		Fighters.FUX:
			p2 = load('res://characters/fux/fux.tscn')
			p2card.set_portrait(preload("res://characters/fux/charselect.png"))
		Fighters.MARTYO:
			p2 = load('res://characters/martyo/martyo.tscn')
			p2card.set_portrait(preload("res://characters/martyo/sprites/portrait.png"))

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
