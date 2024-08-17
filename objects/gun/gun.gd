extends Node3D
class_name Gun

enum AMMO_TYPE {Normal, Sticky, Floating, Enlarge, Shrink}

@export var bullet_scene : PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var gunpoint: Marker3D = $blasterG2/Gunpoint
@onready var reload_timer: Timer = $Timer

@export_group("Stats")
@export var bullet_speed : float
@export var firerate : float


var can_shoot : bool = true
var is_ready : bool = true

#signal reloaded


func _process(delta: float) -> void:
	if can_shoot:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			fire()

func mantle_start():
	can_shoot = false
	anim.play("bring_down")
	
func mantle_end():
	anim.play("bring_up")
	await anim.animation_finished
	can_shoot = true

func fire():
	if is_ready:
		anim.play("shoot")
		var fired_bullet = bullet_scene.instantiate() as Bullet
		get_tree().root.add_child(fired_bullet)
		
		fired_bullet.global_position = gunpoint.global_position
		fired_bullet.global_rotation = global_rotation
		fired_bullet.apply_force(-global_basis.z * bullet_speed)
		
		var _reload_time = 1 / firerate
		if not _reload_time < 0.01:
			reload_timer.start(_reload_time)
			is_ready = false
	else:
		return reload_timer.time_left

func reload() -> void:
	is_ready = true
	#reloaded.emit(self)
