extends Node3D

@export var wall_shapecast : ShapeCast3D
@onready var wall_ray_head = $WallRayHead
@onready var wall_ray_side = $WallRaySide
@onready var up_wall_ray_head = $UpWallRayHead


func is_on_wall() -> bool:
	wall_shapecast.force_shapecast_update()
	if wall_shapecast.is_colliding():
		var _normal = get_wall_normal()
		var _normal_snapped = snapped(_normal.dot(Vector3.UP), 0.001)
		if _normal_snapped <= 0.25 and _normal_snapped >= -0.19:
			return true
		return false
	return false

func get_wall_dot():
	wall_shapecast.force_shapecast_update()
	if wall_shapecast.is_colliding():
		var _normal = wall_shapecast.get_collision_normal(0)
		var _rotation = -owner.global_transform.basis.z
		var _dot = _normal.dot(_rotation)
		return _dot
	return null

func get_wall_normal() -> Vector3:
	wall_shapecast.force_shapecast_update()
	if not wall_shapecast.is_colliding():
		return Vector3.ZERO
	else:
		wall_ray_side.target_position = Vector3(-0.5, 0, 0) * get_wall_sign_direction()
		wall_ray_side.target_position.y = 0
		wall_ray_side.force_raycast_update()
		return wall_ray_side.get_collision_normal()

func get_wall_forward() -> Vector3:
	wall_shapecast.force_shapecast_update()
	if not wall_shapecast.is_colliding():
		return Vector3.ZERO
	else:
		#var _dir = -owner.global_transform.basis.z
		var _normal = get_wall_normal()
		#var _dot = _dir.dot(_normal)
		### определить куда смотрит игрок
		var _cross = Vector3.UP.cross(_normal)
		var sign_direction = get_wall_sign_direction()
		sign_direction = sign_direction/abs(sign_direction)
		return _cross * sign_direction

func get_wall_sign_direction() -> int:
	wall_shapecast.force_shapecast_update()
	if wall_shapecast.is_colliding():
		var _cross = Vector3.UP.cross(wall_shapecast.get_collision_normal(0))
		var sign_direction = _cross.dot(-global_transform.basis.z)
		sign_direction = sign_direction / abs(sign_direction)
		return sign_direction
	return 0

func is_head_colliding() -> bool:
	var _point = Vector3(-0.5, 0, 0) * get_wall_sign_direction()
	wall_ray_head.target_position = _point
	wall_ray_head.target_position.y = 0
	wall_ray_head.force_raycast_update()
	if not wall_ray_head.is_colliding():
		return false
	return true

func is_upper_head_colliding() -> bool:
	var _point = Vector3(-0.5, 0, 0) * get_wall_sign_direction()
	up_wall_ray_head.target_position = _point
	up_wall_ray_head.target_position.y = 0
	up_wall_ray_head.force_raycast_update()
	if not up_wall_ray_head.is_colliding():
		return false
	return true
