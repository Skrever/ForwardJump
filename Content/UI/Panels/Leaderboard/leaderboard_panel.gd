class_name LeaderboardPanel
extends Panel
@onready var rdName: Label = $BackNamePanel/Name
@onready var rdZombies: Label = $Panel/Zombies
@onready var rdAvatar: TextureRect = $Avatar
@onready var rdFrame: Panel = $Avatar/Frame

func setLeaderBoard(place_ : String = "1", name_ : String = "NoName", count_ : String = " ", usr : bool = false, img : Array = []):
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
	if !img.is_empty():
		var avatar := Image.new()
		avatar.load_png_from_buffer(img)
		rdAvatar.texture = ImageTexture.create_from_image(avatar)
		
	var styleBox: StyleBoxFlat = StyleBoxFlat.new()
	styleBox = rdFrame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	
	match place_:
		"1": styleBox.border_color = Color(0.82, 0.71, 0.00)
		"2": styleBox.border_color = Color(0.56, 0.75, 0.76)
		"3": styleBox.border_color = Color(0.82, 0.53, 0.47)
		"4": styleBox.border_color = Color(0.60, 0.65, 0.48)
		_: styleBox.border_color = Color(0.63, 0.50, 0.70)
	rdFrame.add_theme_stylebox_override("panel", styleBox)
	
	var styleBoxUsr: StyleBox = get_theme_stylebox("panel").duplicate()
	if usr:
		#rdName.text = Language.localisation["username"][Language.lang]
		styleBoxUsr.bg_color = Color(0.23, 0.22, 0.20)
	else:
		styleBoxUsr.bg_color = Color(0.47, 0.47, 0.47)
	add_theme_stylebox_override("panel", styleBoxUsr)
