class_name Gem
extends Area3D

var Use : bool = false

var _closePlayer : Player = null

@onready var rdParticles: CPUParticles3D = $Particles
@onready var rdGem: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn(pos_ : Vector3):
	position = pos_
	Use = true
	create_tween().tween_property(rdGem, "scale", Vector3(1, 1, 1), 0.1)

func reload(pos_ : Vector3 = Vector3(0,30, 0)):
	position = pos_
	Use = false
	


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_closePlayer = body as Player
		var tween := create_tween().tween_method(_interpolate_to_player, 0.0, 1.0, 0.1)
		await  tween.finished
		Global.Gems += 1
		rdParticles.emitting = true
		await  get_tree().create_timer(1).timeout
		reload()

func _interpolate_to_player(alpha : float):
	position = lerp(position, _closePlayer.position + Vector3(0,2,0), alpha)
	rdGem.scale = lerp(Vector3(1, 1, 1), Vector3.ZERO, alpha)
