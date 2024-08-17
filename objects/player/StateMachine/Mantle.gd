extends PlayerState

var mantle_point : Vector3
var crouch : bool

signal gun_down
signal gun_up


func on_enter():
	player.is_mantling = true
	if mantle_point != Vector3.ZERO:
		player.velocity = Vector3.ZERO
		player.head.do_rotate_owner = false
		body_tween()
		cam_tween()
		gun_down.emit()
	else:
		end_mantle()

func on_physics_process(delta):
	pass

func on_exit():
	tweens_ended = 0
	mantle_point = Vector3.ZERO
	player.global_rotation.y = player.head.camera.global_rotation.y
	player.head.camera.rotation.y = 0
	player.head.do_rotate_owner = true
	player.is_mantling = false


var time : float

func cam_tween():
	var _tween = create_tween()
	var _to = -5
	_tween.tween_property(%Camera, "rotation_degrees:z", _to, time/2)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.play()
	_tween.connect("finished", Callable(self, "ending_tweens"))
	await _tween.finished
	_tween.kill()
	
	var _tween2 = create_tween()
	var _to2 = 0
	_tween2.tween_property(%Camera, "rotation_degrees:z", _to2, time/2)
	_tween2.set_ease(Tween.EASE_IN)
	_tween2.play()
	_tween2.connect("finished", Callable(self, "ending_tweens"))
	
	gun_up.emit()
	await _tween2.finished
	_tween2.kill()

func body_tween():
	var _tween = create_tween() as Tween
	var _to : Vector3 = player.global_position + -player.global_basis.z
	_to.y = mantle_point.y
	time = 0.3 * player.global_position.distance_to(_to)
	_tween.tween_property(player, "global_position", _to, time)
	_tween.play()
	_tween.connect("finished", Callable(self, "ending_tweens"))
	await _tween.finished
	_tween.kill()

func get_mantle_point(point : Vector3):
	mantle_point = point

var tweens_ended : int = 0
func ending_tweens():
	tweens_ended += 1
	if tweens_ended >= 3:
		end_mantle()

func end_mantle():
	if crouch:
		change_state("Crouch")
		return
	change_state("Run")
