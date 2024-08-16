extends CharacterBody3D
class_name Player

@export var legs : Node3D
@export var head : Node3D
@export var climb : Node3D

@export var speed : float
@export var acceleration : float
@export var gravity : float
@export var jump_power : float

@onready var state_machine = %FiniteStateMachine

func _physics_process(delta):
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y = -20
	%Label2.text = str($FiniteStateMachine.current_state.name)
