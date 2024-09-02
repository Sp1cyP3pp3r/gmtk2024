extends Node3D
class_name Gun

@export var audio_shoot_array : Array[AudioStream]
@export var audio_laser_array : Array[AudioStream]
@export var audio_jam_array : Array[AudioStream]

#enum AMMO_TYPE {Normal, Sticky, Floaty}
enum BEAM_TYPE {Enlarge, Shrink}

@export var bullet_scene : PackedScene
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var gunpoint: Marker3D = $blasterG2/Gunpoint
@onready var reload_timer: Timer = $Timer
@onready var free_space: ShapeCast3D = $blasterG2/Gunpoint/FreeSpace

@onready var normal_box_ammo: TextureProgressBar = %NormalBoxAmmo
@onready var floaty_box_ammo: TextureProgressBar = %FloatyBoxAmmo
@onready var sticky_box_ammo: TextureProgressBar = %StickyBoxAmmo
@onready var enlarge_bar: TextureProgressBar = %EnlargeBar
@onready var shrink_bar: TextureProgressBar = %ShrinkBar
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var hologram: Sprite3D = %Hologram
@onready var beam_holo: Sprite3D = $blasterG2/Gunpoint/Beam
@onready var hud: CanvasLayer = $CanvasLayer
@onready var mesh: MeshInstance3D = $blasterG2/blasterG




@export_group("Stats")
@export var bullet_speed : float
@export var firerate : float
@export var scale_power : float = 0.05
@export var scale_value : float = 0.375

#var current_ammo : AMMO_TYPE = AMMO_TYPE.Normal
var current_ammo : BoxType.Type = BoxType.Type.Normal
var current_beam : BEAM_TYPE = BEAM_TYPE.Enlarge
var can_shoot : bool = true
var is_ready : bool = true

signal shooted


func _physics_process(delta: float) -> void:
	if visible == false:
		can_shoot = false
	
	if owner.is_multiplayer_authority():
		if Input.is_action_pressed("box1"):
			current_ammo = BoxType.Type.Normal
			hologram.texture = preload("res://hud/icon_normal.svg")
		elif Input.is_action_pressed("box2"):
			current_ammo = BoxType.Type.Floaty
			hologram.texture = preload("res://hud/icon_floaty.svg")
		elif Input.is_action_pressed("box3"):
			current_ammo = BoxType.Type.Sticky
			hologram.texture = preload("res://hud/icon_sticky.svg")
		
		if Input.is_action_pressed("beam2"):
			current_beam = BEAM_TYPE.Enlarge
			beam_holo.texture = preload("res://hud/icon_enlarge.svg")
		elif Input.is_action_pressed("beam1"):
			current_beam = BEAM_TYPE.Shrink
			beam_holo.texture = preload("res://hud/icon_shrink.svg")
	
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

func gun_jam():
	if not anim.is_playing():
		anim.play("yoink")
		var size = audio_jam_array.size()
		randomize()
		var i = randi_range(0, size - 1)
		$AudioJam.stream = audio_jam_array[i]
		$AudioJam.play()

