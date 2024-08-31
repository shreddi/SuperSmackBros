extends Button


func _on_SinglePlayerButton_focus_entered():
	add_theme_color_override("font_outline_color", Color(1, 0.3254, 0))
	
func _on_SinglePlayerButton_focus_exited():
	add_theme_color_override("font_outline_color", Color(0,0,0))
	
func _on_pressed():
	get_tree().quit()


func _on_area_2d_area_entered(area):
	emit_signal("focus_entered")


func _on_area_2d_area_exited(area):
	emit_signal("focus_exited")
