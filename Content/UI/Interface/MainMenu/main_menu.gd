extends Control


@onready var rdPanel: Panel = $GroupBox/Panel
@onready var rdCrownButton: Button = $GroupBox/Panel/CrownButton
@onready var rdSettingsButton: Button = $GroupBox/Panel/SettingsButton
@onready var rdStoreButton: Button = $GroupBox/Panel/StoreButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenMainMenu.connect(setVisible)
	UI.CloseMainMenu.connect(setInvisible)

func setVisible():
	
	if UI.focus != UI.FOCUS_IN.NONE: return
	
	visible = true
	UI.focus = UI.FOCUS_IN.MAIN_MENU
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	create_tween().tween_property(rdPanel, "position", Vector2(0, 0), 0.1)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdStoreButton, "scale", Vector2(1, 1), 0.15)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdSettingsButton, "scale", Vector2(1, 1), 0.2)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdCrownButton, "scale", Vector2(1, 1), 0.25)
	await get_tree().create_timer(0.25).timeout
	UI.MainMenuOpened.emit()
	
	
func setInvisible():
	create_tween().tween_property(rdPanel, "position", Vector2(0, 200), 0.1)
	create_tween().tween_property(rdStoreButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdSettingsButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdCrownButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	UI.focus = UI.FOCUS_IN.NONE
	UI.MainMenuClosed.emit()
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func _on_settings_button_pressed() -> void:
	await setInvisible()
	UI.CloseLearningMenu.emit()
	UI.OpenSettingsMenu.emit()


func _on_crown_button_pressed() -> void:
	await setInvisible()
	UI.CloseLearningMenu.emit()
	UI.OpenLeaderboardMenu.emit()
