extends Node

signal UserTryToAuth
signal SDKinited
signal PhotoDownloaded
var LoadedImage : Image

signal CloseAdd
signal RewardedAdShowed
var canReward : bool = false

signal DataDeleted
signal DataLoaded
signal DataSaved

signal PlayerLevelLoadFromIternal

signal UpdateLeaderboard(Dictionary)

var isDataLoading := false
var isDataSaving := false
var DataLoadedFully := false
var canSaiving := false

#@onready var manager = JavaScriptBridge.get_interface("manager")

var UserAuth : bool = false

var leaderboard : Dictionary:  #= { "1" : {"rank": "1", "name" : "Абрикосовый сироп", "score" : "20", "usr" : true, "img": [] },
									#"2" : {"rank": "2", "name" : "Кроккодило Бомбардиро", "score" : "15", "usr" : false, "img": [] },
										 #"3" : {"rank": "3", "name" : "Зубенко Михаил", "score" : "12", "usr" : false, "img": [] },
											#"4" : {"rank": "4", "name" : "Летающее нечто", "score" : "7", "usr" : false, "img": [] },
												#"5" : {"rank": "5", "name" : "Очередной пингачок", "score" : "5", "usr" : false, "img": [] }}:
	get:
		return leaderboard
	set(value):
		leaderboard = value
		UpdateLeaderboard.emit(leaderboard)

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
	
	Bridge.advertisement.connect("interstitial_state_changed", Callable(self, "_on_ad_state_changed"))
	Bridge.advertisement.connect("rewarded_state_changed", Callable(self, "_on_rewarded_ad_state_changed"))
	
	Global.GameReady.connect(_game_ready)
	#Global.SavePlayerData.connect(saveData)
	Global.GamePaused.connect(saveData)
	Global.GameStop.connect(saveData)
	
	Global.GameStart.connect(GameIsOn)
	Global.GameContinued.connect(GameIsOn)
	Global.GameReload.connect(GameIsOff)
	Global.GamePaused.connect(GameIsOff)
	
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
		
func ShowRewordedAdd():
	Bridge.advertisement.show_rewarded()
		
	
func _on_ad_state_changed(state):
	match state:
		"loading":
			print("Ad loading...")
			AudioServer.set_bus_mute(0, true)
		"opened" :
			print("Ad opened...")
			AudioServer.set_bus_mute(0, true)
		"closed":
			print("Ad closed...")
			CloseAdd.emit()
			AudioServer.set_bus_mute(0, false)
		"failed":
			print("Ad failed...")
			CloseAdd.emit()
			AudioServer.set_bus_mute(0, false)
			
	
			
func _on_rewarded_ad_state_changed(state):
	canReward = false
	match state:
		"loading":
			print("Ad loading...")
			AudioServer.set_bus_mute(0, true)
		"opened" :
			print("Ad opened...")
			AudioServer.set_bus_mute(0, true)
		"closed":
			print("Ad closed...")
			AudioServer.set_bus_mute(0, false)
		"rewarded":
			#AudioServer.set_bus_mute(0, false)
			canReward = true
			RewardedAdShowed.emit()
			print("Ad rewarded...")
			
		"failed":
			print("Ad failed...")
			RewardedAdShowed.emit()
			AudioServer.set_bus_mute(0, false)

	

func _game_ready():
	Bridge.platform.send_message(Bridge.PlatformMessage.GAME_READY)
	if !Bridge.player.is_authorized:
		UI.OpenAuthMenu.emit()
		await UserTryToAuth
		if Bridge.player.is_authorized: _update_leaderboard_timer()
	else:
		_update_leaderboard_timer()
		UI.OpenMainMenu.emit()
		UI.OpenLearningMenu.emit()

func _get_raw_leaderboard(success, entries):
	if success:
		
		var new_leaderboard : Dictionary
		match Bridge.platform.id:
			"yandex":
				for entry in entries:
					#print(entry)
					var usr := false
					if str(entry.name) == Bridge.player.name:
						usr = true
					#print("Player: ", str(entry.name), " Scores: ", str(entry.score))
					var name_ = str(entry.name)
					if str(entry.name).is_empty():
						name_ = Language.local("noname")
					#print("сырое имя игрока: ", entry.name, " После обработки: ", name_)
					var HTTPImgRequest := HTTPRequest.new()
					add_child(HTTPImgRequest)
					HTTPImgRequest.request_completed.connect(_on_load_img)
					print(entry.photo)
					HTTPImgRequest.request(entry.photo)
					await PhotoDownloaded
					
					var user = {
							"rank" : str(new_leaderboard.keys().size() + 1), 
							"name" : name_,
							"score" : str(entry.score),
							"usr" : usr,
							"img": LoadedImage.save_png_to_buffer()
							}
					new_leaderboard.get_or_add(str(entry.rank), user)

		leaderboard.clear()
		leaderboard = new_leaderboard


