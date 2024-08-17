extends RigidBody3D
class_name Bullet

var bounce_counter : int = 0

func _on_body_entered(body: Node) -> void:
	bounce_counter += 1
	if bounce_counter >= 2:
		queue_free()
		return
