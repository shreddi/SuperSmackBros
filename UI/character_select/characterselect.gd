extends Control

signal character_selected(player, character_index)
signal selection_confirmed(player, character_index)

var player1_selection = 1
var player2_selection = 1
var characters = {"fox": "res://Characters/Fox/Fox.tscn", "mario": "res://Characters/Mario/Mario.tscn"} # Character to path mapping
@onready var gridContainer = $HBoxContainer/VBoxContainer/GridContainer
@onready var p1 = $HBoxContainer/VBoxContainer/Player1Indicator
@onready var p2 = $HBoxContainer/VBoxContainer/Player2Indicator
@onready var anim = $AnimatedSprite2D

func _ready():
	#anim.position = Vector2(1920/2+200,1080/2)
	#anim.scale.y = 6
	#anim.scale.x = 10
	anim.play("default",1.0,false)
	characters = gridContainer.get_children()
	print(characters)
	p1.global_position.x = characters[0].global_position.x + characters[0].custom_minimum_size.x/10
	p1.global_position.y = characters[0].global_position.y
	p2.global_position.x = characters[0].global_position.x + characters[0].custom_minimum_size.x/3
	p2.global_position.y = characters[0].global_position.y
	print(characters[0].global_position.x + characters[0].custom_minimum_size.x/10)
	print(characters[0].global_position.y)
	print(p1.global_position)
	# Initialize selections
	update_selection(1, 1)
	update_selection(2, 1)

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
		p1.global_position.x = characters[selection_index].global_position.x + characters[selection_index].custom_minimum_size.x/10
		p1.global_position.y = characters[selection_index].global_position.y
		Globals.player1 = selection_index
	elif player == 2:
		p2.global_position.x = characters[selection_index].global_position.x + characters[selection_index].custom_minimum_size.x/3
		p2.global_position.y = characters[selection_index].global_position.y
		Globals.player2 = selection_index
