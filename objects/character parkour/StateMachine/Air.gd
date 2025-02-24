extends PlayerState

var _power = 0.01

# Called when the state machine enters this state.
func on_enter():
	player.acceleration = 0.8
	match %FiniteStateMachine._previous_state.name:
		"Run", "Idle", "Wallrun", "UpWallrun":
			can_jump_in_this_state = true
			$CoyoteTimer.start()

# Called every physics frame when this state is active.
func on_physics_process(delta):
	handle_fall(delta)
	handle_landing()
	handle_movement(delta)
	handle_jump()
	handle_ledgegrab()

# Called when the state machine exits this state.
func on_exit():
	pass

func coyote_disable_jump() -> void :
	can_jump_in_this_state = false

func handle_landing():
	if not player.legs.is_touching_floor():
		_power = abs(player.velocity.y / 18)
	else:
		player.add_speed_ratio -= _power
		change_state("Run")
