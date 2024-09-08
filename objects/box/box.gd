extends RigidBody3D
class_name Box

@export var audio_array : Array[AudioStream]
@export var size : Vector3 = Vector3.ONE
@export var max_size : float = 5
@export var min_size : float = 0.5

@export_flags_3d_physics var coll_grounded : int
@export_flags_3d_physics var coll_fall : int

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D.shape
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

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
	
	size.x = clamp(size.x, min_size, max_size)
	size.y = clamp(size.y, min_size, max_size)
	size.z = clamp(size.z, min_size, max_size)
	
	collision_shape.size = size
	mesh.mesh.size = size
	mass = initial_mass * size.length()/4 + 0.75
	
	#audio.pitch_scale = 2 - ( (size.length_squared() / 3) / 4 + 0.75 )
	#audio.pitch_scale = clamp(audio.pitch_scale, 0.3, 3)


func _on_body_entered(body: Node) -> void:
	if not audio_array.is_empty():
		var _size = audio_array.size()
		randomize()
		var i = randi_range(0, _size - 1)
		audio.stream = audio_array[i]
		audio.play()
