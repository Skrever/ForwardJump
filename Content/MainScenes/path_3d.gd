extends Path3D

@onready var rdSlide : PathFollow3D = $Slide
var t := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	
func _activate(body : Node3D):
	print("234")
	rdSlide.add_child(body)
	print("Children of Curve: ",rdSlide.get_children())
	create_tween().tween_property(rdSlide, "progress_ratio", 1.0, 0.2)
	add_sibling(body)
	#rdSlide.progress_ratio = 0;
