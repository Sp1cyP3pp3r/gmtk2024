extends Node
class_name MultiplayerDirector

var Port : int = 5357
var Adress : String = "localhost"
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
	peer.create_server(Port)
	multiplayer.multiplayer_peer = peer
	#get_tree().multiplayer.allow_object_decoding = true
	multiplayer.server_relay = true
	add_player(1)
	
	multiplayer.peer_connected.connect(add_player, 1)
	

func create_client() -> void:
	peer.create_client(Adress, Port)
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

@rpc("any_peer", "call_local", "reliable")
func change_box_size(box_path, normal, face, direction, offset, scale_power, current_beam) -> void:
	if not multiplayer.is_server():
		return
	
	var box = get_node(box_path)
	#var face : Basis = box.global_basis.orthonormalized()
	#var direction : Vector3 = normal * face # actual face
	var value = abs(direction)
	var final_value = value * scale_power
	#var offset = normal * scale_power / 2
	
	#TODO
	if abs(direction).is_equal_approx(Vector3.RIGHT):
		if box.size.x >= box.max_size:
			offset = Vector3.ZERO
		elif box.size.x <= box.min_size:
			offset = Vector3.ZERO
	elif abs(direction).is_equal_approx(Vector3.BACK):
		if box.size.z >= box.max_size:
			offset = Vector3.ZERO
		elif box.size.z <= box.min_size:
			offset = Vector3.ZERO
	elif abs(direction).is_equal_approx(Vector3.UP):
		if box.size.y >= box.max_size:
			offset = Vector3.ZERO
		elif box.size.y <= box.min_size:
			offset = Vector3.ZERO
			
			
	match current_beam:
		Gun.BEAM_TYPE.Enlarge:
			box.size += final_value
			box.global_position += offset
			
		Gun.BEAM_TYPE.Shrink:
			box.size -= final_value
			box.global_position -= offset

#func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	#var mesh_instance := MeshInstance3D.new()
	#var immediate_mesh := ImmediateMesh.new()
	#var material := ORMMaterial3D.new()
#
	#mesh_instance.mesh = immediate_mesh
	#mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
#
	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	#immediate_mesh.surface_add_vertex(pos1 + Vector3(0, 0.03, -0.04))
	#immediate_mesh.surface_add_vertex(pos1 + Vector3(0.02, -0.06, 0))
	#immediate_mesh.surface_add_vertex(pos2 + Vector3(0, 0.03,  -0.04))
	#immediate_mesh.surface_end()
	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	#immediate_mesh.surface_add_vertex(pos2 + Vector3(0, 0.03,  -0.04))
	#immediate_mesh.surface_add_vertex(pos1 + Vector3(0.02, -0.06, 0))
	#immediate_mesh.surface_add_vertex(pos2 + Vector3(0.02, -0.06, 0))
	#immediate_mesh.surface_end()
#
	#material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#material.albedo_color = color
	#immediate_mesh.surface_set_material(0, material)
	#immediate_mesh.surface_set_material(1, material)
	#
	#
	#return await final_cleanup(mesh_instance, persist_ms)
	
#func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	#get_tree().get_root().add_child(mesh_instance)
	#await get_tree().create_timer(persist_ms).timeout
	#mesh_instance.queue_free()

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
