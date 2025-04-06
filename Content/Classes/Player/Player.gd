class_name Player
extends CharacterBody3D

signal MovingStarted
signal MovingFinished

#Детект движения по экрану
var StartTouch
var RelativeTouch
var IsPressed : bool = false
var CountJump : int = 0

var CanCastTraectory : bool = true:
	get: return CanCastTraectory
	set(value):
		CanCastTraectory = value as bool
		CastingObj.visible = CanCastTraectory

#Сжатия игрока
@export_category("Player Settings")
@export var MinCompression : float = 0.3
@export var MaxCompression : float = 1
@export var JumpCurve : Curve
@export var MaxJump : float = 3
@export var JumpTime : float = 1
@export var MaxLengthTouch : float = 300

#Компоненты игрока
var rdMesh : MeshInstance3D
@onready var rdCheckFloor: RayCast3D = $Collision/CheckFloor
@onready var rdRoot: Node3D = $Collision/Root
@onready var rdCollision: CollisionShape3D = $Collision
@onready var rdParticles: CPUParticles3D = $Particles



var moving : bool = false
var flying : bool = false
var isDead : bool = false

var StartPosition : Vector3
var lastPosition : Vector3
var nextPosition : Vector3
var lastRotation : Vector3
var nextRotation : Vector3
var CompressinRatio : float = 1
var Floor : Node3D
var Force : float = 1.4

@export var CastingObj : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	setSkin(Global.TakedSkin)
	
	UI.MainMenuOpened.connect(func() : CanCastTraectory = true)
	
	Global.ChangePlayerSkin.connect(setSkin)
	Global.player = self
	Global.GameReload.connect(_on_game_reload)
	Global.GameStart.connect(_on_game_start)
	Global.GameStop.connect(_on_game_stop)
	Global.GameResumed.connect(_on_game_resumed)
	StartPosition = position



# Called every frame. 'delta' is the elapsed time since the previous frame.
var time_passed : float = 0
func _process(delta):
	if CanCastTraectory:
		if IsPressed and !Global.ButtonPressed and (CountJump < 3):
			CastingObj.visible = true
		else: CastingObj.visible = false
	else: CastingObj.visible = false
	
	time_passed += delta
	var _tmp_scale : float = 1 +  sin(time_passed * 4) / 40
	rdRoot.scale = Vector3(_tmp_scale,_tmp_scale,_tmp_scale)
	

func _physics_process(delta):

	if (!moving and !isDead):
		velocity.y = -500 * delta
	move_and_slide()

func setSkin(TakedSkin : Global.SKINS = Global.SKINS.DEFAULT):
	var tween : Tween
	if rdMesh != null: 
		tween = create_tween()
		tween.tween_property(rdMesh, "scale", Vector3(0.7, 0.7, 0.7), 0.05)
		await tween.finished
		rdMesh.queue_free()
	var skin : MeshInstance3D = load(Global.get_skin_by_key(Global.getSkinByEnum(TakedSkin))["scene"]).instantiate()
	rdMesh = skin
	rdRoot.add_child(rdMesh)
	create_tween().tween_property(rdMesh, "scale", Vector3(1, 1, 1), 0.1)

