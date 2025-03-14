extends Control

@onready var rdLabel: Label = $LearningGroupBox/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	setInvisible()
	UI.OpenLearningMenu.connect(setVisible)
	UI.CloseLearningMenu.connect(setInvisible)
	
var time_passed : float = 0
func _physics_process(delta: float) -> void:
	if visible:
		time_passed += delta
		var _tmp_scale : float = 1 +  sin(time_passed * 5) / 40
		rdLabel.scale = Vector2(_tmp_scale, _tmp_scale)

func setVisible():
	visible = true
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	create_tween().tween_property(rdLabel, "scale", Vector2(1, 1), 0.1)
	await get_tree().create_timer(0.1).timeout
	
	UI.LearningMenuOpened.emit()
	
	
func setInvisible():
	create_tween().tween_property(rdLabel, "scale", Vector2.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	
	visible = false
	UI.LearningMenuClosed.emit()
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	
