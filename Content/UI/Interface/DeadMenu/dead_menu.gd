extends Control


@onready var rdPanel: Panel = $GroupBox/Panel
@onready var rdRestartButton: Button = $GroupBox/Panel/RestartButton
@onready var rdNoButton: Button = $GroupBox/Panel/NoButton
@onready var rdRewordedButton: Button = $GroupBox/Panel/RewordedButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenDeadMenu.connect(setVisible)
	UI.CloseDeadMenu.connect(setInvisible)

func setVisible():
	
	if UI.focus == UI.FOCUS_IN.MAIN_MENU: await UI.MainMenuClosed
	if UI.focus == UI.FOCUS_IN.GAME: await UI.HUDClosed
	if UI.focus == UI.FOCUS_IN.PAUSE_MENU: await UI.PauseMenuClosed
	if UI.focus == UI.FOCUS_IN.SETTINGS_MENU: await UI.SettingsMenuClosed
	if UI.focus == UI.FOCUS_IN.LEADERBOARD_MENU: await UI.LeaderboardMenuClosed
	
	
	UI.focus = UI.FOCUS_IN.DEAD_MENU
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	if Global.CurTimesGameResumed < Global.MaxTimesGameResumed:
		rdRewordedButton.visible = true
		rdPanel.size = Vector2(220, 220)
		rdPanel.position = Vector2.ZERO
	else:
		rdRewordedButton.visible = false
		rdPanel.size = Vector2(220, 114)
		rdPanel.position = Vector2(0, 55)
		
	
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.1)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdRestartButton, "scale", Vector2(1, 1), 0.125)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.15)
	await get_tree().create_timer(0.1).timeout
	
	if Global.CurTimesGameResumed < Global.MaxTimesGameResumed:
		create_tween().tween_property(rdRewordedButton, "scale", Vector2(1, 1), 0.175)
		await get_tree().create_timer(0.175).timeout
		
	UI.DeadMenuOpened.emit()
	
	
func setInvisible():
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdRestartButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdRewordedButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	UI.focus = UI.FOCUS_IN.NONE
	UI.DeadMenuClosed.emit()


func _on_no_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()
	Global.GameReload.emit()


func _on_restart_button_pressed() -> void:
	await setInvisible()
	Global.GameReload.emit()
	Global.GameStart.emit()


func _on_reworded_button_pressed() -> void:
	SDKBridge.ShowRewordedAdd()
	await SDKBridge.RewardedAdShowed
	if SDKBridge.canReward:
		await setInvisible()
		Global.GameResumed.emit()
	
