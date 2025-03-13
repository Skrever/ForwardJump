extends Node

signal UserAuthCorrectly
signal SDKinited
signal CloseAdd
signal DataDeleted
signal DataLoaded
signal DataSaved

signal PlayerLevelLoadFromIternal

var isDataLoading := false
var isDataSaving := false
var DataLoadedFully := false
var canSaiving := false

#@onready var manager = JavaScriptBridge.get_interface("manager")

var UserAuth : bool = false

var leaderboard : Dictionary  #= { "1" : { "name" : "Огромный хуй", "score" : "10000", "usr" : true }, "2" : { "name" : "Большой член", "score" : "999", "usr" : false }, "3" : { "name" : "Синица съяйцами", "score" : "9999", "usr" : false }}
var maxLeaderBoardScore : int
var lang : String = "en"
var device : String = "mobile"
var canShowAdd := true

var PlayerLevelInLocal : int
var PlayerLevelInInternal : int

var AdTimer : Timer
var SaveTimer : Timer

func _ready() :
	device = Bridge.device.type
	Bridge.advertisement.set_minimum_delay_between_interstitial(10)
	
	Bridge.advertisement.connect("interstitial_state_changed", Callable(self, "_on_interstitial_state_changed"))
	
	Global.GameReady.connect(_game_ready)
	#Global.SavePlayerData.connect(saveData)
	Global.GamePaused.connect(saveData)
	Global.GameStop.connect(saveData)
	
	#Global.GameStart.connect(GameIsOn)
	#Global.GameContinued.connect(GameIsOn)
	#Global.GameReload.connect(GameIsOff)
	#Global.GamePaused.connect(GameIsOff)
	
	#Global.PlayerLevelChanged.connect(func(x) : saveData())
	
	
	AdTimer = Timer.new()
	add_child(AdTimer)
	AdTimer.timeout.connect(_on_ad_timer_timeout)
	AdTimer.autostart = true
	AdTimer.one_shot = false
	AdTimer.wait_time = 30 
	_on_ad_timer_timeout()
	ShowAdd()
	
	SaveTimer = Timer.new()
	SaveTimer.timeout.connect(_on_saving_timer_timeout)
	SaveTimer.autostart = true
	SaveTimer.one_shot = false
	SaveTimer.wait_time = 4
	_on_saving_timer_timeout()
	add_child(SaveTimer)
	match Bridge.platform.language:
		"ru":
			lang = "ru"
		_:
			lang = "en"
	
	Bridge.game.connect("visibility_state_changed", Callable(self, "_on_visibility_state_changed"))
	SDKinited.emit()


func _on_ad_timer_timeout():
	#print("update ad")
	AdTimer.stop()
	canShowAdd = true

func ShowAdd():
	if canShowAdd:
		
		#if Global.GameState == Global.GAMESTATS.GOING:
			#Global.GamePaused.emit()
		#print("Can show ad")
		Bridge.advertisement.show_interstitial()
		canShowAdd = false
		AdTimer.start()
	else:
		#print("Can't show ad!")
		CloseAdd.emit()
		
	
func _on_interstitial_state_changed(state):
	match state:
		"loading":
			print("Ad loading...")
			#Global.SetMusicVolume.emit(0)
		"opened" :
			print("Ad opened...")
			#Global.SetMusicVolume.emit(0)
			#if Global.GameState == Global.GAMESTATS.GOING:
				#Global.GamePaused.emit()
				#Global.PauseMenuOpen.emit()
		"closed":
			print("Ad closed...")
			#Global.SetMusicVolume.emit(Global.Music)
			CloseAdd.emit()
		"failed":
			print("Ad failed...")
			#Global.SetMusicVolume.emit(Global.Music)
			CloseAdd.emit()

func _game_ready():
	Bridge.platform.send_message(Bridge.PlatformMessage.GAME_READY)
	if !Bridge.player.is_authorized:
		pass
		#Global.AuthorizePlayer.emit()
	else:
		pass
		#Global.MainMenuOpen.emit()
	_update_leaderboard_timer()

