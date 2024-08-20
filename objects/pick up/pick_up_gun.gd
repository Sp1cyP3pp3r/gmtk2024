extends Area3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var color : Color = Color("#49b6d3")
	particles.draw_pass_1.surface_get_material(0).albedo_color = color



func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		$AudioStreamPlayer3D.play()
		body.gun.visible = true
		body.gun.hud.visible = true
		body.gun.can_shoot = true
		particles.emitting = false
		collision.disabled = true
		await $AudioStreamPlayer3D.finished
		queue_free()
