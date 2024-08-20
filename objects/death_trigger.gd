extends Area3D
class_name DeathTrigger

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	collision_mask = pow(2, 2-1) + pow(2, 3-1) + pow(2, 4-1)
	collision_layer = 0

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.death()
	if body is Bullet or body is Box:
		body.queue_free()