func _get_raw_leaderboard(success, entries):
	if success:
		leaderboard.clear()
		match Bridge.platform.id:
			"yandex":
				for entry in entries:
					var usr := false
					if str(entry.name) == Bridge.player.name:
						usr = true
						#print("User in leaderboard")
					var name_ = str(entry.name)
					if str(entry.name).is_empty():
						name_ = ""
					#print("сырое имя игрока: ", entry.name, " После обработки: ", name_)
					var user = {
							"name" : name_,
							"score" : str(entry.score),
							"usr" : usr
							} 
					leaderboard.get_or_add(str(entry.rank), user)

func authUser():
	var options = {"scopes" : true}
	Bridge.player.authorize(options, Callable(self, "_on_player_authorize_completed"))
	UserAuthCorrectly.emit()
	
func _on_player_authorize_completed(success): 
	UserAuth = success
	if success:
		print("Authorized")
	else:
		print("Authorization error")
	UserAuthCorrectly.emit()

func _update_leaderboard_timer():
	print("Leaderboard init")
	_update_leaderboard()
	var UpdateLeaderBoardTimer := Timer.new()
	UpdateLeaderBoardTimer.autostart = true
	UpdateLeaderBoardTimer.one_shot = false
	UpdateLeaderBoardTimer.wait_time = 16
	UpdateLeaderBoardTimer.timeout.connect(_update_leaderboard)
	add_child(UpdateLeaderBoardTimer)

func _update_leaderboard():
	print("Update Leaderboard")
	var options = {
		"leaderboardName": "Best",
		"includeUser": true,
		"quantityAround": 0,
		"quantityTop": 10
		}
	Bridge.leaderboard.get_entries(options, Callable(self, "_get_raw_leaderboard"))

func setUserRecord(score : int):
	if maxLeaderBoardScore < score:
		Bridge.leaderboard.set_score({ "leaderboardName": "Best", "score": score }, Callable(self, "_on_set_score_completed"))
		
func _on_set_score_completed(success):
	print("Posted is ", success)
	pass

func _on_saving_timer_timeout():
	if canSaiving and !isDataSaving and !isDataLoading:
		#print("Сработал таймер на сохранение во время игры")
		if Global.GameState == Global.GAMESTATS.GOING:
			saveData()
	else:
		canSaiving = true

func saveData():
	
	if !canSaiving: return
	canSaiving = false
	if isDataLoading: await DataLoaded # Если сейчас загружается что-то, пропуск
	isDataSaving = true
	#print("Попытка сохранить...")
	#
	#var boughtCats : String
	#for i in Global.boughtCats:
		#if i:
			#boughtCats += "1"
		#else:
			#boughtCats += "0"
	#var TakedCatID : int = Global.TakedCat
	#var TakedGunID : int = Global.TakedGun
	#var Coins : int = Global.Coins
	#var CountKilledZombies : int = Global.CountKilledZombie # Сохраняем максимальное число, чтоб потом сравнивать с текущим
	#var Music : int = Global.Music
	#var Sounds : int = Global.Sounds
	#var PlayerLevel = Global.PlayerLevel
	#var ProgressKillZombie : int = Global.ProgressKillZombie
	#var CatName : String = Global.CatName
	#var ControlSystem : String = "touch" if Global.ControlSystem == Global.CONTROL.TOUCH else "joystick"
	#
	#Bridge.storage.set(["boughtCats", "TakedCatID", "TakedGunID", "Coins", "CountKilledZombies", "Music", "Sounds", "PlayerLevel", "ProgressKillZombie", "CatName", "ControlSystem"], [boughtCats, TakedCatID, TakedGunID, Coins, CountKilledZombies, Music, Sounds, PlayerLevel, ProgressKillZombie, CatName, ControlSystem], Callable(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	#
	
func _on_get_score_completed(success, score):
	if success:
		maxLeaderBoardScore = int(score)
	else:
		maxLeaderBoardScore = 0

