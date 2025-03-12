extends Label


func _ready() -> void:
	Global.CoinsChanged.connect(setCoins)
	setCoins()
	
func setCoins():
	if (Global.Coins < 99999) and (Global.Coins >= 0):
		text = str(Global.Coins)
	else:
		text = "(◣_◢)"
