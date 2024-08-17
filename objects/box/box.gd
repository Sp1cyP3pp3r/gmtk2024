extends RigidBody3D
class_name Box

@export var size : float = 1

@export_flags_3d_physics var coll_grounded : int
@export_flags_3d_physics var coll_fall : int
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D.shape
@onready var mesh: MeshInstance3D = $MeshInstance3D
var initial_mass

func _ready() -> void:
	initial_mass = mass
	anim.play("appear")
	collision_layer = coll_fall

func _physics_process(delta: float) -> void:
	if not sleeping:
		if linear_velocity.length() >= 5:
			collision_layer = coll_fall
		else:
			collision_layer = coll_grounded
			
	else:
		collision_layer = coll_grounded
	
	collision_shape.size = Vector3(1, 1, 1) * size
	mesh.mesh.size = Vector3(1, 1, 1) * size
	mass = initial_mass * size/2 + 0.5
