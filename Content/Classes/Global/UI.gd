extends Node

signal OpenMainMenu()
signal CloseMainMenu()
signal MainMenuOpened()
signal MainMenuClosed()

signal OpenDeadMenu()
signal CloseDeadMenu()
signal DeadMenuOpened()
signal DeadMenuClosed()

signal OpenSettingsMenu()
signal CloseSettingsMenu()
signal SettingsMenuOpened()
signal SettingsMenuClosed()

signal OpenLeaderboardMenu()
signal CloseLeaderboardMenu()
signal LeaderboardMenuOpened()
signal LeaderboardMenuClosed()

signal OpenPauseMenu()
signal ClosePauseMenu()
signal PauseMenuOpened()
signal PauseMenuClosed()

signal OpenLearningMenu()
signal CloseLearningMenu()
signal LearningMenuOpened()
signal LearningMenuClosed()

signal OpenHUD()
signal CloseHUD()
signal HUDOpened()
signal HUDClosed()

signal OpenStoreMenu()
signal CloseStoreMenu()
signal StoreMenuOpened()
signal StoreMenuClosed()

signal OpenAuthMenu()
signal CloseAuthMenu()
signal AuthMenuOpened()
signal AuthMenuClosed()

enum FOCUS_IN
{
	NONE,
	MAIN_MENU,
	GAME,
	DEAD_MENU,
	PAUSE_MENU,
	SETTINGS_MENU,
	LEADERBOARD_MENU,
	STORE_MENU,
	AUTH_MENU
}

var focus : FOCUS_IN = FOCUS_IN.NONE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.GameReady.connect(_on_game_ready)
	Global.GameStart.connect(_on_game_going)
	Global.GameStop.connect(_on_game_stopped)
	Global.GamePaused.connect(_on_game_paused)
	Global.GameContinued.connect(_on_game_continued)
	Global.GameResumed.connect(_on_game_resumed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_game_ready():
	pass
	
func _on_game_going():
	CloseMainMenu.emit()
	CloseLearningMenu.emit()
	OpenHUD.emit()

func _on_game_paused():
	CloseHUD.emit()
	OpenPauseMenu.emit()

func _on_game_continued():
	OpenHUD.emit()
	
func _on_game_stopped():
	CloseHUD.emit()
	ClosePauseMenu.emit()
	CloseSettingsMenu.emit()
	CloseMainMenu.emit()
	OpenDeadMenu.emit()
	
func _on_game_resumed():
	OpenHUD.emit()
