extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str(Global.PlayerLevel)
	Global.PlayerLevelChanged.connect(func(x) : text = str(x))
