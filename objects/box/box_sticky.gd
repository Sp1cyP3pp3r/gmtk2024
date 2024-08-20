extends Box

@onready var shape_cast: ShapeCast3D = $ShapeCast3D
@export var force_power : float = 600

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	shape_cast.shape.size = collision_shape.size + Vector3(0.5, 0.5, 0.5)
	$MeshInstance3D2.mesh.size = $MeshInstance3D.mesh.size + Vector3(0.001, 0.001, 0.001)
	
	if shape_cast.is_colliding():
		var normal = shape_cast.get_collision_normal(0)
		
		var dot = normal.dot(Vector3.UP)
		var direction = -normal + (Vector3.UP * 1 * (1 - dot))
		direction.normalized()
		
		var force = direction * (force_power * (size.length() / 4 + 0.25) )
		apply_force(force)
