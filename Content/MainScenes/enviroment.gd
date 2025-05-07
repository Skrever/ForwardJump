extends WorldEnvironment

@export var ColumnMaterial : StandardMaterial3D
@export var EnviromentMaterial : StandardMaterial3D

var nextColor : Color = "#7a9e84"
var nextCollumnColor : Color = "#7a9e84"
var colorCounter : int = 1
var NowInterpolateColor : bool = false
var nomenclature : float
var music : AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = load("uid://d0l1oot2hs8gv")
	music.play()
	
	Global.SetBackSideColor.connect(_set_color)
	Global.SetMusicVolume.connect(_set_music)
	
func _set_music(volume : float):
	music.volume_db = -40 + volume
	print("Музыка изменена")
	
func _set_color():
	create_tween().tween_property(environment, "background_color", Global.backColor, 0.5)
	create_tween().tween_property(EnviromentMaterial, "albedo_color", Global.backColor, 0.5)
	create_tween().tween_property(ColumnMaterial, "albedo_color", Global.secondBackColor, 0.5)
	#environment.background_color = Global.backColor
	#ColumnMaterial.albedo_color = Global.secondBackColor
	
	Global.PlayerScoresChanged.connect(func(x) : _lerp_background_color())

	
func _lerp_background_color():
	if NowInterpolateColor : return
	print("Change color")
	match colorCounter:
		0: 
			nextColor = "#b87968"
			nextCollumnColor = "e65c48"
			NowInterpolateColor = true
			colorCounter += 1
		1:
			nextColor = "#4f6b5a"
			nextCollumnColor = "7a9e6f"
			NowInterpolateColor = true
			colorCounter += 1
		2: 
			nextColor = "#5c4452"
			nextCollumnColor = "b06a7e"
			NowInterpolateColor = true
			colorCounter += 1
		3:
			nextColor = "#7a5a3a"
			nextCollumnColor = "d18a5c"
			NowInterpolateColor = true
			colorCounter += 1
		4:
			nextColor = "#3e5468"
			nextCollumnColor = "6c90a5"
			NowInterpolateColor = true
			colorCounter += 1
		5: 
			nextColor = "#2e2d2b"
			nextCollumnColor = "7e4d44"
			NowInterpolateColor = true
			colorCounter = 0
	var tween := create_tween()
	tween.tween_method(_color_from_to, 0.0, 0.005 * nomenclature, 5)
	print(0.002 * nomenclature)
	await tween.finished
	nomenclature = 0 if nomenclature >= 1.0 else (nomenclature + 0.1)
	NowInterpolateColor = false
			
func _color_from_to(alpha : float):
	environment.background_color = lerp(environment.background_color, nextColor, alpha)
	EnviromentMaterial.albedo_color = environment.background_color
	ColumnMaterial.albedo_color = lerp(ColumnMaterial.albedo_color, nextCollumnColor, alpha)
	Global.backColor = environment.background_color
	Global.secondBackColor = ColumnMaterial.albedo_color
