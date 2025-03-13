extends Control

@onready var rdPauseButton: Button = $GroupBox/PauseButton
@onready var rdScorePanel: Panel = $GroupBox/ScorePanel


func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenHUD.connect(setVisible)
	UI.CloseHUD.connect(setInvisible)


func setVisible():
	
	visible = true
	UI.focus = UI.FOCUS_IN.GAME
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdPauseButton, "position", Vector2(216, 27), 0.1)
	create_tween().tween_property(rdScorePanel, "position", Vector2(350, 27), 0.1)

	await get_tree().create_timer(0.3).timeout
	UI.HUDOpened.emit()

func setInvisible():

	create_tween().tween_property(rdPauseButton, "position", Vector2(216, -56), 0.1)
	create_tween().tween_property(rdScorePanel, "position", Vector2(450, -56), 0.1)
	await get_tree().create_timer(0.1).timeout
	visible = false
	
	UI.focus = UI.FOCUS_IN.NONE
	UI.HUDClosed.emit()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_pause_button_pressed() -> void:
	await setInvisible()
	Global.GamePaused.emit()
