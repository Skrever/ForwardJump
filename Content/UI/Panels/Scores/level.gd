extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.PlayerScoresChanged.connect(func(x) : text = str(x))
