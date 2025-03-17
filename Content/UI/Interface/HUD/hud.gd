extends Control

@onready var rdPauseButton: Button = $GroupBox/PauseButton
@onready var rdScorePanel: Panel = $GroupBox/Panel/ScorePanel
@onready var rdPanel: Panel = $GroupBox/Panel


func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenHUD.connect(setVisible)
	UI.CloseHUD.connect(setInvisible)


func setVisible():
	
	if UI.focus == UI.FOCUS_IN.MAIN_MENU: await UI.MainMenuClosed
	#if UI.focus != UI.FOCUS_IN.GAME: await UI.HUDClosed
	if UI.focus == UI.FOCUS_IN.DEAD_MENU: await UI.DeadMenuClosed
	if UI.focus == UI.FOCUS_IN.PAUSE_MENU: await UI.PauseMenuClosed
	if UI.focus == UI.FOCUS_IN.SETTINGS_MENU: await UI.SettingsMenuClosed
	if UI.focus == UI.FOCUS_IN.LEADERBOARD_MENU: await UI.LeaderboardMenuClosed

	visible = true
	UI.focus = UI.FOCUS_IN.GAME
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdPauseButton, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdScorePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.1)

	await get_tree().create_timer(0.3).timeout
	UI.HUDOpened.emit()

func setInvisible():

	create_tween().tween_property(rdPauseButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdScorePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	
	await get_tree().create_timer(0.1).timeout
	visible = false
	
	UI.focus = UI.FOCUS_IN.NONE
	UI.HUDClosed.emit()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_pause_button_pressed() -> void:
	await setInvisible()
	Global.GamePaused.emit()
