extends Control
@onready var rdBackSidePanel: Panel = $SetterGroupBox/BackSidePanel
@onready var rdNoBackSideModel: Control = $NoBackSideModel/Panel

func _ready() -> void:
	visible = false
	setInvisible()
	#if SdkBridge.device == "mobile":
		#DisplayServer.window_set_input_text_callback(_on_line_edit_text_changed)
	UI.OpenAboutDeveloper.connect(setVisible)
	UI.CloseAboutDeveloper.connect(setInvisible)

func setVisible():
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	UI.focus = UI.FOCUS_IN.ABOUT_DEVELOPER
	
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1,1), 0.1)
	create_tween().tween_property(rdNoBackSideModel, "scale", Vector2(1,1), 0.2)
	await get_tree().create_timer(0.1).timeout
	UI.AboutDeveloperOpened.emit()
	
func setInvisible():
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoBackSideModel, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS
	UI.focus = UI.FOCUS_IN.NONE
	UI.AboutDeveloperClosed.emit()

func _on_no_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()
