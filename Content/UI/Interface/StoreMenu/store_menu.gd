extends Control

@onready var rdBacksidePanel: Panel = $GroupBox/BackSidePanel
@onready var rdNoButton: Button = $GroupBox/NoButton
@onready var rdYesButton: Button = $GroupBox/YesButton
@onready var rdGemsPanel: Panel = $GemsGroupBox/GemsPanel
@onready var rdArrowButtonRight: Button = $ArrowsGroupBox/ArrowButtonRight
@onready var rdArrowButtonLeft: Button = $ArrowsGroupBox/ArrowButtonLeft


var CurrentIndexOfSkins : int = Global.TakedSkin
var SkinsKeys : Array

func _ready() -> void:
	SkinsKeys = Global.SkinsDict.keys()
	visible = false
	setInvisible()
	UI.OpenStoreMenu.connect(setVisible)
	UI.CloseStoreMenu.connect(setInvisible)


func setVisible():
	visible = true
	UI.focus = UI.FOCUS_IN.STORE_MENU
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdArrowButtonLeft, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdArrowButtonLeft, "position", Vector2(-177.5, -27.5), 0.1)
	
	create_tween().tween_property(rdArrowButtonRight, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdArrowButtonRight, "position", Vector2(122.5, -27.5), 0.1)
	
	create_tween().tween_property(rdGemsPanel, "position", Vector2(-39, 30), 0.1)
	var BacksidePanel := create_tween().tween_property(rdBacksidePanel, "scale", Vector2(1, 1), 0.1)
	await BacksidePanel.finished
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdYesButton, "scale", Vector2(1, 1), 0.1)
	
	await get_tree().create_timer(0.1).timeout
	UI.StoreMenuOpened.emit()

func setInvisible():
	
	create_tween().tween_property(rdArrowButtonLeft, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdArrowButtonLeft, "position", Vector2(-27.5, -27.5), 0.1)
	
	create_tween().tween_property(rdArrowButtonRight, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdArrowButtonRight, "position", Vector2(-27.5, -27.5), 0.1)
	
	create_tween().tween_property(rdGemsPanel, "position", Vector2(-39, -60), 0.1)
	create_tween().tween_property(rdBacksidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdYesButton, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	UI.focus = UI.FOCUS_IN.NONE
	UI.StoreMenuClosed.emit()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_yes_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()


func _on_no_button_pressed() -> void:
	await setInvisible()
	UI.OpenMainMenu.emit()


func _on_arrow_button_right_pressed() -> void:
	CurrentIndexOfSkins = (CurrentIndexOfSkins + 1) if CurrentIndexOfSkins < (SkinsKeys.size() - 1) else 0
	Global.ChangePlayerSkin.emit(CurrentIndexOfSkins)
	print(CurrentIndexOfSkins)

func _on_arrow_button_left_pressed() -> void:
	CurrentIndexOfSkins = (CurrentIndexOfSkins - 1) if CurrentIndexOfSkins > 0 else SkinsKeys.size() - 1
	Global.ChangePlayerSkin.emit(CurrentIndexOfSkins)
	print(CurrentIndexOfSkins)
