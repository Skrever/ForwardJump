extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.PlayerScoresChanged.connect(_text_changed)

func _text_changed(value):
	var tween := create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.075).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	text = str(value)
	tween = create_tween().tween_property(self, "scale", Vector2(1, 1), 0.07).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
