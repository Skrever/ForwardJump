extends CharacterBody3D

#Детект движения по экрану
var StartTouch
var RelativeTouch
var IsPressed : bool = false

#Сжатия игрока
@export_category("Player Settings")
@export var MaxCompression : float = 400
var CurrentCompression : float = 1

#Компоненты игрока
@onready var MeshInstance : MeshInstance3D = get_node("Collision/Mesh")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if (!is_on_floor()):
		velocity.y = -10
	move_and_slide()

func _input(event):
	#Касание экрана
	if event is InputEventScreenTouch and event.is_pressed():
		StartTouch = event.position
		IsPressed = true
		print(StartTouch)
		
	#Конец касания экрана
	if event is InputEventScreenTouch and event.is_released():
		IsPressed = false
		scale.y = 1
		print("Realese")
		
	#Положение текущего касания
	if IsPressed and (scale.y <= 1) and (scale.y >= 0.1):
		RelativeTouch = event.position
		CurrentCompression = abs((StartTouch.y - RelativeTouch.y)) / 30
		print(CurrentCompression/MaxCompression)
		
		scale.y = (scale.y - (CurrentCompression/MaxCompression))

			
