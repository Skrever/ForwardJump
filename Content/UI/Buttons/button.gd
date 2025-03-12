extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var sound := AudioStreamPlayer.new()
	#sound.volume_db = -40 + Global.Sounds
	#sound.stream = load("res://Content/Music/Sounds/UI/ButtonSound.wav")
	add_child(sound)
	sound.play()
	sound.finished.connect(func() : sound.queue_free())
