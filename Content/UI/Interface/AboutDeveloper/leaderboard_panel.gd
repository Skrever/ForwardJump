extends Control

@onready var rdBackSidePanel: Panel = $SetterGroupBox/BackSidePanel
@onready var rdBackSideBestPanel: Panel = $SetterGroupBox/BackSideBistPanel
@onready var rdPanel: Panel = $NoBackSideModel/Panel
@onready var rdNoButton: Button = $NoBackSideModel/Panel/NoButton
@onready var rdVBoxContainer: VBoxContainer = $SetterGroupBox/BackSidePanel/Control/ScrollContainer/VBoxContainer


func _ready() -> void:
	visible = false
	setInvisible()
	Global.LeaderBoardMenuOpen.connect(setVisible)
	

func setVisible():
	for i in rdVBoxContainer.get_children():
		i.queue_free()
		
	if SdkBridge.leaderboard:
		for i in SdkBridge.leaderboard.keys():
			var leaderboardPanel : LeaderboardPanel = load("res://Content/UI/Panels/Leaderboard/LeaderboardPanel.tscn").instantiate()
			rdVBoxContainer.add_child(leaderboardPanel)
			var name_ : String
			if SdkBridge.leaderboard[i]["name"].is_empty():
				name_ = Language.localisation["noname"][Language.lang]
			else:
				name_ = SdkBridge.leaderboard[i]["name"]
			leaderboardPanel.setLeaderBoard(i, name_, SdkBridge.leaderboard[i]["score"], SdkBridge.leaderboard[i]["usr"])
	
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2(1, 1), 0.1)
	create_tween().tween_property(rdBackSideBestPanel, "scale", Vector2(1, 1), 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2(1, 1), 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2(1, 1), 0.25)
	
	
func setInvisible():
	create_tween().tween_property(rdBackSidePanel, "scale", Vector2.ZERO, 0.1)
	create_tween().tween_property(rdBackSideBestPanel, "scale", Vector2.ZERO, 0.15)
	create_tween().tween_property(rdPanel, "scale", Vector2.ZERO, 0.2)
	create_tween().tween_property(rdNoButton, "scale", Vector2.ZERO, 0.25)
	await get_tree().create_timer(0.1).timeout
	visible = false
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS


func _on_no_button_pressed() -> void:
	await setInvisible()
	Global.MainMenuOpen.emit()
