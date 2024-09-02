extends Node3D

@onready var obstacle_detector: ShapeCast3D = $ObstacleDetector
@onready var obstacle_height: RayCast3D = $ObstacleHeight
@onready var obstacle_obstr: RayCast3D = $ObstacleObstr
@onready var free_space_standing: ShapeCast3D = %FreeSpaceStanding
@onready var free_space_crouch: ShapeCast3D = %FreeSpaceCrouch
@onready var height_spring_arm: SpringArm3D = $HeightSpringArm


var current_target : Vector3
var current_position : Vector3
var init_position : Vector3

signal update_ledge(point : Vector3)

func _ready() -> void:
	init_position = position
	obstacle_detector.add_exception(owner)
	obstacle_height.add_exception(owner)
	obstacle_obstr.add_exception(owner)
	free_space_crouch.add_exception(owner)
	free_space_standing.add_exception(owner)
	height_spring_arm.add_excluded_object(owner)


func is_wall() -> bool:
	if not is_obstacle():
		return false
	if get_obstacle_height() <= 100:
		return false
	return true

func is_obstacle()  -> bool:
	#obstacle_detector.force_shapecast_update()
	if not obstacle_detector.is_colliding():
		return false
	current_position = obstacle_detector.get_collision_point(0)
	return true

func get_obstacle_height() -> float:
	var _temp_y = obstacle_height.global_position.y
	obstacle_height.global_position = current_position
	obstacle_height.global_position += -obstacle_detector.get_collision_normal(0) * 0.01
	obstacle_height.global_position.y = _temp_y
	#obstacle_height.force_raycast_update()
	if not obstacle_height.is_colliding():
		# Is inside a wall
		return 999.9
	current_target = obstacle_height.get_collision_point()
	var _value : float = abs(owner.global_position.y - current_target.y)
	update_ledge.emit(current_target)
	return _value

func has_freespace_standing() -> bool:
	#var _margin = -init_position.y + 0.01 + free_space_standing.shape.height
	#free_space_standing.position.y = get_obstacle_height() - _margin
	free_space_standing.force_shapecast_update()
	if free_space_standing.is_colliding():
		return false
	return true
	
func has_freespace_crouching() -> bool:
	#var _margin =  0.01 + free_space_crouch.shape.height + 0.225 
	#free_space_crouch.position.y = get_obstacle_height() - _margin
	free_space_crouch.force_shapecast_update()
	if free_space_crouch.is_colliding():
		return false
	return true

func has_free_way() -> bool:
	obstacle_obstr.global_position = %Camera.global_position
	var dir = obstacle_obstr.global_position.direction_to(current_target + Vector3(0, 0.5, 0))
	var dist = obstacle_detector.global_position.distance_to(current_target)
	obstacle_obstr.target_position = dir * dist
	obstacle_obstr.force_raycast_update()
	if obstacle_obstr.is_colliding():
		return false
	return true
