extends Control

@onready var rdPanel: Panel = $ConfirmationPanel/Panel
@onready var rdNoButton: Button = $ConfirmationPanel/NoButton
@onready var rdYesButton: Button = $ConfirmationPanel/YesButton
@onready var rdBackSidePanel: Panel = $MessageGroupBox/BackSidePanel
@onready var rdMessage: Panel = $MessageGroupBox/BackSidePanel/Message

func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenAuthMenu.connect(setVisible)
	UI.CloseAuthMenu.connect(setInvisible)

func setVisible():
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	UI.focus = UI.FOCUS_IN.AUTH_MENU
	
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdMessage, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.25)
	create_tween().tween_property(rdYesButton, "scale", Vector2(1, 1), 0.3)
	await get_tree().create_timer(0.3).timeout
	UI.AuthMenuOpened.emit()
	
func setInvisible():
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdMessage, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdYesButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.2).timeout
	visible = false
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS
	UI.focus = UI.FOCUS_IN.NONE
	UI.AuthMenuClosed.emit()


func _on_no_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()
	UI.OpenLearningMenu.emit()


func _on_yes_button_pressed() -> void:
	SDKBridge.authUser()
	
	await setInvisible()
	UI.OpenMainMenu.emit()
	UI.OpenLearningMenu.emit()
