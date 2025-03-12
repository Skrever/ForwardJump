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
  
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# "Догоняем" объект
	#if Global.GameState == Global.GAMESTATS.GOING:
	position = position.lerp(tracking_object.position, delta * speed_tracking)
