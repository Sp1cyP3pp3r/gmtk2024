extends Node3D

@onready var floor_cast = $FloorCast
@onready var stairs_cast = $StairsCast
@onready var floor_ray = $FloorCast/FloorRay
@onready var stairs_floor_ray_cast = $StairsCast/StairsFloorRayCast
@onready var free_space_ray_cast = $StairsCast/FreeSpaceRayCast
@onready var stairs_beneath = $StairsCast/StairsBeneath
@onready var stairs_near = $StairsCast/StairsNear


@export var stairs_up_margin : float = 0.2


func is_on_stairs() -> bool:
	stairs_cast.force_shapecast_update()
	if stairs_cast.is_colliding():
			return true
	return false

func is_stairs_beneath() -> bool:
	stairs_beneath.force_shapecast_update()
	if stairs_beneath.is_colliding():
		return true
	return false

func get_staircase_point():
	stairs_cast.force_shapecast_update()
	if stairs_cast.is_colliding():
		# Sets position of stairs floor ray cast to the collision point
		stairs_floor_ray_cast.global_position.x = stairs_cast.get_collision_point(0).x
		stairs_floor_ray_cast.global_position.z = stairs_cast.get_collision_point(0).z
		stairs_floor_ray_cast.force_raycast_update()
		if stairs_floor_ray_cast.is_colliding():
			# Sets position of free space detector above and looking at collision point
			var _point = stairs_floor_ray_cast.get_collision_point()
			free_space_ray_cast.look_at(_point)
			free_space_ray_cast.rotation.x = 0
			free_space_ray_cast.rotation.z = 0
			free_space_ray_cast.global_position.y = _point.y + stairs_up_margin
			free_space_ray_cast.force_raycast_update()
			if not free_space_ray_cast.is_colliding():
				return _point
	return Vector3.ZERO

func is_ray_floor() -> bool:
	floor_cast.force_shapecast_update()
	if floor_cast.is_colliding():
		return true
	return false

func is_floor_raycast() -> bool:
	floor_ray.force_raycast_update()
	if floor_ray.is_colliding():
		return true
	return false

func get_floor_point():
	floor_cast.force_shapecast_update()
	if floor_cast.is_colliding():
		return floor_cast.get_collision_point(0)
	return Vector3.ZERO

#func get_staircase_normal() -> Vector3:
	#stairs_floor_ray_cast.force_raycast_update()
	#if stairs_floor_ray_cast.is_colliding():
		#return stairs_floor_ray_cast.get_collision_normal()
	#return Vector3.ZERO

func get_floor_normal()  -> Vector3:
	floor_cast.force_shapecast_update()
	#floor_ray.force_raycast_update()
	if floor_cast.is_colliding():
		var _normal = floor_cast.get_collision_normal(0)
		#var _normal = floor_ray.get_collision_normal()
		_normal.x = snapped(_normal.x, 0.001)
		_normal.y = snapped(_normal.y, 0.001)
		_normal.z = snapped(_normal.z, 0.001)
		return _normal
	return Vector3.ZERO

func is_on_slope() -> bool:
	var _floor_normal = get_floor_normal()
	var _up = owner.up_direction
	if _floor_normal.is_equal_approx(_up) or _floor_normal.is_equal_approx(Vector3.ZERO):
		%Label3.text = "is on slope: false \n" + str((_floor_normal)) #+ " " + str((_stairs_normal))
		return false
	%Label3.text = "is on slope: true \n" + str((_floor_normal))# + " " + str((_stairs_normal))
	return true
	
func is_touching_floor() -> bool:
	if is_ray_floor():
		#var _pointY = get_floor_point().y
		#if snappedf(_pointY, 0.01) == snappedf(owner.global_position.y, 0.01):
		if owner.is_on_floor():
			return true
	return false

func is_stair_near() -> bool:
	stairs_near.force_shapecast_update()
	if stairs_near.is_colliding():
		# Sets position of stairs floor ray cast to the collision point
		stairs_floor_ray_cast.global_position.x = stairs_near.get_collision_point(0).x
		stairs_floor_ray_cast.global_position.z = stairs_near.get_collision_point(0).z
		stairs_floor_ray_cast.force_raycast_update()
		if stairs_floor_ray_cast.is_colliding():
			# Sets position of free space detector above and looking at collision point
			var _point = stairs_floor_ray_cast.get_collision_point()
			free_space_ray_cast.look_at(_point)
			free_space_ray_cast.rotation.x = 0
			free_space_ray_cast.rotation.z = 0
			free_space_ray_cast.global_position.y = _point.y + stairs_up_margin
			free_space_ray_cast.force_raycast_update()
			if not free_space_ray_cast.is_colliding():
				return true
	return false




