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
	visible = true
	UI.focus = UI.FOCUS_IN.DEAD_MENU
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.1)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdRestartButton, "scale", Vector2(1, 1), 0.125)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.15)
	await get_tree().create_timer(0.1).timeout
	create_tween().tween_property(rdRewordedButton, "scale", Vector2(1, 1), 0.175)
	await get_tree().create_timer(0.175).timeout
	UI.DeadMenuOpened.emit()
	
	
func setInvisible():
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdRestartButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdRewordedButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	UI.focus = UI.FOCUS_IN.NONE
	UI.DeadMenuClosed.emit()
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func _on_no_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()
	Global.GameReload.emit()


func _on_restart_button_pressed() -> void:
	await setInvisible()
	Global.GameReload.emit()
	Global.GameStart.emit()
