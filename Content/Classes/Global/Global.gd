extends Node

signal CollumnGenerated()

signal SetMusicVolume()

signal PlayerOnCollumn()
signal PlayerScoresChanged(scores : int)
signal GettedScores(scores : int)

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

var player : Player: 
	get:
		return player
	set(value):
		player = value as Player
		player.MovingStarted.connect(func(): CountTouchesCollumn = 0)
		
var generator : Generator = null

var Music : float = 40
var Sounds : float = 40

var GoalScore : int
var Score : int:
	get:
		return Score
	set(value):
		Score = int(value)
		PlayerScoresChanged.emit(Score)
		GettedScores.emit(Score)
		
var MaxScore : int:
	get:
		return MaxScore
	set(value):
		MaxScore = int(value)
		SDKBridge.setUserRecord(MaxScore)

var CountTouchesCollumn : int = 0

func _ready() -> void:
	
	GameReady.connect(_on_game_ready)
	GameReload.connect(_on_game_reload)
	GameStart.connect(_on_game_going)
	GameStop.connect(_on_game_stopped)
	GamePaused.connect(_on_game_paused)
	GameContinued.connect(_on_game_continued)
	GameResumed.connect(_on_game_resumed)
	
	PlayerOnCollumn.connect(playerOnCollumn)
	
	SDKBridge.loadUserData()
	
	await CollumnGenerated
	GameReady.emit()
	
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
	MaxScore = max(Score, MaxScore)
	GameState = GAMESTATS.PAUSED
	print("Game Paused")
	
func _on_game_continued():
	GameState = GAMESTATS.GOING
	print("Game Continued")
	
func _on_game_stopped():
	MaxScore = max(Score, MaxScore)
	Score = 0
	GameState = GAMESTATS.NONE
	print("Game Stopped")
	
func _on_game_resumed():
	GameState = GAMESTATS.GOING
	print("Game Resumed")

func lost_focus():
	if GameState == GAMESTATS.GOING:
		GamePaused.emit()
	
func get_focus():
	pass
	
func playerOnCollumn():
	if GameState != Global.GAMESTATS.GOING: return
	await get_tree().create_timer(0.1).timeout
	if CountTouchesCollumn == 1: GoalScore = 0
	if GoalScore > 4 : GoalScore = 4
	Score += (1 + GoalScore)
