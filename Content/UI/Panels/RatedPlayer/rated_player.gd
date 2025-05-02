class_name RatedPlayer
extends Control

@onready var rdPanel: Panel = $Panel
@onready var rdAvatar: TextureRect = $Panel/Avatar
@onready var rdFrame: Panel = $Panel/Avatar/Frame
@onready var rdLabel: Label = $Panel/Label


func _ready() -> void:
	setInvisible()

func setVisible(value : Dictionary):
	visible = true
	var frameStyleBox : StyleBoxFlat = rdFrame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	match value["rank"]:
		"1": frameStyleBox.border_color = Color(0.82, 0.71, 0.00)
		"2": frameStyleBox.border_color = Color(0.56, 0.75, 0.76)
		"3": frameStyleBox.border_color = Color(0.82, 0.53, 0.47)
		"4": frameStyleBox.border_color = Color(0.60, 0.65, 0.48)
		_: frameStyleBox.border_color = Color(0.63, 0.50, 0.70)
		
	rdLabel.text = value["name"]
	
	rdFrame.add_theme_stylebox_override("panel", frameStyleBox)
	if value.has("img"):
		var avatar := Image.new()
		avatar.load_jpg_from_buffer(value["img"])
		print(value["name"]," - ", value["img"])
		rdAvatar.texture = ImageTexture.create_from_image(avatar)
	create_tween().tween_property(rdPanel, "scale", Vector2(1,1), 0.1)
	
		

func setInvisible():
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	visible = false
