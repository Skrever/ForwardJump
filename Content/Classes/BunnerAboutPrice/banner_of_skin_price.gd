extends Sprite3D

@onready var message: Message = $SubViewport/Message

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.ChangePlayerSkin.connect(_change_price)
	UI.OpenStoreMenu.connect(func(): _setVisible(true))
	UI.StoreMenuClosed.connect(func(): _setVisible(false))



func _change_price(TakedSkin : Global.SKINS):
	#print(Global.boughtSkins[Global.TakedSkin])
	var tween := create_tween().tween_property(self, "scale", Vector3.ZERO, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	await tween.finished
	if !Global.boughtSkins[TakedSkin]:
		message.changeText(Language.local("cost") + Global.get_skin_by_key(Global.getSkinByEnum(TakedSkin))["price"])
	else:
		message.changeText(Language.local("bought"))
	create_tween().tween_property(self, "scale", Vector3(1,1,1), 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)

func _setVisible(visibility : bool):
	if visibility:
		_change_price(Global.TakedSkin)
	else:
		var tween := create_tween().tween_property(self, "scale", Vector3.ZERO, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		message.setInvisible()
