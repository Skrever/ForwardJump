class_name Message
extends Control

@onready var rdLabel: Label = $TextureRect/Label
@onready var rdTextureRect: TextureRect = $TextureRect

func _ready() -> void:
	visible = false
	setInvisible()
	
var time_passed : float = 0
func _process(delta: float) -> void:
	if visible:
		time_passed += delta
		rdTextureRect.position.y = 39.0 + sin(time_passed) * 6.0

func setVisible(text : String):
	visible = true
	rdLabel.text = text
	
func setInvisible():
	visible = false
	rdLabel.text = ""
	
func changeText(text : String):
	if text.is_empty(): return
	setVisible(text)
