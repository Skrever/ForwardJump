class_name DinamicFloor
extends StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player.MovingFinished.connect(_move)
	Global.GameReload.connect(func(): position = Vector3.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move():
	position = Global.player.position * Vector3(1,0,1)


func _on_area_body_entered(body: Node3D) -> void: 
	if body is Player:
		body.dead()
