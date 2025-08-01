extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var sound := AudioStreamPlayer.new()
	sound.volume_db = -40 + Global.Sounds
	sound.stream = load("uid://ck11eu7ldtrb6")
	add_child(sound)
	sound.play()
	sound.finished.connect(func() : sound.queue_free())


func _on_button_up() -> void:
	scale = Vector2(1, 1)
	Global.ButtonPressed = false
	focus_mode = FocusMode.FOCUS_NONE

func _on_button_down() -> void:
	scale = Vector2(0.95, 0.95)
	Global.ButtonPressed = true

func _on_focus_entered() -> void:
	Global.ButtonPressed = true
