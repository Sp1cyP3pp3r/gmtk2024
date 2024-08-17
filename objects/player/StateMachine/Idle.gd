extends PlayerState


# Called when the state machine enters this state.
func on_enter():
	player.acceleration = 15.0
	player.global_rotation.y = player.head.camera.global_rotation.y
	player.head.camera.rotation.y = 0
	player.head.do_rotate_owner = true

# Called every physics frame when this state is active.
func on_physics_process(delta):
	handle_no_floor()
	slopes_and_stairs(delta)
	smooth_landing(delta)
	
	if Input.is_action_pressed("jump"):
		handle_mantle()
	
	handle_jump()
	handle_crouch()
	
	player.velocity.x = lerp(player.velocity.x, 0 * player.speed, player.acceleration * delta)
	player.velocity.z = lerp(player.velocity.z, 0 * player.speed, player.acceleration * delta)
	player.move_and_slide()
	catch_movement()


# Called when the state machine exits this state.
func on_exit():
	pass
