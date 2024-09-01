extends Node
class_name MultiplayerDirector

const PORT : int = 5357
var peer = ENetMultiplayerPeer.new()
var position = Vector3(22, 7, 9)
var playerspawners_array : Array[PlayerSpawner] = []

func get_playerspawners():
	#var timer = Timer.new()
	#timer.start(1)
	#await timer.timeout 
	#timer.queue_free()
	
	#playerspawners_array = get_tree().get_nodes_in_group("PlayerSpawners") as Array[PlayerSpawner]
	pass

func create_server():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_relay = true

func create_client():
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer
	

func add_player(player_id : int):
	#var timer = Timer.new()
	#timer.start(0.0)
	#await timer.timeout 
	#timer.queue_free()
	
	var player_scene = preload("res://objects/player/player.tscn")
	var player = player_scene.instantiate()
	player.global_position = position
	player.name = str(player_id)
	add_child(player)
	
	#var rand = randi_range(0, playerspawners_array.size() - 1)
	#var spawner = playerspawners_array[rand] as PlayerSpawner
	#if spawner.has_method("spawn_player"):
		#spawner.spawn_player(player_id)
	#else:
		#OS.alert("Какой-то из PlayerSpawner'ов пиздит", "ИГРА СЛОМАНА БЛЯТЬ")
	
	
