extends Node
class_name MultiplayerDirector

const PORT : int = 5357
var peer = ENetMultiplayerPeer.new()
var position = Vector3(22, 7, 9)
var playerspawners_array : Array[PlayerSpawner] = []

# Custom Spawn
# Configuration Dictionary
# "You can write code for the host to spawn nodes this way,\
# then provide an RPC for a client to send a configuration if they are not the server."
#
#
#
#


func get_playerspawners():
	#var timer = Timer.new()
	#timer.start(1)
	#await timer.timeout 
	#timer.queue_free()
	
	#playerspawners_array = get_tree().get_nodes_in_group("PlayerSpawners") as Array[PlayerSpawner]
	pass

func create_server() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.server_relay = true
	add_player(1)
	
	multiplayer.peer_connected.connect(add_player, 1)
	

func create_client() -> void:
	peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = peer
	

func add_player(player_id : int) -> void:
	var player_scene = preload("res://objects/player/player.tscn")
	var player = player_scene.instantiate()
	player.global_position = position
	player.name = str(player_id)
	add_child(player)
	
	#if player_id != 1:
		#add_spawner(player_id)\

@rpc("any_peer", "call_local", "reliable")
func add_box(box_type, normal, force_speed, global_position) -> void:
	if not multiplayer.is_server():
		return
	var the_box = BoxType.get_type(box_type).instantiate()
	#if box_scene is not EncodedObjectAsID:
		#the_box = box_scene.instantiate() as Box
	#else:
		#the_box = preload("res://objects/box/box.tscn").instantiate() as Box
	the_box.name = str(randi())
	add_child(the_box, 1)
	var dot = abs(normal.dot(Vector3.UP))
	var direction = normal + (Vector3.UP * 0.3 * (1 - dot))
	direction.normalized()
	var force = direction * force_speed * abs( 1 - (the_box.mass / 10 + 0.1) )
	the_box.global_position = global_position
	the_box.global_position += normal * (the_box.size.length()) / 10
	the_box.look_at(the_box.global_position + normal * 2)
	the_box.apply_impulse(force)

@export var spawn_list : Array[PackedScene]

func add_spawner(id : int) -> void:
	var spawner = MultiplayerSpawner.new()
	spawner.spawn_path = get_path()
	for scene in spawn_list:
		var path : String = scene.resource_path
		spawner.add_spawnable_scene(path)
	add_child(spawner, true)
	_handoff(spawner.get_path(), id)

@rpc("call_local")
func _handoff(node_name, auth_id):
	get_node(node_name).set_multiplayer_authority(auth_id) 
