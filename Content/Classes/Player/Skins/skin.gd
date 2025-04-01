extends MeshInstance3D

@onready var rdParticles: CPUParticles3D = $Particles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func emitJumpParticles():
	rdParticles.emitting = true
	
func emitDeathParticles():
	pass
	