func _on_load_img(result, response_code, headers, body):
	if response_code == 200:
		var img := Image.new()
		if img.load_jpg_from_buffer(body) != OK:
			if img.load_png_from_buffer(body) != OK:
				if img.load_webp_from_buffer(body) != OK:
					img.load_from_file("res://Content/UI/Textures/testImg.jpg")
		LoadedImage = img

	else:
		LoadedImage.load_from_file("res://Content/UI/Textures/testImg.jpg")
	PhotoDownloaded.emit()
	
func authUser():
	var options = {"scopes" : true}
	Bridge.player.authorize(options, Callable(self, "_on_player_authorize_completed"))
	
func _on_player_authorize_completed(success): 
	UserAuth = success
	if success:
		print("Authorized")
	else:
		print("Authorization error")
	UserTryToAuth.emit()
	

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
		"quantityAround": 1,
		"quantityTop": 5
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
	print("Попытка сохранить...")
	var MaxScore = Global.MaxScore
	var Gems = Global.Gems
	var boughtSkins : String = ""
	for skin in Global.boughtSkins: boughtSkins += "1" if skin else "0"
	var takedSkin : int = Global.TakedSkin
	var backColor : String = Global.backColor.to_html(false)
	var secondBackColor : String = Global.secondBackColor.to_html(false)
	var sounds : float = Global.Sounds
	var music : float = Global.Music
	
	Bridge.storage.set(["MaxScore", "Gems", "boughtSkins", "takedSkin", "backColor", "secondBackColor", "sounds", "music"], [MaxScore, Gems, boughtSkins, takedSkin, backColor, secondBackColor, sounds, music], Callable(self, "_on_storage_set_completed"), Bridge.StorageType.LOCAL_STORAGE)
	
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
	
	Bridge.storage.get(["MaxScore", "Gems", "boughtSkins", "takedSkin", "backColor", "secondBackColor", "sounds", "music"], Callable(self, "_on_storage_get_completed"), Bridge.StorageType.LOCAL_STORAGE)
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
		print(data)
		print("Load user data is ", success)
		
		# Восстанавливаем максимальные очки
		Global.MaxScore = int(data[0]) if data[0] != null else 0
		
		# Восстанавливаем гемы
		Global.Gems = int(data[1]) if data[1] != null else 0
		
		# Восстанавливаем массив купленных скинов
		if data[2] != null:
			Global.boughtSkins.clear()
			var countSkins : int = Global.SkinsDict.keys().size()
			for let in str(data[2]): 
				if let == "1": Global.boughtSkins.append(true)  
				else: Global.boughtSkins.append(false)
			if Global.boughtSkins.size() < countSkins:
				for i in range(0, countSkins - Global.boughtSkins.size()):
					Global.boughtSkins.append(false)
			Global.boughtSkins[0] = true
			
			
		#Восстанавливаем выбранный индекс скина
		Global.TakedSkin = int(data[3]) if data[3] != null else 0
		
		#Восстанавливаем цвет заднего фона
		Global.backColor = Color(str(data[4])) if data[4] != null else "b87968"
		Global.secondBackColor = Color(str(data[5])) if data[5] != null else "e65c48"
		
		Global.Sounds = float(data[6]) if data[6] != null else Global.Sounds
		Global.Music = float(data[7]) if data[7] != null else Global.Music
		
	else:
		print("Loading Data is insucces")
		
	DataLoadedFully = true
	DataLoaded.emit()
	isDataLoading = false
		
func GameIsOn():
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STARTED)
#
func GameIsOff():
	Bridge.platform.send_message(Bridge.PlatformMessage.GAMEPLAY_STOPPED)

func _on_visibility_state_changed(state):
	print(state)
	match str(state):
		"hidden":
			Global.lost_focus()
		"visible":
			Global.get_focus()
			
