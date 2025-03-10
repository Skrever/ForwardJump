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
@export var MaxCompression : float = 400
var CurrentCompression : float = 1
@export var JumpCurve : Curve
@export var MaxJump : float = 3
@export var JumpTime : float = 1

#Компоненты игрока
@onready var MeshInstance : MeshInstance3D = $Collision/Mesh


var moving : bool = false
var lastPosition : Vector3
var nextPosition : Vector3
var CompressinRatio : float

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if (!is_on_floor() and !moving):
		velocity.y = -10
	move_and_slide()

func _input(event):
	if !moving:
		#Касание экрана
		if event is InputEventScreenTouch and event.is_pressed():
			StartTouch = event.position
			IsPressed = true
			
		#Конец касания экрана
		if event is InputEventScreenTouch and event.is_released(): 
			IsPressed = false
			create_tween().tween_property(self, "scale", Vector3(1, 1, 1), 0.05)
			print("CompressinRatio: ", CompressinRatio)
			if CompressinRatio < 0.7: move()
			
		#Положение текущего касания
		if IsPressed and (scale.y <= 1) and (scale.y >= 0.3):
			RelativeTouch = event.position
			CurrentCompression = abs((StartTouch.y - RelativeTouch.y)) / 30
			scale.y = (scale.y - (CurrentCompression/MaxCompression))
			CompressinRatio = scale.y

func move():
	moving = true
	MovingStarted.emit()
	lastPosition = position
	match Global.Direction:
		Global.DIRECTION.LEFT:
			nextPosition = position + Vector3(-Global.Distance, 0, 0)
		Global.DIRECTION.RIGHT:
			nextPosition = position + Vector3(Global.Distance, 0, 0)
		Global.DIRECTION.FORWARD:
			nextPosition = position + Vector3(0, 0, -Global.Distance)
	#nextPosition *= (1.3 - CompressinRatio)
	var movingTween := create_tween().tween_method(_curve_move, 0.0, 1.0, JumpTime * (1 - CompressinRatio))
	await movingTween.finished
	
	moving = false
	MovingFinished.emit()
	
func _curve_move(alpha : float):
	position = lerp(lastPosition, nextPosition, alpha)
	position.y = lastPosition.y + JumpCurve.sample(alpha) * MaxJump * (1 - CompressinRatio)
	MeshInstance.rotation.z = deg_to_rad(lerp(0, 360, alpha))
