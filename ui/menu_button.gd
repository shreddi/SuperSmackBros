extends Button
## Shared script for menu buttons: highlights on focus/hover and either
## changes scene to `path` or quits the game when pressed.

@export_file("*.tscn") var path := ""
@export var quit_game := false

func _on_SinglePlayerButton_focus_entered():
	add_theme_color_override("font_outline_color", Color(1, 0.3254, 0))

func _on_SinglePlayerButton_focus_exited():
	add_theme_color_override("font_outline_color", Color(0, 0, 0))

func _on_pressed():
	if quit_game:
		get_tree().quit()
	elif path != "":
		get_tree().change_scene_to_file(path)

func _on_area_2d_area_entered(_area):
	focus_entered.emit()

func _on_area_2d_area_exited(_area):
	focus_exited.emit()
