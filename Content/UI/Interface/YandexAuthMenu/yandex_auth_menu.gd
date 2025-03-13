extends Control

@onready var rdBlur: ColorRect = $blur
@onready var rdPanel: Panel = $ConfirmationPanel/Panel
@onready var rdNoButton: Button = $ConfirmationPanel/NoButton
@onready var rdYesButton: Button = $ConfirmationPanel/YesButton
@onready var rdBackSidePanel: Panel = $MessageGroupBox/BackSidePanel
@onready var rdMessage: Panel = $MessageGroupBox/BackSidePanel/Message

func _ready() -> void:
	visible = false
	setInvisible()
	Global.AuthorizePlayer.connect(setVisible)

func setVisible():
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdBlur.material, "shader_parameter/value", 0.5, 0.3)
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdMessage, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.25)
	create_tween().tween_property(rdYesButton, "scale", Vector2(1, 1), 0.3)
	
func setInvisible():
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdMessage, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdYesButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdBlur.material, "shader_parameter/value", 0, 0.2)
	await get_tree().create_timer(0.2).timeout
	visible = false
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_no_button_pressed() -> void:
	await setInvisible()
	Global.MainMenuOpen.emit()


func _on_yes_button_pressed() -> void:
	await SdkBridge.authUser()
	await setInvisible()
	Global.MainMenuOpen.emit()
