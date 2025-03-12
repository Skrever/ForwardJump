class_name MusicPanel
extends Panel

@onready var rdHSlider: HSlider = $HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rdHSlider.value = Global.Music 
	#SdkBridge.DataLoaded.connect(resetMusic)

func getNewMusic() -> int: 
	return rdHSlider.value

func resetMusic() -> void: rdHSlider.value = Global.Music 
	
func _on_h_slider_value_changed(value: float) -> void:
	Global.SetMusicVolume.emit(value)
