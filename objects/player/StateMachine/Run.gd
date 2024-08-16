extends PlayerState

func on_enter():
	player.speed = 6
	player.acceleration = 30

func on_physics_process(delta):
	handle_movement(delta)
	handle_no_floor()
	slopes_and_stairs(delta)
	catch_no_movement()
	smooth_landing(delta)
	handle_crouch()
	
	if Input.is_action_pressed("jump"):
		handle_mantle()
	handle_jump()
	

func on_exit():
	pass
