extends Box

@export var float_curve : Curve
@export var float_power : float = 5
var i : float = 0

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	i += delta / 4
	
	i = clamp(i, 0, 1)
	var sample = float_curve.sample(i)
	var force = Vector3.UP * (sample * float_power)
	apply_force(force)
