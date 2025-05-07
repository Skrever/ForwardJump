extends Label3D

@export var Name_Text : String

func _ready() -> void:
	Language.ChangeLanguage.connect(func() : text = Language.local(Name_Text))
	text = Language.local(Name_Text)
