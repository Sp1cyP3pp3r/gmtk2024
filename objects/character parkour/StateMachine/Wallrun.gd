extends PlayerState

@export var speed_curve : Curve 
@export var wall_curve : Curve 
var i : float = 0.0
var speed : float = 0

# should remove when make real walljump code
var _do_wallrun = true
var previous_wall : Vector3 = Vector3.ZERO

# Called when the state machine enters this state.
func on_enter():
	player.add_speed_ratio += -0.2
	player.speed = 5
	i = 0
	_do_wallrun = true
	speed = player.speed
	player.head.do_rotate_owner = false
	$Timer.start()
	$DotTimer.start()
	previous_wall = player.body.get_wall_normal()
	_dot = 1

var _can_jump := true


# Called every physics frame when this state is active.
func on_physics_process(delta):
	i += delta / 1.1
	player.add_speed_ratio += delta / 10
	
	
	if _do_wallrun:
		var additional_speed = player.speed * speed_curve.sample(player.add_speed_ratio) / 2
		var _total_speed = player.speed + additional_speed
		player.velocity.x = (-player.body.get_wall_normal() * 1.25 + \
		player.body.get_wall_forward() * _total_speed).x
		player.velocity.z = (-player.body.get_wall_normal()  * 1.25 + \
		player.body.get_wall_forward() * _total_speed).z
	
		var _wall_grav = wall_curve.sample(i)
		player.velocity.y -= player.gravity * delta
		player.velocity.y -= (player.velocity.y * _wall_grav)
		
		check_curve(delta)
	
		camera_tilt(delta)
	
	player.move_and_slide()
	
	
	if player.legs.is_floor_raycast() and not player.legs.is_on_slope():
		change_state("Idle")
	
	if not player.body.is_on_wall():# or not player.body.is_head_colliding():
		wallrun_timeout()
	
	if _can_jump:
		if Input.is_action_just_pressed("jump"):
			_do_wallrun = false
			player.velocity += player.body.get_wall_normal() * 3.3
			change_state("Jump")
	
	
		if Input.is_action_just_pressed("quick_turn"):
			var tween = create_tween()
			var _to = 90 * -player.body.get_wall_sign_direction()
			var _time = 0.1
			tween.tween_property(%Camera, "rotation_degrees:y", _to, _time)
			_can_jump = false
			tween.play()
			await tween.finished
			_can_jump = true
			tween.kill()
		

# Called when the state machine exits this state.
func on_exit():
	camera_tween_end() 
	player.global_rotation.y = player.head.camera.global_rotation.y
	player.head.camera.rotation.y = 0
	player.head.do_rotate_owner = true
	
	$Timer.stop()
	$DotTimer.stop()

func camera_tilt(delta):
	var sign_direction = player.body.get_wall_sign_direction()
	var _dot = abs(player.body.get_wall_dot())
	var cam_tilt : float = 12 * -sign_direction
	cam_tilt = cam_tilt - (cam_tilt * _dot)
	player.head.camera.rotation_degrees.z = lerp(player.head.camera.rotation_degrees.z, cam_tilt, delta)
	
	var _forward : Vector3 = player.body.get_wall_forward()
	var look = lerp(player.global_position + -player.global_basis.z, player.global_position + _forward, 10 * delta)
	player.look_at(look)
	
	var _yaw : float = player.head.camera.rotation_degrees.y
	
	var min_angle = min(0, 90 * -sign_direction)
	var max_angle = max(0, 90 * -sign_direction)
	var _yaw_clamped : float = clamp(_yaw, min_angle, max_angle)
	_yaw = _yaw_clamped
	
	player.head.camera.rotation_degrees.y = _yaw


func camera_tween_end():
	var _tween : Tween = create_tween()
	var sign_direction = player.body.get_wall_sign_direction()
	var cam_tilt = 0
	_tween.tween_property(player.head.camera, "rotation_degrees:z", cam_tilt, 0.24)
	_tween.play()
	await _tween.finished
	_tween.kill()


func wallrun_timeout():
	_do_wallrun = false
	var _temp_y = player.velocity.y
	player.velocity = previous_wall * 2 + -player.global_basis.z * player.speed
	player.velocity.y = _temp_y
	change_state("Air")

var _dot : float
func check_curve(delta):
	if _dot >= 0.0:
		previous_wall = player.body.get_wall_normal()
	else:
		wallrun_timeout()

func update_dot():
	_dot = previous_wall.dot(player.body.get_wall_normal())
	%Label5.text = str(_dot)
