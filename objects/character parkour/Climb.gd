extends Node3D

@onready var obstacle_detector: ShapeCast3D = $ObstacleDetector
@onready var obstacle_height: RayCast3D = $ObstacleHeight
@onready var obstacle_obstr: = $ObstacleObstr
@onready var stand_free_space: ShapeCast3D = $MantleContainer/StandFreeSpace
@onready var crouch_free_space: ShapeCast3D = $MantleContainer/CrouchFreeSpace
@onready var mantle_through: ShapeCast3D = $MantleThrough
@onready var mantle_container: Node3D = $MantleContainer



var current_position : Vector3
var init_position : Vector3

signal update_ledge(point : Vector3)

func _ready() -> void:
	init_position = position

#func _physics_process(delta: float) -> void:
	#can_mantle()

func can_mantle() -> bool:
	if owner.velocity.y < -10:
		printerr("UR FALLING TOO FAST")
		return false
	mantle_through.global_position.y = get_mantle_point().y + 0.5 + 0.015
	#mantle_through.force_shapecast_update()
	if mantle_through.is_colliding():
		printerr("cant mantle through")
		return false
	if is_free_space():
		%Mantle.mantle_point = get_mantle_point()
		%Mantle.crouch_after = crouched
		printerr("Mantled")
		return true
	printerr("No free space")
	return false

func get_mantle_point() -> Vector3:
	
	if obstacle_height.is_colliding():
		return obstacle_height.get_collision_point()
	return Vector3.ZERO

var crouched : bool = false
func is_free_space() -> bool:
	mantle_container.global_position = owner.global_position + -owner.global_basis.z * 0.506
	mantle_container.global_position.y = get_mantle_point().y + 0.1
	
	crouch_free_space.force_shapecast_update()
	if crouch_free_space.is_colliding():
		return false
	stand_free_space.force_shapecast_update()
	if stand_free_space.is_colliding():
		crouched = true
		return true
	crouched = false
	return true

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
	current_normal = obstacle_detector.get_collision_normal(0)
	return true

var current_normal : Vector3

func can_grab_ledge() -> bool:
	obstacle_obstr.global_position.y = get_mantle_point().y + 0.03
	#obstacle_obstr.global_basis.z = current_normal
	obstacle_obstr.force_raycast_update()
	if obstacle_obstr.is_colliding():
		return false
	return true

func get_obstacle_height() -> float:
	var _temp_y = obstacle_height.global_position.y
	obstacle_height.global_position = current_position
	obstacle_height.global_position += -current_normal * 0.01
	obstacle_height.global_position.y = _temp_y
	#obstacle_height.force_raycast_update()
	if not obstacle_height.is_colliding():
		# Is inside a wall
		return 999.9
	var _point : Vector3 = obstacle_height.get_collision_point()
	var _value : float = abs(owner.global_position.y - _point.y)
	print("obstacle height " + str(_value))
	update_ledge.emit(_point)
	return _value
