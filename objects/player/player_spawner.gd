extends Marker3D
class_name PlayerSpawner

@export var player_scn : PackedScene

func spawn_player(id : int = 1):
	var player_inst = player_scn.instantiate()
	player_inst.name = str(id)
	owner.add_child.call_deferred(player_inst)
