extends Node2D

@export var p1: PackedScene
@export var p2: PackedScene
@onready var p1portrait = $CanvasLayer/Control/HBoxContainer/P1Card/HBoxContainer/Portrait
@onready var p2portrait = $CanvasLayer/Control/HBoxContainer/P2Card/HBoxContainer/Portrait
var p1instance
var p2instance 

# Enum for Fighters
enum Fighters {
	FOX,
	MARIO
}

func _ready():
	print("stage")

	# Load the correct character for Player 1
	p1 = load('res://Characters/Fox/Fox.tscn')
	match Globals.player1:
		Fighters.FOX:
			p1 = load('res://Characters/Fox/Fox.tscn')
			p1portrait.texture = preload("res://Characters/Fox/charselect.png")
		Fighters.MARIO:
			p1 = load('res://Characters/Mario/Mario.tscn')
			p1portrait.texture = preload("res://Characters/Mario/Sprites/portrait.png")
	
	# Load the correct character for Player 2
	p2 = load('res://Characters/Mario/Mario.tscn')	
	match Globals.player2:
		Fighters.FOX:
			p2 = load('res://Characters/Fox/Fox.tscn')
			p2portrait.texture = preload("res://Characters/Fox/charselect.png")
		Fighters.MARIO:
			p2 = load('res://Characters/Mario/Mario.tscn')
			p2portrait.texture = preload("res://Characters/Mario/Sprites/portrait.png")

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
	$CanvasLayer/Control/HBoxContainer/P1Card/HBoxContainer/VBoxContainer/Stocks.text = str(p1instance.stocks)
	$CanvasLayer/Control/HBoxContainer/P2Card/HBoxContainer/VBoxContainer/Stocks.text = str(p2instance.stocks)
	$CanvasLayer/Control/HBoxContainer/P1Card/HBoxContainer/VBoxContainer/Percent.text = str(round(p1instance.percentage)) + "%"
	$CanvasLayer/Control/HBoxContainer/P2Card/HBoxContainer/VBoxContainer/Percent.text = str(round(p2instance.percentage)) + "%"
	
	if p1instance.stocks < 1 or p2instance.stocks < 1:
		get_tree().change_scene_to_file('res://UI/character_select/character_select.tscn')
