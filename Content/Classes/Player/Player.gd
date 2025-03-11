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
var lastPosition : Vector3
var nextPosition : Vector3
var lastRotation : Vector3
var nexRotation : Vector3
var CompressinRatio : float = 1
var BottomColumn : Collumn
var Force : float = 1.4

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#print(BottomColumn)

func _physics_process(delta):
	if (!is_on_floor() and !moving):
		velocity.y = -10
	move_and_slide()

func _input(event):
	
		#Касание экрана
	if event is InputEventScreenTouch and event.is_pressed():
		StartTouch = event.position
		IsPressed = true
		
	#Конец касания экрана
	if event is InputEventScreenTouch and event.is_released(): 
		IsPressed = false
		create_tween().tween_property(self, "scale", Vector3(1, 1, 1), 0.05)
		if CompressinRatio < 0.8 and BottomColumn != null: move()
			
	#Положение текущего касания
	if IsPressed : #and (scale.y <= 1) and (scale.y >= 0.3):
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
	MovingStarted.emit()
	lastPosition = position
	match BottomColumn.NextCollumnAt:
		Global.DIRECTION.LEFT:
			nextPosition = position + Vector3(-Global.Distance, 0, 0) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(180))
		Global.DIRECTION.FORWARD:
			nextPosition = position + Vector3(0, 0, -Global.Distance) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(deg_to_rad(-180),0,0)
		Global.DIRECTION.RIGHT:
			nextPosition = position + Vector3(Global.Distance, 0, 0) * (Force - CompressinRatio)
			nexRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(-180))
	lastRotation = rdMesh.rotation
	var movingTween := create_tween().tween_method(_curve_move, 0.0, 1.0, JumpTime * (1 - CompressinRatio))
	await movingTween.finished
	moving = false
	MovingFinished.emit()
	
func _curve_move(alpha : float):
	position = lerp(lastPosition, nextPosition, alpha)
	position.y = lastPosition.y + JumpCurve.sample(alpha) * MaxJump * (1 - CompressinRatio)
	rdMesh.rotation = lerp(lastRotation, nexRotation, alpha)


func _on_checker_body_entered(body: Node3D) -> void:
	if body is Collumn:
		BottomColumn = body
		


func _on_checker_body_exited(body: Node3D) -> void:
	if body is Collumn:
		BottomColumn = null
