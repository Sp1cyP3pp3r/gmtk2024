extends Control



func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://maps/test_main_map.tscn"))


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
