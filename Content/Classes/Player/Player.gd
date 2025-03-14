class_name Player
extends CharacterBody3D

signal MovingStarted
signal MovingFinished

#Детект движения по экрану
var StartTouch
var RelativeTouch
var IsPressed : bool = false

#Сжатия игрока
@export_category("Player Settings")
@export var MinCompression : float = 0.3
@export var MaxCompression : float = 1
@export var JumpCurve : Curve
@export var MaxJump : float = 3
@export var JumpTime : float = 1
@export var MaxLengthTouch : float = 300

#Компоненты игрока
@onready var rdMesh : MeshInstance3D = $Collision/Root/Mesh
@onready var rdCheckFloor: RayCast3D = $Collision/CheckFloor
@onready var rdRoot: Node3D = $Collision/Root


var moving : bool = false
var flying : bool = false
var isDead : bool = false

var StartPosition : Vector3
var lastPosition : Vector3
var nextPosition : Vector3
var lastRotation : Vector3
var nexRotation : Vector3
var CompressinRatio : float = 1
var Floor : Node3D
var Force : float = 1.4

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self
	Global.GameReload.connect(_on_game_reload)
	StartPosition = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var time_passed : float = 0
func _physics_process(delta):

	if (!moving and !isDead):
		velocity.y = -500 * delta
		time_passed += delta
		var _tmp_scale : float = 1 +  sin(time_passed * 4) / 40
		rdRoot.scale = Vector3(_tmp_scale,_tmp_scale,_tmp_scale)
	
	move_and_slide()

func _input(event):
	
	if !moving and !isDead and (Floor != null):
			#Касание экрана
		if event is InputEventScreenTouch and event.is_pressed() and !IsPressed:
			StartTouch = event.position
			IsPressed = true
			

		#Конец касания экрана
		if event is InputEventScreenTouch and event.is_released() and IsPressed: 
			IsPressed = false
			create_tween().tween_property(self, "scale", Vector3(1, 1, 1), 0.05)
			if (CompressinRatio < 0.8) and (Floor is Collumn) and !isDead: 
				match Global.GameState:
					Global.GAMESTATS.NONE: 
						if UI.focus == UI.FOCUS_IN.MAIN_MENU:
							Global.GameStart.emit()
							move()
					Global.GAMESTATS.GOING: move()
				
		#Положение текущего касания
		if IsPressed :
			if event is not InputEventKey:
				RelativeTouch = event.position
				var alpha = -(StartTouch.y - RelativeTouch.y) / MaxLengthTouch
				if alpha > 1: alpha = 1
				elif alpha < -1 : alpha = -1
				scale.y = (1 - alpha) if MinCompression < (1 - alpha) else MinCompression
				if scale.y > MaxCompression:  scale.y = MaxCompression
				CompressinRatio = scale.y

func move():
	moving = true
	set_physics_process(false)
	MovingStarted.emit()
	lastPosition = position
	match Floor.NextCollumnAt:
		Global.DIRECTION.LEFT:
			nextPosition = position + Vector3(-Floor.DistanceToNextCollumn, 0, 0) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(180))
		Global.DIRECTION.FORWARD:
			nextPosition = position + Vector3(0, 0, -Floor.DistanceToNextCollumn) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(deg_to_rad(-180),0,0)
		Global.DIRECTION.RIGHT:
			nextPosition = position + Vector3(Floor.DistanceToNextCollumn, 0, 0) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(-180))
	lastRotation = rdMesh.rotation
	var movingTween := create_tween().tween_method(_curve_move, 0.0, 1.0, JumpTime * (1 - CompressinRatio))
	await movingTween.finished
	set_physics_process(true)
	MovingFinished.emit()
	CompressinRatio = 0
	moving = false
	
func _curve_move(alpha : float):
	position = lerp(lastPosition, nextPosition, alpha)
	position.y = lastPosition.y + JumpCurve.sample(alpha) * MaxJump * (1 - CompressinRatio)
	rdMesh.rotation = lerp(lastRotation, nexRotation, alpha)

func dead():
	isDead = true
	Global.GameStop.emit()

func _on_game_reload():
	position = StartPosition
	isDead = false


func _on_area_body_entered(body: Node3D) -> void:
	if body is Collumn:
		Floor = body
		if Global.GameState == Global.GAMESTATS.GOING:
			body._show_number()
			Global.CountTouchesCollumn += 1
			Global.PlayerOnCollumn.emit()
	else:
		Floor = null


func _on_area_body_exited(body: Node3D) -> void:
	if body is Collumn: Floor = null
