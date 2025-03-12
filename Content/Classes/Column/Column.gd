class_name Collumn
extends StaticBody3D

var Use : bool = false
var NextCollumnAt : Global.DIRECTION = Global.DIRECTION.LEFT
var DistanceToNextCollumn : float = 0

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
	if body is Player:
		print("Player got goal!")
