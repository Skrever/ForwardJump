class_name LeaderboardPanel
extends Panel
@onready var rdName: Label = $BackNamePanel/Name
@onready var rdPlace: Label = $BackNumberPanel/Place
@onready var rdZombies: Label = $Panel/Zombies
@onready var rdBackNumberPanel: Panel = $BackNumberPanel

func setLeaderBoard(place_ : String = "1", name_ : String = "NoName", count_ : String = " ", usr : bool = false):
	var zombies_count : int
	if int(count_) >= 1000:
		rdZombies.add_theme_font_size_override("font_size", 16)
		rdZombies.text = str(floor(int(count_) / 1000))
		rdZombies.text += "."
		rdZombies.text += str(floor((int(count_) % 1000) / 100) )
		rdZombies.text += "K"
	else:
		rdZombies.text = count_
		
	rdName.text = name_
	rdPlace.text = place_
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox = rdBackNumberPanel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	
	match place_:
		"1":
			styleBox.bg_color = Color(0.82, 0.71, 0.00)
		"2":
			styleBox.bg_color = Color(0.56, 0.75, 0.76)
		"3":
			styleBox.bg_color = Color(0.82, 0.53, 0.47)
		_:
			styleBox.bg_color = Color(0.63, 0.62, 0.60)
	rdBackNumberPanel.add_theme_stylebox_override("panel", styleBox)
	
	var styleBoxUsr: StyleBox = get_theme_stylebox("panel").duplicate()
	if usr:
		#rdName.text = Language.localisation["username"][Language.lang]
		styleBoxUsr.bg_color = Color(0.23, 0.22, 0.20)
	else:
		styleBoxUsr.bg_color = Color(0.47, 0.47, 0.47)
	add_theme_stylebox_override("panel", styleBoxUsr)
