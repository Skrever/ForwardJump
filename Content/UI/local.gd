extends Label

@export var Name_Text : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Language.changeLanguage.connect(func() : text = Language.localisation[Name_Text][Language.lang])
	text = Language.localisation[Name_Text][Language.lang]
