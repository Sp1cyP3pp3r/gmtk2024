extends RigidBody3D
class_name Box

@export_flags_3d_physics var coll_grounded : int
@export_flags_3d_physics var coll_fall : int
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D.shape

func _ready() -> void:
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