func _on_storage_delete_completed(success):
	#Bridge.storage.delete(["boughtCats", "TakedCatID", "TakedGunID", "Coins", "CountKilledZombies", "Music", "Sounds", "PlayerLevel", "ProgressKillZombie"], Callable(self, "_on_storage_delete_completed"), Bridge.StorageType.LOCAL_STORAGE)
	print("Remove user data is ", success)
	DataDeleted.emit()
	
func _on_storage_set_completed(success):
	print("Save user data is ", success)
	DataSaved.emit()
	isDataSaving = false

func loadUserData():
	if isDataSaving: await DataSaved
	isDataLoading = true
	
	Bridge.storage.get(["boughtCats", "TakedCatID", "TakedGunID", "Coins", "CountKilledZombies", "Music", "Sounds", "PlayerLevel", "ProgressKillZombie", "CatName", "ControlSystem"], Callable(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE)
	Bridge.leaderboard.get_score({ "leaderboardName": "Best" }, Callable(self, "_on_get_score_completed"))
	#if Bridge.storage.is_supported(Bridge.StorageType.PLATFORM_INTERNAL):
		#print("Выбрали облако")
		#Bridge.storage.get(["boughtCats", "TakedCatID", "TakedGunID", "Coins", "CountKilledZombies", "Music", "Sounds", "PlayerLevel", "ProgressKillZombie", "CatName"], Callable(self, "_on_storage_get_completed"))
	#else:
		#print("Выбрали локалку")
		#Bridge.storage.get(["boughtCats", "TakedCatID", "TakedGunID", "Coins", "CountKilledZombies", "Music", "Sounds", "PlayerLevel", "ProgressKillZombie", "CatName"], Callable(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE)
		
func _on_storage_get_completed(success, data):
	if success:
		pass
		#print(data)
		#print("Load user data is ", success)
		#if data[0] != null:
			#for i in range(0, data[0].length()):
				#if (data[0][i] == "1") or (data[0][i] == "0"):
					#if (data[0][i] == "1") : Global.boughtCats[i] = true
					#else : Global.boughtCats[i] = false
		#else:
			#Global.boughtCats = [true, false, false, false]
		#if data[1] != null:
			#Global.TakedCat = data[1]
		#else:
			#Global.TakedCat = 0
		#if data[2] != null:
			#Global.TakedGun = data[2]
		#else:
			#Global.TakedGun = 0
		#if data[3] != null:
			#Global.Coins = data[3]
		#else:
			#Global.Coins = 0
		#if data[4] != null:
			#Global.CountKilledZombie = data[4]
		#else:
			#Global.CountKilledZombie = 0
		#if data[5] != null:
			#Global.Music = data[5]
		#else:
			#Global.Music = 40
		#if data[6] != null:
			#Global.Sounds = data[6]
		#else:
			#Global.Sounds = 40
		#if data[7] != null:
			#Global.PlayerLevel = data[7]
			#Global.PlayerLevelChanged.emit(Global.PlayerLevel)
		#else:
			#Global.PlayerLevel = 1
		#if data[8] != null:
			#Global.ProgressKillZombie = data[8]
		#else:
			#Global.ProgressKillZombie = 0
		#if data[9] != null:
			#Global.CatName = data[9]
		#else: 
			#Global.CatName = " "
		#if data[10] != null:
			#Global.ControlSystem = Global.CONTROL.TOUCH if data[10] == "touch" else Global.CONTROL.JOYSTICK
			#if device == "mobile": Global.ControlSystem = Global.CONTROL.JOYSTICK
		#else:
			#Global.ControlSystem = Global.CONTROL.TOUCH if device == "desktop" else Global.CONTROL.JOYSTICK
	else:
		print("Loading Data is insucces")
		
	DataLoadedFully = true
	DataLoaded.emit()
	Global.DataLoadedCorrectly.emit()
	isDataLoading = false
		
#func GameIsOn():
	#Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)
#
#func GameIsOff():
	#Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)

func _on_visibility_state_changed(state):
	print(state)
	match str(state):
		"hidden":
			Global.lost_focus()
		"visible":
			Global.get_focus()
			
