class_name Collumn
extends StaticBody3D

var Use : bool = false
var NextCollumnAt : Global.DIRECTION = Global.DIRECTION.LEFT
var DistanceToNextCollumn : float = 0

var shakeX : float = randf_range(0.1,0.15)
var shakeZ : float = randf_range(0.1,0.15)

var canShake : bool = true

@onready var rdGoalEffect: Node3D = $GoalEffect
@onready var rdMesh: MeshInstance3D = $CollisionShape3D/Mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func reload():
	Use = false
	NextCollumnAt = Global.DIRECTION.LEFT
	DistanceToNextCollumn = 0
	

func _on_goal_area_body_entered(body: Node3D) -> void:
	if body is Player and canShake:
		_shake()
		for i in range(0, rdGoalEffect.get_children().size()):
			rdGoalEffect.get_children()[i].setVisible()
			rdGoalEffect.get_children()[i].setInvisible()
			await get_tree().create_timer(0.1).timeout
			#rdGoalEffect.get_children()[i].visible = false

func _shake():
	var tweenX : Tween = create_tween()
	tweenX.tween_property(rdMesh, "position:x", shakeX, 0.05)
	var tweenY : Tween = create_tween()
	tweenY.tween_property(rdMesh, "position:z", -shakeZ, 0.071)
	
	await tweenX.finished
	tweenX = create_tween()
	tweenX.tween_property(rdMesh, "position:x", -shakeX, 0.05)
	await tweenY.finished
	tweenY = create_tween()
	tweenY.tween_property(rdMesh, "position:z", shakeZ, 0.071)
	
	
	await tweenY.finished
	tweenX = create_tween()
	tweenX.tween_property(rdMesh, "position:x", 0, 0.05)
	tweenY = create_tween()
	tweenY.tween_property(rdMesh, "position:z", 0, 0.071)
