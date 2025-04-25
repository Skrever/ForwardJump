extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.PlayerScoresChanged.connect(_text_changed)

func _text_changed(value):
	var tween := create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.075).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if int(value) >= 1000 and int(value) < 10000:
		text = str(float((int(value) / 10) * 10) / 1000.0) + "K"
		add_theme_font_size_override("font_size", 32)
	elif int(value) >= 10000:
		text = str(float((int(value) / 10) * 10) / 1000.0) + "K"
		add_theme_font_size_override("font_size", 30)
	else:
		text = str(value)
		add_theme_font_size_override("font_size", 35)
	if int(value > 100000): text = "(-_-)"
	tween = create_tween().tween_property(self, "scale", Vector2(1, 1), 0.07).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
