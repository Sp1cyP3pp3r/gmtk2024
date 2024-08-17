extends Node3D
class_name Gun

enum AMMO_TYPE {Normal, Sticky, Floaty, Enlarge, Shrink}

@export var bullet_scene : PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var gunpoint: Marker3D = $blasterG2/Gunpoint
@onready var reload_timer: Timer = $Timer
@onready var free_space: ShapeCast3D = $blasterG2/Gunpoint/FreeSpace

@export_group("Stats")
@export var bullet_speed : float
@export var firerate : float

var current_ammo : AMMO_TYPE = AMMO_TYPE.Normal
var can_shoot : bool = true
var is_ready : bool = true

signal shooted


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("box1"):
		current_ammo = AMMO_TYPE.Normal
	elif Input.is_action_pressed("box2"):
		current_ammo = AMMO_TYPE.Floaty
	elif Input.is_action_pressed("box3"):
		current_ammo = AMMO_TYPE.Sticky
	
	if can_shoot:
		if Input.is_action_pressed("shoot"):
			fire()

func mantle_start():
	can_shoot = false
	anim.play("bring_down")
	
func mantle_end():
	anim.play("bring_up")
	await anim.animation_finished
	can_shoot = true

func fire():
	if not free_space.is_colliding():
		if is_ready:
			shooted.emit()
			anim.play("shoot")
			if current_ammo != AMMO_TYPE.Enlarge:
				if current_ammo != AMMO_TYPE.Shrink:
					var fired_bullet = bullet_scene.instantiate() as Bullet
					get_tree().root.add_child(fired_bullet)
					
					fired_bullet.global_position = gunpoint.global_position
					fired_bullet.global_rotation = global_rotation
					fired_bullet.apply_impulse(-global_basis.z * bullet_speed)
					
					match current_ammo:
						AMMO_TYPE.Normal:
							fired_bullet.box_scene = preload("res://objects/box/box.tscn")
							fired_bullet.force_speed = 20
							
						AMMO_TYPE.Floaty:
							fired_bullet.box_scene = preload("res://objects/box/box_floaty.tscn")
							fired_bullet.force_speed = 2.5
						
						AMMO_TYPE.Sticky:
							fired_bullet.box_scene = preload("res://objects/box/box_sticky.tscn")
							fired_bullet.force_speed = 3
				else:
					pass
			
			var _reload_time = 1 / firerate
			if not _reload_time < 0.01:
				reload_timer.start(_reload_time)
				is_ready = false
		else:
			return reload_timer.time_left

func reload() -> void:
	is_ready = true
	#reloaded.emit(self)
