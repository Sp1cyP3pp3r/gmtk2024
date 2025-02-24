extends PlayerState

var wall_normal : Vector3

# Called when the state machine enters this state.
func on_enter():
	wall_normal = -player.global_basis.z
	player.add_speed_ratio += 0.5
	player.acceleration = 1.0
	player.velocity = wall_normal * 5
	player.velocity.y = player.jump_power * 1.1


# Called every physics frame when this state is active.
func on_physics_process(delta):
	player.move_and_slide()
	handle_fall(delta)
	#handle_movement(delta)
	handle_ledgegrab()
	handle_wallrun()
	if player.velocity.y <= 0:
		change_state("Air")
	if player.is_on_floor():
		change_state("Air")

# Called when the state machine exits this state.
func on_exit():
	pass

func handle_wallrun():
	var _vel = player.velocity
	_vel.y = 0
	var _len = _vel.length()
	if player.body.is_on_wall():
		# horizontal wallrun
		var _dot = player.body.get_wall_dot()
		if _dot:
			if _dot <= -0.1 and _dot >= -0.85:
				if player.body.is_upper_head_colliding():
					change_state("Wallrun")
			# vertical wallrun
			elif _dot <= -0.85 and _dot >= -1:
				if player.climb.is_wall():
					change_state("UpWallrun")

#func handle_climbing():
	#var _height = player.climb.get_obstacle_height()
	#
	#pass
