extends Control


@onready var rdPanel: Panel = $GroupBox/Panel
@onready var rdCrownButton: Button = $GroupBox/Panel/CrownButton
@onready var rdSettingsButton: Button = $GroupBox/Panel/SettingsButton
@onready var rdStoreButton: Button = $GroupBox/Panel/StoreButton
@onready var rdDevPanel: Panel = $GroupBoxAboutDeveloper/DevPanel
@onready var rdTelegramButton: TextureButton = $GroupBoxAboutDeveloper/DevPanel/TelegramButton


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
	
	create_tween().tween_property(rdDevPanel, "position", Vector2(15, 5), 0.1)
	create_tween().tween_property(rdDevPanel, "scale", Vector2(1, 1), 0.1)
	
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
	create_tween().tween_property(rdDevPanel, "position", Vector2(15, -90), 0.1)
	create_tween().tween_property(rdDevPanel, "scale", Vector2.ZERO, 0.1)
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


func _on_store_button_pressed() -> void:
	await setInvisible()
	UI.CloseLearningMenu.emit()
	UI.OpenStoreMenu.emit()


func _on_telegram_button_button_down() -> void:
	rdTelegramButton.scale = Vector2(0.9, 0.9)


func _on_telegram_button_button_up() -> void:
	rdTelegramButton.scale = Vector2(1, 1)


func _on_telegram_button_pressed() -> void:
	OS.shell_open("https://t.me/LittleDevelopersDiary_and_YG")


func _on_about_dev_pressed() -> void:
	await setInvisible()
	UI.OpenAboutDeveloper.emit()
	UI.CloseLearningMenu.emit()
