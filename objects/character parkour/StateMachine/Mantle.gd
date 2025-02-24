extends PlayerState

var mantle_point : Vector3 = Vector3.ZERO
var crouch_after : bool = false

signal end_mantle(state : String)

func on_enter():
	if not mantle_point.is_equal_approx(Vector3.ZERO):
		mantle_tween()

func on_physics_process(delta):
	pass

func on_exit():
	no_tilt()

func no_tilt():
	var cam_tilt = create_tween()
	var _tilt_time = 0.3
	var height = player.global_position.y - mantle_point.y
	var _tilt
	cam_tilt.tween_property(%Camera, "rotation_degrees:z", height, _tilt_time)
	await cam_tilt.finished
	cam_tilt.kill()
	

func mantle_tween():
	var tween = create_tween()
	var cam_straight = create_tween()
	var cam_tilt = create_tween()
	var time = 0.35
	tween.tween_property(player, "global_position", mantle_point, time)
	tween.play()
	var _to = 0
	var _cam_time = 0.3412
	cam_straight.tween_property(%Camera, "rotation:x", _to, _cam_time)
	cam_straight.play()
	var _tilt = -9.53
	var _tilt_time = 0.3
	cam_tilt.tween_property(%Camera, "rotation_degrees:z", _tilt, _tilt_time)
	cam_tilt.play()
	await tween.finished
	tween.kill()
	cam_straight.kill()
	cam_tilt.kill()
	end_mantle.emit("Idle")
	change_state("Idle")


#func _on_end_mantle(state: String) -> void:
	#change_state("Idle")
