extends RigidBody3D
class_name Bullet

@export var box_scene : PackedScene

@export var max_bounces : int = 0
var bounce_counter : int = 0
var normal : Vector3
var force_speed : float

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	normal = state.get_contact_local_normal(0)


func _on_body_entered(body: Node) -> void:
	bounce_counter += 1
	if bounce_counter >= max_bounces + 1:
		create_box()
		queue_free()
		return

func create_box():
	var the_box = box_scene.instantiate() as Box
	get_tree().root.add_child(the_box)
	var dot = abs(normal.dot(Vector3.UP))
	var direction = normal + (Vector3.UP * 0.3 * (1 - dot))
	direction.normalized()
	var force = direction * force_speed
	the_box.global_position = global_position
	the_box.global_position += normal * (the_box.collision_shape.size.length()) / 10
	the_box.look_at(the_box.global_position + normal * 2)
	the_box.apply_force(force)
