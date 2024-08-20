extends Area3D

enum TYPE {Normal, Floaty, Sticky, Enlarge, Shrink}

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hologram : Sprite3D = $Sprite3D



@export var pickup_type : TYPE
@export var respawn_time : float = 10


func _ready() -> void:
	var color : Color
	match pickup_type:
		TYPE.Normal:
			color = Color("ffb380")
			hologram.texture = preload("res://hud/icon_normal.svg")
			
		TYPE.Floaty:
			color = Color("80b3ff")
			hologram.texture = preload("res://hud/icon_floaty.svg")
			
		TYPE.Sticky:
			color = Color("d35f8d")
			hologram.texture = preload("res://hud/icon_sticky.svg")
			
		TYPE.Enlarge:
			color = Color("d34949")
			hologram.texture = preload("res://hud/icon_enlarge.svg")
			
		TYPE.Shrink:
			color = Color("5f66d3")
			hologram.texture = preload("res://hud/icon_shrink.svg")
			
	particles.draw_pass_1.surface_get_material(0).albedo_color = color



func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		var gun = body.gun
		if gun.visible:
			match pickup_type:
				TYPE.Normal:
					if gun.normal_box_ammo.value >= gun.normal_box_ammo.max_value:
						return
					else:
						gun.normal_box_ammo.value += 1
						
				
				TYPE.Floaty:
					if gun.floaty_box_ammo.value >= gun.floaty_box_ammo.max_value:
						return
					else:
						gun.floaty_box_ammo.value += 1
				
				TYPE.Sticky:
					if gun.sticky_box_ammo.value >= gun.sticky_box_ammo.max_value:
						return
					else:
						gun.sticky_box_ammo.value += 1
				
				TYPE.Enlarge:
					if gun.enlarge_bar.value >= gun.enlarge_bar.max_value:
						return
					else:
						gun.enlarge_bar.value += 15
				TYPE.Shrink:
					if gun.shrink_bar.value >= gun.shrink_bar.max_value:
						return
					else:
						gun.shrink_bar.value += 15
			
			$AudioStreamPlayer3D.play()
			monitoring = false
			collision.disabled = true
			particles.emitting = false
			animation_player.play("disappear")
			timer.start(respawn_time)


func _on_timer_timeout() -> void:
		monitoring = true
		collision.disabled = false
		particles.emitting = true
		animation_player.play("appear")
