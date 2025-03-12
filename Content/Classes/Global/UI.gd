extends Node

signal OpenMainMenu()
signal CloseMainMenu()
signal MainMenuOpened()
signal MainMenuClosed()

signal OpenDeadMenu()
signal CloseDeadMenu()
signal DeadMenuOpened()
signal DeadMenuClosed()


enum FOCUS_IN
{
	NONE,
	MAIN_MENU,
	GAME,
	DEAD_MENU
}

var focus : FOCUS_IN = FOCUS_IN.NONE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Дебаг
	await get_tree().create_timer(2).timeout
	OpenMainMenu.emit()
	
	Global.GameReady.connect(_on_game_ready)
	Global.GameStart.connect(_on_game_going)
	Global.GameStop.connect(_on_game_stopped)
	Global.GamePaused.connect(_on_game_paused)
	Global.GameResumed.connect(_on_game_resumed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_game_ready():
	pass
	
func _on_game_going():
	CloseMainMenu.emit()
	focus = FOCUS_IN.GAME

func _on_game_paused():
	pass
	
func _on_game_stopped():
	await get_tree().create_timer(1).timeout
	OpenDeadMenu.emit()
	
func _on_game_resumed():
	pass
