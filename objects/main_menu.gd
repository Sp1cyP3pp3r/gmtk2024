extends Control

signal notify_director
signal create_server
signal create_client

func _ready() -> void:
	notify_director.connect(Director.get_playerspawners, 1)
	create_server.connect(Director.create_server)
	create_client.connect(Director.create_client)


func change_scene(scene = preload("res://maps/test_main_map.tscn")) -> void:
	get_tree().change_scene_to_packed(scene)
	notify_director.emit()


func _on_start_pressed() -> void:
	multiplayer.multiplayer_peer = null
	change_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_host_pressed() -> void:
	create_server.emit()
	multiplayer.peer_connected.connect(Director.add_player, 1)
	Director.add_player(1)
	change_scene()
	


func _on_join_pressed() -> void:
	create_client.emit()
	change_scene()
