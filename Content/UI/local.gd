extends Label

@export var Name_Text : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Language.ChangeLanguage.connect(func() : text = Language.local(Name_Text))
	text = Language.local(Name_Text)
