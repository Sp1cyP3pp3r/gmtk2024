extends PlayerState


# Called when the state machine enters this state.
func on_enter():
	player.acceleration = 15.0
	

# Called every physics frame when this state is active.
func on_physics_process(delta):
	handle_no_floor()
	slopes_and_stairs(delta)
	smooth_landing(delta)
	handle_jump()
	handle_crouch()
	handle_quickturn()
	if Input.is_action_just_pressed("jump"):
		handle_ledgegrab()
	
	player.add_speed_ratio = lerp(player.add_speed_ratio, 0.0, delta * 1.5)
	player.velocity.x = lerp(player.velocity.x, 0 * player.speed, player.acceleration * delta)
	player.velocity.z = lerp(player.velocity.z, 0 * player.speed, player.acceleration * delta)
	player.move_and_slide()
	catch_movement()


# Called when the state machine exits this state.
func on_exit():
	pass
