class_name Collumn
extends StaticBody3D

enum FORM
{
	SQUARE,
	CIRCLE
}

var form : FORM = FORM.SQUARE

func string_to_enum_form(str: String) -> FORM: 
	match str:
		"circle": return FORM.CIRCLE
		_: return FORM.SQUARE
		
var Use : bool = false
var NextCollumnAt : Global.DIRECTION = Global.DIRECTION.LEFT
var DistanceToNextCollumn : float = 0

var shakeX : float = randf_range(0.1,0.15)
var shakeZ : float = randf_range(0.1,0.15)

var canShake : bool = true

@onready var rdGoalEffect: Node3D = $GoalEffect
@onready var rdCircleGoalEffect: Node3D = $CircleGoalEffect

@onready var rdMesh: CollumnSkin
@onready var rdLabel: Label = $NumberEffect/NumberEffect/SubViewport/Label
@onready var rdNumberEffect: Sprite3D = $NumberEffect/NumberEffect
@onready var rdRoot: Node3D = $Root
@onready var rdCollision: CollisionShape3D = $Collision

@onready var rdCombo: AudioStreamPlayer = $Combo
@onready var rdCombo1: AudioStreamPlayer = $Combo1
@onready var rdCombo2: AudioStreamPlayer = $Combo2
@onready var rdCombo3: AudioStreamPlayer = $Combo3

@onready var rdParticles: CPUParticles3D = $Particles/PartyFace

@onready var rdParticles1: CPUParticles3D = $Particles/StarsFace
@onready var rdParticles1_1: CPUParticles3D = $Particles/SmileFace

@onready var rdParticles2: CPUParticles3D = $Particles/HeartsFace
@onready var rdParticles2_1: CPUParticles3D = $Particles/WowFace

@onready var rdParticles3: CPUParticles3D = $Particles/FearFace
@onready var rdParticles3_1: CPUParticles3D = $Particles/ExploutionFace
@onready var rdParticles3_2: CPUParticles3D = $Particles/Steam

@onready var rdRatedPlayer: RatedPlayer = $Rating/SubViewport/RatedPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	setSkin(true)
	

func setSkin(rand : bool):
	if rand:
		var key : String = Global.CollumnsSkinsDict.keys()[randi_range(0, Global.CollumnsSkinsDict.keys().size() - 1)]
		print(key)
		rdMesh = load(Global.get_collumn_skin_by_key(key)["scene"]).instantiate()
		form = string_to_enum_form(Global.get_collumn_skin_by_key(key)["form"])
	else:
		rdMesh = load(Global.get_collumn_skin_by_key("default")["scene"]).instantiate()
		form = string_to_enum_form(Global.get_collumn_skin_by_key("default")["form"])
	var _collisionShape : Shape3D
	match form:
		FORM.SQUARE:
			_collisionShape = BoxShape3D.new()
			_collisionShape.size = Vector3(3, 4.018, 3)
			#print("Collision is box")
		FORM.CIRCLE:
			_collisionShape = CylinderShape3D.new()
			_collisionShape.height = 4.018
			_collisionShape.radius = 1.5
			#print("Collision is cylinder")
	rdCollision.shape = _collisionShape
	rdRoot.add_child(rdMesh)
	
func reload(ReloadLocation : Vector3 = Vector3(0, 30, 0)):
	await delete_collumn()
	Use = false
	canShake = true
	position = ReloadLocation
	NextCollumnAt = Global.DIRECTION.LEFT
	DistanceToNextCollumn = 0

func delete_collumn():
	rdRatedPlayer.setInvisible()
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
				
		match Global.GoalScore:
			0:
				rdCombo.volume_db = -40 + Global.Sounds
				rdCombo.play()
				rdParticles.emitting = true
			1:
				rdCombo1.volume_db = -40 + Global.Sounds
				rdCombo1.play()
				rdParticles1.emitting = true
				rdParticles1_1.emitting = true
			2:
				rdCombo2.volume_db = -40 + Global.Sounds
				rdCombo2.play()
				rdParticles2.emitting = true
				rdParticles2_1.emitting = true
			_:
				rdCombo3.volume_db = -40 + Global.Sounds
				rdCombo3.play()
				match randi_range(1,3):
					1: rdParticles1.emitting = true
					2: 
						rdParticles2.emitting = true
						rdParticles3_2.emitting = true
					3: 
						rdParticles3.emitting = true
						rdParticles3_1.emitting = true
		rdMesh.double_shake()
		match form:
			FORM.SQUARE:
				for i in range(0, rdGoalEffect.get_children().size()):
					rdGoalEffect.get_children()[i].setVisible()
					await get_tree().create_timer(0.1).timeout
				for i in range(0, rdGoalEffect.get_children().size()):
					rdGoalEffect.get_children()[i].setInvisible()
			FORM.CIRCLE:
				for i in range(0, rdCircleGoalEffect.get_children().size()):
					rdCircleGoalEffect.get_children()[i].setVisible()
					await get_tree().create_timer(0.1).timeout
				for i in range(0, rdCircleGoalEffect.get_children().size()):
					rdCircleGoalEffect.get_children()[i].setInvisible()
			
			#rdGoalEffect.get_children()[i].visible = false

func _vertical_shake():
	rdMesh.double_shake()
	#var tween := create_tween().tween_property(rdMesh, "position", Vector3(0,-0.2, 0), 0.1)
	#await tween.finished
	#create_tween().tween_property(rdMesh, "position", Vector3(0, 0, 0), 0.1)

func _show_number():
	if Global.player.CountJump == 0 or Global.recentlyResumed: return
	await Global.GettedScores
	if Global.player.Floor != self : return
	
	for i in range(Global.lastShownRank):
		if i + 1 > SDKBridge.leaderboard.keys().size() : break
		if (Global.Score >= int(SDKBridge.leaderboard[SDKBridge.leaderboard.keys()[i]]["score"])):
			var generator : Generator = get_tree().get_first_node_in_group("Generator")
			generator.Collumns[generator.Collumns.find(self) - 2].rdRatedPlayer.setVisible(SDKBridge.leaderboard[SDKBridge.leaderboard.keys()[i]])
			Global.lastShownRank = i
			break
	
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
	rdLabel.text = " "
	
func _anim_number_effect_on(alpha : float):
	rdNumberEffect.scale = lerp(Vector3.ZERO, Vector3(1, 1, 1), alpha)
	rdNumberEffect.position = lerp(Vector3.ZERO, Vector3(0, 2, 0), alpha)

func emitParticles(pos_ : Vector3):
	pos_.y /= 2.0
	rdMesh.emitParticles(pos_ - Vector3(0, 0.2, 0))
