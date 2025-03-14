extends Node

signal ChangeLanguage()

var lang : String = "ru"
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	lang = SDKBridge.lang
	ChangeLanguage.emit()

func local(key : String) -> String:
	return Localisation[key][lang]

var Localisation : Dictionary = {
	
	"best" : 
		{
			"ru": "Топ 5",
			"en": "Top 5"
		},
	"noname" : 
		{
			"ru": "Игрок невидим",
			"en": "Noname player"
		}
}
