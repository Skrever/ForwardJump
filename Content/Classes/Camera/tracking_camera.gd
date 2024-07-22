extends Node3D

#----------------------------------------------------------------
#	---Объект, за которым надо следить---
@export_category("Tracking")

 # Ссылка на игрока(моба и тд.)
@export var tracking_object : Node3D

#----------------------------------------------------------------
#	---Настройки камеры в инспекторе---
@export_category("Camera Advanced Settings")

# Скорость догонки камеры
@export var speed_tracking : float = 5

# Чувствительность вращения камеры
@export var speed_mouse_move : float = 1 

#----------------------------------------------------------------

#	---Переменные в этом классе---

# Движется объект или нет
var is_tracking_object_moving : bool = false

#----------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if tracking_object.get_last_motion().length():
		is_tracking_object_moving = true
	else:
		is_tracking_object_moving = false
	
	# "Догоняем" объект
	position = position.lerp(tracking_object.position, delta * speed_tracking)
	
# Функция обработки вращения вокруг требуемого объекта
func _input(event):
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, -event.relative.x * 0.001 * speed_mouse_move)
