extends Node

signal CollumnGenerated()
signal GenerateNextCollumn()

signal SetMusicVolume()

signal PlayerOnCollumn()
signal PlayerScoresChanged(scores : int)
signal GettedScores(scores : int)

signal PlayerGemsChanged(gems : int)
signal GettedGems(gems : int)

signal ChangePlayerSkin(skin : SKINS)

signal GameReady()
signal GameReload()
signal GameStart()
signal GameStop()
signal GamePaused()
signal GameContinued()
signal GameResumed()
var recentlyResumed : bool = false

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

enum SKINS
{
	DEFAULT,
	MINECRAFT
}

var GameState : GAMESTATS = GAMESTATS.NONE
var MaxTimesGameResumed : int = 2
var CurTimesGameResumed : int = 0
var ButtonPressed : bool = false

# Сторона и длинна, куда должен двигаться игрок и спавниться колоннки
var Direction : DIRECTION = DIRECTION.LEFT
var MaxDistance : float = 10
var MinDistance : float = 7
var MaxCountCollumns : int = 10
var RandomSpawn : bool = true

# Количество спавна гемов
var MaxCountGems : int = 3

var player : Player: 
	get:
		return player
	set(value):
		player = value as Player
		player.MovingStarted.connect(func(): CountTouchesCollumn = 0; recentlyResumed = false)
		
var generator : Generator = null

var Music : float = 40
var Sounds : float = 40

var UserKnowHowToPlay : bool = false

var GoalScore : int = 0
var Score : int:
	get:
		return Score 
	set(value):
		if !UserKnowHowToPlay: UserKnowHowToPlay = true 
		Score = int(value)
		PlayerScoresChanged.emit(Score)
		GettedScores.emit(Score)
		
var MaxScore : int:
	get:
		return MaxScore
	set(value):
		MaxScore = int(value)
		SDKBridge.setUserRecord(MaxScore)
		
var Gems : int:
	get:
		return Gems
	set(value):
		Gems = int(value)
		print("Add gems")
		PlayerGemsChanged.emit(Gems)

var CountTouchesCollumn : int = 0

var SkinsDict : Dictionary
var TakedSkin : SKINS = SKINS.DEFAULT
var boughtSkins : Array[bool] = [true, false]
func getSkinByEnum(skin : SKINS) -> String:
	var key : String = "default"
	match skin:
		SKINS.MINECRAFT:
			key = "minecraft"
	return key


func _ready() -> void:
	
	SkinsDict = _read_from_json("res://Content/Classes/Player/Skins/Skins.json")
	
	GameReady.connect(_on_game_ready)
	GameReload.connect(_on_game_reload)
	GameStart.connect(_on_game_going)
	GameStop.connect(_on_game_stopped)
	GamePaused.connect(_on_game_paused)
	GameContinued.connect(_on_game_continued)
	GameResumed.connect(_on_game_resumed)
	
	PlayerOnCollumn.connect(playerOnCollumn)
	PlayerOnCollumn.connect(func(): GenerateNextCollumn.emit())
	
	
	
	
	SDKBridge.loadUserData()
	
	await CollumnGenerated
	await get_tree().create_timer(1).timeout
	GameReady.emit()
	PlayerGemsChanged.emit(Global.Gems)

func _read_from_json(path : String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		return data
	else:
		print("file in ", path, " doesn't exist")

func get_skin_by_key(key : String):
	if SkinsDict and SkinsDict.has(key):
		return SkinsDict[key].duplicate(true)
	else:
		printerr("can't find this skin: ", key)

func _on_game_ready():
	GameState = GAMESTATS.NONE
	print("Game Ready")
	
func _on_game_reload():
	MaxScore = max(Score, MaxScore)
	Score = 0
	GoalScore = 0
	CountTouchesCollumn = 0
	CurTimesGameResumed = 0
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
	GameState = GAMESTATS.NONE
	print("Game Stopped")
	
func _on_game_resumed():
	GameState = GAMESTATS.GOING
	CurTimesGameResumed += 1
	recentlyResumed = true
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
	if !recentlyResumed:
		Score += (1 + GoalScore)
