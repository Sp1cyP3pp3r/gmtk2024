extends Area3D

@export var power : float = 20
var active_bodies : Array[RigidBody3D] = []

func _physics_process(delta: float) -> void:
	if not active_bodies.is_empty():
		var force = (-global_basis.z * power)
		for body in active_bodies:
			force *= body.mass / 3
			body.apply_force(force)

func add_body(body : RigidBody3D):
	if not body in active_bodies:
		active_bodies.append(body)
		body.linear_velocity = body.linear_velocity / 2

func remove_body(body : RigidBody3D):
	if body in active_bodies:
		active_bodies.erase(body)