func beam():
	if can_shoot:
		if not free_space.is_colliding():
			match current_beam:
				BEAM_TYPE.Enlarge:
					if enlarge_bar.value <= 0:
						gun_jam()
						return
					
				BEAM_TYPE.Shrink:
					if shrink_bar.value <= 0:
						gun_jam()
						return
			
			shooted.emit()
			anim.play("shoot")
			
			var size = audio_laser_array.size()
			randomize()
			var i = randi_range(0, size - 1)
			$AudioLaser.stream = audio_laser_array[i]
			$AudioLaser.play()
			
			var server = get_world_3d().direct_space_state
			var params = PhysicsRayQueryParameters3D.new()
			params.collision_mask = pow(2, 5-1) + pow(2, 4-1)
			params.from =  %Camera.global_position
			var _to = %Camera.global_position + -%Camera.global_basis.z * 50
			params.to = _to
			var ray = server.intersect_ray(params)
			var color : Color = Color.DARK_SLATE_GRAY
			if not ray.is_empty():
				_to = ray.position
				if ray.collider is Box:
					var box = ray.collider as Box
					
					var face : Basis = box.global_basis.orthonormalized()
					var normal = ray.normal
					var direction : Vector3 = normal * face # actual face
					var value = abs(direction)
					var final_value = value * scale_power
					
					var offset = normal * scale_power / 2
					
					if abs(direction).is_equal_approx(Vector3.RIGHT):
						if box.size.x >= box.max_size:
							offset = Vector3.ZERO
						elif box.size.x <= box.min_size:
							offset = Vector3.ZERO
					elif abs(direction).is_equal_approx(Vector3.BACK):
						if box.size.z >= box.max_size:
							offset = Vector3.ZERO
						elif box.size.z <= box.min_size:
							offset = Vector3.ZERO
					elif abs(direction).is_equal_approx(Vector3.UP):
						if box.size.y >= box.max_size:
							offset = Vector3.ZERO
						elif box.size.y <= box.min_size:
							offset = Vector3.ZERO
					
					
					match current_beam:
						BEAM_TYPE.Enlarge:
							box.size += final_value
							box.global_position += offset
							color = Color("d34949")
							if not offset.is_equal_approx(Vector3.ZERO):
								enlarge_bar.value -= scale_value
								shrink_bar.value += scale_value / 2
							else:
								color = Color("b63e32")
							
						BEAM_TYPE.Shrink:
							box.size -= final_value
							box.global_position -= offset
							color = Color("5f66d3")
							if not offset.is_equal_approx(Vector3.ZERO):
								shrink_bar.value -= scale_value
								enlarge_bar.value += scale_value / 2
							else:
								color = Color("4148b3")
							
			
			line(gunpoint.global_position, _to, color, 0.025)
		
		
		
	pass

func fire():
	if not free_space.is_colliding():
		if is_ready:
			match current_ammo:
				#TODO
				BoxType.Type.Normal:
					if normal_box_ammo.value <= 0:
						gun_jam()
						reloading()
						return
					
				BoxType.Type.Floaty:
					if floaty_box_ammo.value <= 0:
						gun_jam()
						reloading()
						return
				
				BoxType.Type.Sticky:
					if sticky_box_ammo.value <= 0:
						gun_jam()
						reloading()
						return
			
			shooted.emit()
			anim.play("shoot")
			
			var fired_bullet = bullet_scene.instantiate() as Bullet
			get_tree().root.get_child(1).add_child(fired_bullet)
			
			fired_bullet.global_position = gunpoint.global_position
			fired_bullet.global_rotation = global_rotation
			fired_bullet.apply_impulse(-global_basis.z * bullet_speed)
			
			match current_ammo:
				BoxType.Type.Normal:
					#fired_bullet.box_scene = preload("res://objects/box/box.tscn")
					fired_bullet.force_speed = 20
					normal_box_ammo.value -= 1
					
				BoxType.Type.Floaty:
					#fired_bullet.box_scene = preload("res://objects/box/box_floaty.tscn")
					fired_bullet.force_speed = 2.5
					floaty_box_ammo.value -= 1
				
				BoxType.Type.Sticky:
					#fired_bullet.box_scene = preload("res://objects/box/box_sticky.tscn")
					fired_bullet.force_speed = 3
					sticky_box_ammo.value -= 1
			fired_bullet.box_type = current_ammo
			var size = audio_shoot_array.size()
			randomize()
			var i = randi_range(0, size - 1)
			audio.stream = audio_shoot_array[i]
			audio.play()
			
			reloading()
		else:
			return reload_timer.time_left
	else:
		gun_jam()
		reloading()

func reloading():
	var _reload_time = 1 / firerate
	if not _reload_time < 0.01:
		reload_timer.start(_reload_time)
		is_ready = false

func reload() -> void:
	is_ready = true
	#reloaded.emit(self)



func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE, persist_ms = 0):
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

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
