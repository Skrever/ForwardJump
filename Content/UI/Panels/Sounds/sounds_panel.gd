class_name SoundsPanel
extends Panel

@onready var rdHSlider: HSlider = $HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rdHSlider.value = Global.Sounds
	#SdkBridge.DataLoaded.connect(resetSounds)

func getNewSounds() -> int: return rdHSlider.value

func resetSounds() -> void : rdHSlider.value = Global.Sounds
