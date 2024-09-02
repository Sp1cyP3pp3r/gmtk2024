extends RigidBody3D
class_name Bullet

@export var box_type : BoxType.Type

@export var max_bounces : int = 0
var bounce_counter : int = 0
var normal : Vector3
var force_speed : float

#signal create_box(box_tscn, _normal, _force, _position)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() >= 1:
		normal = state.get_contact_local_normal(0)

#func _ready() -> void:
	#create_box.connect(Director.add_box)

func _on_body_entered(body: Node) -> void:
	bounce_counter += 1
	if bounce_counter >= max_bounces + 1:
		_create_box()
		queue_free()
		return

func _create_box():
	Director.add_box.rpc(box_type, normal, force_speed, global_position)
