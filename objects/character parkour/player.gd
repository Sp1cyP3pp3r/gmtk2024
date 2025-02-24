extends CharacterBody3D
class_name Player

@export var legs : Node3D
@export var head : Node3D
@export var body : Node3D
@export var climb : Node3D

@export var speed : float
@export var acceleration : float
@export var add_speed_ratio : float = 0
@export var gravity : float
@export var jump_power : float

var debug_letters : = 0
@onready var state_machine = %FiniteStateMachine

func _physics_process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y = -20
	%Label2.text = str($FiniteStateMachine.current_state.name)
	%Label4.text = str(snapped(Vector3(velocity.x, 0, velocity.z).length(), 0.001))\
	 + " " + str(snapped(speed, 0.1)) + " " + str(snapped(add_speed_ratio, 0.01)) + "\n" + str(snapped(velocity.y, 0.1))
	
	$CanvasLayer/Label.text = str(debug_letters) + "/10"
