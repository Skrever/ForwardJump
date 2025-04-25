class_name DinamicFloor
extends StaticBody3D

@onready var rdDead: AudioStreamPlayer = $Dead

@onready var rdParticlesParent: Node3D = $Particles
@onready var rdDieParticles: CPUParticles3D = $Particles/ConfusedFace
@onready var rdDieParticles1: CPUParticles3D = $Particles/CryingFace
@onready var rdDieParticles2: CPUParticles3D = $Particles/DisapointedFace
@onready var rdDieParticles3: CPUParticles3D = $Particles/DowncastFace

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player.MovingFinished.connect(_move)
	Global.GameReload.connect(func(): position = Vector3.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move():
	position = Global.player.position * Vector3(1,0,1)


func _on_area_body_entered(body: Node3D) -> void: 
	if body is Player:
		rdDead.volume_db = -40 + Global.Sounds
		rdDead.play()
		body.dead()
		rdParticlesParent.global_position = body.global_position + Vector3(-1,0,-0.3)
		if body.CountJump < 2:
			rdDieParticles.emitting = true
		else:
			match randi_range(0, 3):
				0: rdDieParticles1.emitting = true
				1: rdDieParticles2.emitting = true
				2: rdDieParticles3.emitting = true
				3: 
					rdDieParticles2.emitting = true
					rdDieParticles3.emitting = true
