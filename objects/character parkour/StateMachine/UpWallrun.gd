extends PlayerState

@export var up_curve : Curve

# Called when the state machine enters this state.
func on_enter():
	# ПЕРЕДЕЛАТЬ
	coyote = false
	player.velocity = Vector3.ZERO
	player.velocity.y = 0.01
	i = player.add_speed_ratio
	QT = false
	player.head.do_rotate = false
	var pos = player.global_position - player.climb.current_normal
	player.look_at(pos)
	cam_tween()
	$WallTimer.start()


var normal : Vector3
var i: = 1.0
var QT : = false
var coyote := false

func on_physics_process(delta):
	player.move_and_slide()
	handle_ledgegrab()
	i = i - delta / 2
	var sample = up_curve.sample(i)
	if not QT:
		if not coyote:
			player.velocity.y = 5.5 * sample
		else:
			handle_fall(delta / 1.5)
		
		if not player.climb.is_obstacle():
			change_state("Air")
		handle_quickturn()
		if Input.is_action_just_pressed("quick_turn"):
			QT = true
			cam_tween_end()
			player.velocity.y = player.velocity.y / 3
			$WallTimer.stop()
			$TurnTimer.start()
			
	
	
	if QT:
		if Input.is_action_just_pressed("jump"):
			normal = player.body.get_wall_normal()
			$"../UpWallrunJump".wall_normal = normal
			change_state("UpWallrunJump")
	
	

func on_exit():
	if not QT:
		cam_tween_end()
	player.head.do_rotate = true
	player.add_speed_ratio = 0


func _on_timer_timeout() -> void:
	change_state("Air")

func _on_walltimer_timeout() -> void:
	coyote = true
	$CoyoteTimer.start()

func cam_tween():
	var tween = create_tween()
	var _to = PI / 2 / 1.2
	var time = 0.28
	tween.tween_property(%Camera, "rotation:x", _to, time)
	tween.play()
	await tween.finished
	tween.kill()

func cam_tween_end():
	var tween = create_tween()
	var _to = 0
	var time = 0.28
	tween.tween_property(%Camera, "rotation:x", _to, time)
	tween.play()
	await tween.finished
	tween.kill()
