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
	"auth":
		{
		"ru": "Авторизуйтесь, чтобы можно было видеть вас в списках лучших!",
		"en": "Log in to be visible on the leaderboards!"
		},
	"best" : 
		{
			"ru": "Топ 5",
			"en": "Top 5"
		},
	"noname" : 
		{
			"ru": "Игрок невидим",
			"en": "Noname player"
		},
	"continueforadd" : 
		{
			"ru": "Продолжить после рекламы",
			"en": "Watch ad to continue"
		},
	"learning" :
		{
			"ru": "Нажми на экран и проведи вниз чтобы регулировать прыжок!",
			"en": "Tap the screen and swipe down to adjust the jump!"
		}
}
