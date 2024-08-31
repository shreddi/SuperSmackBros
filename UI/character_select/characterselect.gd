extends Control

signal character_selected(player, character_index)
signal selection_confirmed(player, character_index)

var player1_selection = 1
var player2_selection = 1
var characters = {"fox": "res://Characters/Fox/Fox.tscn", "mario": "res://Characters/Mario/Mario.tscn"} # Character to path mapping
@onready var gridContainer = $ColorRect/VBoxContainer/GridContainer
@onready var p1 = $ColorRect/Player1Indicator
@onready var p2 = $ColorRect/Player2Indicator

func _ready():
	characters = gridContainer.get_children()
	print(characters)

	# Initialize selections
	update_selection(1, 0)
	update_selection(2, 0)

func _input(event):
	if Input.is_action_just_pressed("left_1"):
		player1_selection = max(0, player1_selection - 1)
		update_selection(1, player1_selection)
	elif Input.is_action_just_pressed("right_1"):
		player1_selection = min(player1_selection + 1, characters.size() - 1)
		update_selection(1, player1_selection)
	elif Input.is_action_just_pressed("attack_1"):
		emit_signal("selection_confirmed", 1, player1_selection)

	if Input.is_action_just_pressed("left_2"):
		player2_selection = max(0, player2_selection - 1)
		update_selection(2, player2_selection)
	elif Input.is_action_just_pressed("right_2"):
		player2_selection = min(player2_selection + 1, characters.size() - 1)
		update_selection(2, player2_selection)
	elif Input.is_action_just_pressed("attack_2"):
		emit_signal("selection_confirmed", 2, player2_selection)

func update_selection(player, selection_index):
	print("bruh")
	if player == 1:
		p1.global_position.x = characters[selection_index].global_position.x 
		p1.global_position.y = characters[selection_index].global_position.y
		Globals.player1 = selection_index
	elif player == 2:
		p2.global_position.x = characters[selection_index].global_position.x + characters[selection_index].custom_minimum_size.x/3
		p2.global_position.y = characters[selection_index].global_position.y
		Globals.player2 = selection_index