func _input(event):

	#if UI.focus != UI.FOCUS_IN.MAIN_MENU and  UI.focus != UI.FOCUS_IN.GAME and UI.focus != UI.FOCUS_IN.NONE : return
	
	match UI.focus:
		UI.FOCUS_IN.STORE_MENU: return
		UI.FOCUS_IN.ABOUT_DEVELOPER: return
		UI.FOCUS_IN.LEADERBOARD_MENU: return
		UI.FOCUS_IN.SETTINGS_MENU: return
		UI.FOCUS_IN.AUTH_MENU: return
		
	if !moving and !isDead and (Floor != null):
		#print(UI.focus)
			#Касание экрана
		if event is InputEventScreenTouch and event.is_pressed() and !IsPressed:
			StartTouch = event.position
			IsPressed = true
			
			if CountJump < 3 and CanCastTraectory:
				CastingObj.position = position
			else: CanCastTraectory = false
			

		#Конец касания экрана
		if event is InputEventScreenTouch and event.is_released() and IsPressed: 
			IsPressed = false
			create_tween().tween_property(self, "scale", Vector3(1, 1, 1), 0.05)
			if (CompressinRatio < 0.8) and (Floor is Collumn) and !isDead: 
				match Global.GameState:
					Global.GAMESTATS.NONE: 
						if UI.focus == UI.FOCUS_IN.MAIN_MENU:
							Global.GameStart.emit()
							move()
					Global.GAMESTATS.GOING: move()
			if CastingObj.visible != false:
				for obj in CastingObj.get_children(): obj.position = Vector3.ZERO
				CastingObj.visible = false
				
		#Положение текущего касания
		if IsPressed and !Global.ButtonPressed:
			if event is not InputEventKey:
				RelativeTouch = event.position
				if (StartTouch - RelativeTouch).length() < 2.0: return
				var alpha = -(StartTouch.y - RelativeTouch.y) / MaxLengthTouch
				if alpha > 1: alpha = 1 
				elif alpha < -1 : alpha = -1
				scale.y = (1 - alpha) if MinCompression < (1 - alpha) else MinCompression
				if scale.y > MaxCompression:  scale.y = MaxCompression
				CompressinRatio = scale.y
				if CastingObj.visible:
					#CastingObj.position = position
					var countChildrensCastingObj : int = CastingObj.get_children().size()
					for i in range(1, countChildrensCastingObj):
						CastingObj.get_children()[i].position.y = JumpCurve.sample((1.0 / countChildrensCastingObj) * i) * MaxJump - 0.5
						CastingObj.get_children()[i].scale = Vector3((1.5 - 0.1 * i), (1.5 - 0.1 * i), (1.5 - 0.1 * i))
						match Floor.NextCollumnAt:
							Global.DIRECTION.LEFT: CastingObj.get_children()[i].position.x = (-Floor.DistanceToNextCollumn * (Force - CompressinRatio) / countChildrensCastingObj) * (i) * 1.1
							Global.DIRECTION.FORWARD: CastingObj.get_children()[i].position.z = (-Floor.DistanceToNextCollumn * (Force - CompressinRatio) / countChildrensCastingObj) * (i) * 1.1
		else:
			#for obj in CastingObj.get_children(): obj.position = Vector3.ZERO
			CastingObj.visible = false
				
				

func move():
	moving = true
	rdParticles.emitting = true
	set_physics_process(false)
	MovingStarted.emit()
	lastPosition = position
	match Floor.NextCollumnAt:
		Global.DIRECTION.LEFT:
			nextPosition = position + Vector3(-Floor.DistanceToNextCollumn, 0, 0) * (Force - CompressinRatio)
			nextRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(180))
		Global.DIRECTION.FORWARD:
			nextPosition = position + Vector3(0, 0, -Floor.DistanceToNextCollumn) * (Force - CompressinRatio)
			nextRotation = rdMesh.rotation + Vector3(deg_to_rad(-180),0,0)
		Global.DIRECTION.RIGHT:
			nextPosition = position + Vector3(Floor.DistanceToNextCollumn, 0, 0) * (Force - CompressinRatio)
			nextRotation = rdMesh.rotation + Vector3(0,0,deg_to_rad(-180))
	lastRotation = rdMesh.rotation
	var movingTween := create_tween().tween_method(_curve_move, 0.0, 1.0, JumpTime * (1 - CompressinRatio))
	await get_tree().create_timer(JumpTime * (1 - CompressinRatio) * 0.9).timeout
	rdParticles.emitting = false
	await get_tree().create_timer(JumpTime * (1 - CompressinRatio) * 0.1).timeout
	CountJump += 1
	set_physics_process(true)
	MovingFinished.emit()
	CompressinRatio = 1
	moving = false
	
func _curve_move(alpha : float):
	position = lerp(lastPosition, nextPosition, alpha)
	position.y = lastPosition.y + JumpCurve.sample(alpha) * MaxJump * (1 - CompressinRatio)
	rdMesh.rotation = lerp(lastRotation, nextRotation, alpha)

func dead():
	if CountJump < 2:
		await get_tree().create_timer(1).timeout
		_on_game_reload()
	else:
		isDead = true
		Global.GameStop.emit()

func _on_game_start():
	CanCastTraectory = true

func _on_game_resumed():
	position = lastPosition + Vector3(0, 1, 0)
	isDead = false
	

func _on_game_reload():
	create_tween().tween_property(rdRoot, "scale", Vector3.ZERO, 0.1)
	await get_tree().create_timer(0.1).timeout
	position = StartPosition
	isDead = false
	CountJump = 0
	create_tween().tween_property(rdRoot, "scale", Vector3(1, 1, 1), 0.2)
	await get_tree().create_timer(0.2).timeout 

func _on_game_stop():
	pass


func _on_area_body_entered(body: Node3D) -> void:
	if body is Collumn:
		Floor = body
		if CountJump >= 1:
			body.emitParticles(position - body.position)
		
			body._show_number()
			body._vertical_shake()
			Global.CountTouchesCollumn += 1
			Global.PlayerOnCollumn.emit()
	else:
		Floor = null

func _on_area_body_exited(body: Node3D) -> void:
	if body is Collumn: Floor = null
