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
@onready var rdLabel: Label = $NumberEffect/NumberEffect/SubViewport/Label
@onready var rdNumberEffect: Sprite3D = $NumberEffect/NumberEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func reload(ReloadLocation : Vector3 = Vector3(0, 30, 0)):
	await delete_collumn()
	Use = false
	canShake = true
	position = ReloadLocation
	NextCollumnAt = Global.DIRECTION.LEFT
	DistanceToNextCollumn = 0

func delete_collumn():
	var tween := create_tween().tween_property(rdMesh, "position", Vector3(0, -5, 0), 0.05)
	create_tween().tween_property(rdMesh, "scale", Vector3(0, 0, 0), 0.05)
	await tween.finished
	
func put_collumn():
	var tween := create_tween().tween_property(rdMesh, "position", Vector3.ZERO, 0.05)
	create_tween().tween_property(rdMesh, "scale", Vector3(1, 1, 1), 0.05)
	await tween.finished
	
func _on_goal_area_body_entered(body: Node3D) -> void:
	if Global.player.CountJump == 0 or Global.recentlyResumed: return
	if body is Player and canShake:
		Global.GoalScore += 1
		Global.CountTouchesCollumn += 1
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
	
func _show_number():
	if Global.player.CountJump == 0 or Global.recentlyResumed: return
	await Global.GettedScores
	rdNumberEffect.get_parent().position.x = randf_range(-1, 1)
	rdNumberEffect.get_parent().position.z = randf_range(-1, 1)
	rdLabel.text = "+" + str(1 + Global.GoalScore)
	rdNumberEffect.visible = true
	
	var number_tween : Tween = create_tween()
	number_tween.tween_method(_anim_number_effect_on, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await number_tween.finished
	await get_tree().create_timer(1).timeout
	
	number_tween = create_tween()
	number_tween.tween_method(_anim_number_effect_on, 1.0, 0.0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await number_tween.finished
	
	rdNumberEffect.visible = false
	
func _anim_number_effect_on(alpha : float):
	rdNumberEffect.scale = lerp(Vector3.ZERO, Vector3(1, 1, 1), alpha)
	rdNumberEffect.position = lerp(Vector3.ZERO, Vector3(0, 2, 0), alpha)
