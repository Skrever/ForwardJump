extends Node

signal CollumnGenerated()

signal SetMusicVolume()

signal GameReady()
signal GameReload()
signal GameStart()
signal GameStop()
signal GamePaused()
signal GameContinued()
signal GameResumed()

enum DIRECTION 
{
	LEFT,
	FORWARD,
	RIGHT,
	BACK
}

enum GAMESTATS
{
	NONE,
	READY,
	GOING,
	PAUSED
}

var GameState : GAMESTATS = GAMESTATS.NONE

# Сторона и длинна, куда должен двигаться игрок и спавниться колоннки
var Direction : DIRECTION = DIRECTION.LEFT
var MaxDistance : float = 10
var MinDistance : float = 7
var MaxCountCollumns : int = 10
var RandomSpawn : bool = true

var player : Player = null
var generator : Generator = null

var Music : float = 40
var Sounds : float = 40

func _ready() -> void:
	
	GameReady.connect(_on_game_ready)
	GameReload.connect(_on_game_reload)
	GameStart.connect(_on_game_going)
	GameStop.connect(_on_game_stopped)
	GamePaused.connect(_on_game_paused)
	GameContinued.connect(_on_game_continued)
	GameResumed.connect(_on_game_resumed)
	
	await CollumnGenerated
	GameReady.emit()
	#GameStart.emit()	
	
func _on_game_ready():
	GameState = GAMESTATS.NONE
	print("Game Ready")
	
func _on_game_reload():
	GameState = GAMESTATS.NONE
	print("Game Reload")
	
func _on_game_going():
	GameState = GAMESTATS.GOING
	print("Game Going")

func _on_game_paused():
	GameState = GAMESTATS.PAUSED
	print("Game Paused")
	
func _on_game_continued():
	GameState = GAMESTATS.GOING
	print("Game Continued")
	
func _on_game_stopped():
	GameState = GAMESTATS.NONE
	print("Game Stopped")
	
func _on_game_resumed():
	GameState = GAMESTATS.GOING
	print("Game Resumed")
	
func lost_focus():
	pass
	
func get_focus():
	pass
