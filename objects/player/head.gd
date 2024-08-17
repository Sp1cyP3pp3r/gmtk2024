extends Node3D

var mouse_sensitivity = 0.15

@onready var head_free_space_cast = $HeadFreeSpaceCast
@onready var camera = $Camera
@onready var gun: Gun = $Camera/Gun
@onready var cursor_point: Marker3D = %CursorPoint

var do_rotate_owner : bool = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if do_rotate_owner:
			owner.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		else:
			camera.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity

func _physics_process(delta):
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-87), deg_to_rad(87))
	
	var from = gun.global_position + -gun.global_basis.z
	var time = delta * 30
	gun.look_at(lerp(from, cursor_point.global_position, time))


func head_free_space() -> bool:
	head_free_space_cast.force_shapecast_update()
	if not head_free_space_cast.is_colliding():
		return true
	return false
