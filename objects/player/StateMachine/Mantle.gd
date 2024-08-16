extends PlayerState

var mantle_point : Vector3
var crouch : bool

func on_enter():
	if mantle_point != Vector3.ZERO:
		player.head.do_rotate_owner = false
		cam_tween()

func on_physics_process(delta):
	pass

func on_exit():
	mantle_point = Vector3.ZERO
	player.global_rotation.y = player.head.camera.global_rotation.y
	player.head.camera.rotation.y = 0
	player.head.do_rotate_owner = true



func cam_tween():
	var _tween = create_tween()
	var _from : Vector3 = %Camera.global_position + -%Camera.global_basis.z
	var _to : Vector3 = owner.global_position + -owner.global_basis.z
	_to.y = mantle_point.y
	var time = 10 * _to.angle_to(_from)
	_tween.tween_method(Callable(%Camera, "look_at"), _from, _to, time)
	_tween.play()
	await _tween.finished
	_tween.kill()


func get_mantle_point(point : Vector3):
	mantle_point = point
