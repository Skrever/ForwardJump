extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.PlayerScoresChanged.connect(_cut_text_label)

func _cut_text_label(score : int) -> void:
	text = str(score)
