extends WorldEnvironment

@export var ColumnMaterial : StandardMaterial3D

var nextColor : Color = "#7a9e84"
var nextCollumnColor : Color = "#7a9e84"
var colorCounter : int = 1
var NowInterpolateColor : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#environment.background_color = Global.BackColor 
	environment.background_color = Global.backColor
	ColumnMaterial.albedo_color = Global.secondBackColor
	Global.PlayerScoresChanged.connect(func(x) : _lerp_background_color())
# Called every frame. 'delta' is the elapsed time since the previous frame.
var _delta_counter : float = 0
func _process(delta: float) -> void:
	if NowInterpolateColor: 
		_color_from_to(_delta_counter)
		_delta_counter = clampf(_delta_counter + (0.000001), 0.0, 0.002) 
		#print(_delta_counter)
		if _delta_counter == 0.002:
			NowInterpolateColor = false
			_delta_counter = 0.0
			print("Color changed")

	
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
			
func _color_from_to(alpha : float):
	environment.background_color = lerp(environment.background_color, nextColor, alpha)
	ColumnMaterial.albedo_color = lerp(ColumnMaterial.albedo_color, nextCollumnColor, alpha)
	Global.backColor = environment.background_color
	Global.secondBackColor = ColumnMaterial.albedo_color
