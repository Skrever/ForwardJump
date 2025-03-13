extends Control

@onready var rdBackSidePanel: Panel = $SettingsMenuGroupBox/BackSidePanel
@onready var rdNoButton: Button = $SettingsMenuGroupBox/NoButton
@onready var rdYesButton: Button = $SettingsMenuGroupBox/YesButton
@onready var rdSoundsPanel: SoundsPanel = $SettingsMenuGroupBox/SoundsPanel
@onready var rdMusicPanel: MusicPanel = $SettingsMenuGroupBox/MusicPanel

func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenSettingsMenu.connect(setVisible)
	UI.CloseSettingsMenu.connect(setInvisible)


func setVisible():
	
	rdMusicPanel.resetMusic()
	rdSoundsPanel.resetSounds()
	
	visible = true
	UI.focus = UI.FOCUS_IN.SETTINGS_MENU
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdMusicPanel, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdSoundsPanel, "scale", Vector2(1, 1), 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.25)
	create_tween().tween_property(rdYesButton, "scale", Vector2(1, 1), 0.3)
	await get_tree().create_timer(0.3).timeout
	UI.SettingsMenuOpened.emit()

func setInvisible():
	create_tween().tween_property(rdMusicPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdSoundsPanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdYesButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	visible = false
	
	UI.focus = UI.FOCUS_IN.NONE
	UI.SettingsMenuClosed.emit()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_no_button_pressed() -> void:
	Global.SetMusicVolume.emit(float(Global.Music))
	rdMusicPanel.resetMusic()
	await setInvisible()
	
	if Global.GameState == Global.GAMESTATS.PAUSED:
		UI.OpenPauseMenu.emit()
	else:
		UI.OpenMainMenu.emit()
	SDKBridge.ShowAdd()

func _on_yes_button_pressed() -> void:
	Global.Music = rdMusicPanel.getNewMusic()
	Global.Sounds = rdSoundsPanel.getNewSounds()
	await setInvisible()
	
	if Global.GameState == Global.GAMESTATS.PAUSED:
		UI.OpenPauseMenu.emit()
	else:
		UI.OpenMainMenu.emit()
