extends CharacterBody3D

var move : bool = false
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
