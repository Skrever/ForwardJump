class_name Crown
extends Node3D

var KeepingUp : bool = false
@onready var rdRoot: Node3D = $Root
@onready var rdMesh: MeshInstance3D = $Root/Mesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Crown")
	_keep_upping(false)
	Global.PlayerLeadered.connect(_keep_upping)

func _keep_upping(val : bool):
	if val:
		position = Global.player.position if Global.player != null else Vector3(0, 30, 0)
		create_tween().tween_property(self, "scale", Vector3(1,1,1), 0.15).set_ease(Tween.EASE_IN_OUT)
		KeepingUp = true
	else:
		KeepingUp = false
		create_tween().tween_property(self, "scale", Vector3.ZERO, 0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees.y += 25 * delta
	if KeepingUp:
		if Global.player != null and position.distance_to(Global.player.position) > 0.1:
			rdRoot.look_at(Global.player.position)
			rdMesh.rotation_degrees.x = 90
			position = position.lerp(Global.player.position, delta * 15)
