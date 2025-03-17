extends Control

@onready var rdBackSidePanel: Panel = $PauseGroupBox/BackSidePanel
@onready var rdNoButton: Button = $PauseGroupBox/NoButton
@onready var rdRestartButton: Button = $PauseGroupBox/RestartButton
@onready var rdSettingsButton: Button = $PauseGroupBox/SettingsButton



func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenPauseMenu.connect(setVisible)
	UI.ClosePauseMenu.connect(setInvisible)

func setVisible():
	
	if UI.focus == UI.FOCUS_IN.MAIN_MENU: await UI.MainMenuClosed
	if UI.focus == UI.FOCUS_IN.GAME: await UI.HUDClosed
	if UI.focus == UI.FOCUS_IN.DEAD_MENU: await UI.DeadMenuClosed
	#if UI.focus == UI.FOCUS_IN.PAUSE_MENU: await UI.PauseMenuClosed
	if UI.focus == UI.FOCUS_IN.SETTINGS_MENU: await UI.SettingsMenuClosed
	if UI.focus == UI.FOCUS_IN.LEADERBOARD_MENU: await UI.LeaderboardMenuClosed
	
	
	UI.focus = UI.FOCUS_IN.PAUSE_MENU
	print("Paused Menu")
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdRestartButton, "scale", Vector2(1, 1), 0.125)
	create_tween().tween_property(rdSettingsButton, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.175)
	await get_tree().create_timer(0.175).timeout
	UI.PauseMenuOpened.emit()

func setInvisible():
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdRestartButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdSettingsButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	visible = false
	UI.focus = UI.FOCUS_IN.NONE
	UI.PauseMenuClosed.emit()


func _on_next_button_pressed() -> void:
	await setInvisible()
	Global.GameContinued.emit()


func _on_no_button_pressed() -> void:
	SDKBridge.ShowAdd()
	await setInvisible()
	Global.GameReload.emit()
	UI.OpenMainMenu.emit()


func _on_settings_button_pressed() -> void:
	await setInvisible()
	UI.OpenSettingsMenu.emit()
