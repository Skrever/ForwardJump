extends Control

@onready var rdBackSidePanel: Panel = $SetterGroupBox/BackSidePanel
@onready var rdBackSideBestPanel: Panel = $SetterGroupBox/BackSideBistPanel
@onready var rdPanel: Panel = $NoBackSideModel/Panel
@onready var rdNoButton: Button = $NoBackSideModel/Panel/NoButton
@onready var rdVBoxContainer: VBoxContainer = $SetterGroupBox/BackSidePanel/Control/ScrollContainer/VBoxContainer

@export var Leaderboard : String

func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenLeaderboardMenu.connect(setVisible)
	UI.CloseLeaderboardMenu.connect(setInvisible)
	

func setVisible():
	
	UI.focus = UI.FOCUS_IN.LEADERBOARD_MENU
	
	if SDKBridge.leaderboard:
		for i in SDKBridge.leaderboard.keys():
			var leaderboardPanel : LeaderboardPanel = load(Leaderboard).instantiate()
			rdVBoxContainer.add_child(leaderboardPanel)
			var name_ := str(SDKBridge.leaderboard[i]["name"])
			if name_.is_empty():
				name_ = Language.local("noname")
			leaderboardPanel.setLeaderBoard(i, name_, SDKBridge.leaderboard[i]["score"], SDKBridge.leaderboard[i]["usr"])
	
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdBackSideBestPanel, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.25)
	await get_tree().create_timer(0.25).timeout
	UI.LeaderboardMenuOpened.emit()
	
	
func setInvisible():
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdBackSideBestPanel, "scale", Vector2.ZERO, 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.25)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	
	for i in rdVBoxContainer.get_children():
		i.queue_free()
	
	UI.focus = UI.FOCUS_IN.NONE
	UI.LeaderboardMenuClosed.emit()
	
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_no_button_pressed() -> void:
	
	await setInvisible()
	UI.OpenMainMenu.emit()
	
	if !Global.UserKnowHowToPlay:
		UI.OpenLearningMenu.emit()
	
	SDKBridge.ShowAdd()
