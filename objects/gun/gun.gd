extends Node3D
class_name Gun

enum AMMO_TYPE {Normal, Sticky, Floaty}
enum BEAM_TYPE {Enlarge, Shrink}

@export var bullet_scene : PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var gunpoint: Marker3D = $blasterG2/Gunpoint
@onready var reload_timer: Timer = $Timer
@onready var free_space: ShapeCast3D = $blasterG2/Gunpoint/FreeSpace

@export_group("Stats")
@export var bullet_speed : float
@export var firerate : float

var current_ammo : AMMO_TYPE = AMMO_TYPE.Normal
var current_beam : BEAM_TYPE = BEAM_TYPE.Enlarge
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
	
	if Input.is_action_pressed("beam2"):
		current_beam = BEAM_TYPE.Enlarge
	elif Input.is_action_pressed("beam1"):
		current_beam = BEAM_TYPE.Shrink
	
	if can_shoot:
		if Input.is_action_pressed("shoot"):
			fire()
		if Input.is_action_pressed("beam"):
			beam()

func mantle_start():
	can_shoot = false
	anim.play("bring_down")
	
func mantle_end():
	anim.play("bring_up")
	await anim.animation_finished
	can_shoot = true

func beam():
	if not free_space.is_colliding():
		shooted.emit()
		anim.play("shoot")
		
		var server = get_world_3d().direct_space_state
		var params = PhysicsRayQueryParameters3D.new()
		params.collision_mask = pow(2, 1-1) + pow(2, 4-1)
		params.from = gunpoint.global_position
		var _to = global_position + -global_basis.z * 50
		params.to = _to
		var ray = server.intersect_ray(params)
		var color : Color = Color.DARK_SLATE_GRAY
		if not ray.is_empty():
			_to = ray.position
			if ray.collider is Box:
				var box = ray.collider
				match current_beam:
					BEAM_TYPE.Enlarge:
						box.size *= 1.01
						color = Color.BROWN
						
					BEAM_TYPE.Shrink:
						box.size *= 0.99
						color = Color.DARK_CYAN
						
						
		
		line(gunpoint.global_position, _to, color, 0.025)
		
		
		
	pass

func fire():
	if not free_space.is_colliding():
		if is_ready:
			shooted.emit()
			anim.play("shoot")
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
					
			var _reload_time = 1 / firerate
			if not _reload_time < 0.01:
				reload_timer.start(_reload_time)
				is_ready = false
		else:
			return reload_timer.time_left


func reload() -> void:
	is_ready = true
	#reloaded.emit(self)



func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	#immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	#immediate_mesh.surface_add_vertex(pos1)
	#immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	immediate_mesh.surface_add_vertex(pos1 + Vector3(0, 0.03, -0.04))
	immediate_mesh.surface_add_vertex(pos1 + Vector3(0.02, -0.06, 0))
	immediate_mesh.surface_add_vertex(pos2 + Vector3(0, 0.03,  -0.04))
	immediate_mesh.surface_end()
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	immediate_mesh.surface_add_vertex(pos2 + Vector3(0, 0.03,  -0.04))
	immediate_mesh.surface_add_vertex(pos1 + Vector3(0.02, -0.06, 0))
	immediate_mesh.surface_add_vertex(pos2 + Vector3(0.02, -0.06, 0))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	immediate_mesh.surface_set_material(0, material)
	immediate_mesh.surface_set_material(1, material)
	
	return await final_cleanup(mesh_instance, persist_ms)
	
func final_cleanup(mesh_instance: MeshInstance3D, persist_ms: float):
	get_tree().get_root().add_child(mesh_instance)
	await get_tree().create_timer(persist_ms).timeout
	mesh_instance.queue_free()
