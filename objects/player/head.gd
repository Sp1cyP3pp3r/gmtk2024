extends Node3D

var mouse_sensitivity = 0.13

@onready var head_free_space_cast = $HeadFreeSpaceCast
@onready var camera : Camera3D = $Camera
@onready var gun: Gun = $Camera/Gun
@onready var cursor_point: Marker3D = %CursorPoint
@export var fov : float= 75

var do_rotate_owner : bool = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = fov
	initial_sens = mouse_sensitivity
	head_free_space_cast.add_exception(owner)

func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if do_rotate_owner:
				owner.rotation_degrees.y -= event.relative.x * mouse_sensitivity
			else:
				camera.rotation_degrees.y -= event.relative.x * mouse_sensitivity
			camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity

var zoomed : bool = false
var initial_sens
func _physics_process(delta):
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-87), deg_to_rad(87))
	
	var from = gun.global_position + -gun.global_basis.z
	var time = delta * 30
	gun.look_at(lerp(from, cursor_point.global_position, time))
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("zoom_in") and not zoomed:
			zoomed = true
		if Input.is_action_just_pressed("zoom_out"):
			zoomed = false
	
	if zoomed:
		camera.fov = lerp(camera.fov, fov/2.5, delta * 15)
		mouse_sensitivity = initial_sens / 5
	else:
		camera.fov = lerp(camera.fov, fov, delta * 10)
		mouse_sensitivity = initial_sens
		initial_sens = mouse_sensitivity


func head_free_space() -> bool:
	head_free_space_cast.force_shapecast_update()
	if not head_free_space_cast.is_colliding():
		return true
	return false
