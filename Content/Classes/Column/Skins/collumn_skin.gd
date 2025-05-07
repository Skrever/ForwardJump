class_name CollumnSkin
extends MeshInstance3D

@onready var rdParticles: CPUParticles3D = $Particles
var addedParticles : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addedParticles = get_child(0) if get_child(0) is MeshInstance3D else null
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func emitParticles(pos_ : Vector3 = Vector3(0, 4.031, 0)):
	rdParticles.position = pos_
	rdParticles.emitting = true 

func double_shake():
	var tween := create_tween().tween_method(_shaking, 0.0, 1.0, 0.1)
	await tween.finished
	create_tween().tween_method(_shaking, 1.0, 0.0, 0.1)
	
func _shaking(alpha : float):
	position = lerp(Vector3.ZERO, Vector3(0, -0.4, 0), alpha)
	if addedParticles != null: addedParticles.position = lerp(Vector3.ZERO, Vector3(0, 0.4, 0), alpha)
