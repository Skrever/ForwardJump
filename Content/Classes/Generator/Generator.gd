class_name Generator
extends Node3D



@export_category("Columns Settings")
@export var StartCollumnLocation = Vector3.ZERO
var NextCollumnLocation = Vector3.ZERO

#Буфер колонн
var Collumns: Array[Collumn]
var CollumnSpawnPosition := Vector3(0, 30, 0)

#Буффер гемов
var Gems: Array[Gem]
var SpawnGemsLocation : Vector3 = Vector3(0, 30, 0)

var leaders : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	NextCollumnLocation = StartCollumnLocation
	Global.generator = self
	Global.GameReload.connect(_on_game_reload)
	
	for i in Global.MaxCountGems : _create_gem()
	
	#Инициализация буферного массива
	for i in (Global.MaxCountCollumns + 3): _create_collumn()
	_cooking_columns()

	Global.GenerateNextCollumn.connect(_spawn_next)
	
	SDKBridge.UpdateLeaderboard.connect(func(x) : leaders = x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta: float) -> void:
	for gem in Gems:
		gem.rotation_degrees.y += 50 * delta

func _on_game_resume():
	var collumn = Collumns.front()
	Collumns.pop_front()
	collumn.reload()
	Collumns.push_back(collumn)
	

func _on_game_reload():
	var CountUsageCollumns : int = 0
	
	for collumn in Collumns:
		if collumn.Use: 
			CountUsageCollumns += 1
	
	#if (get_tree().get_first_node_in_group("Player").CountJump < 2): return
	
	for gem in Gems:
		gem.reload(SpawnGemsLocation)
	
	for collumn in Collumns:
		collumn.delete_collumn()
		collumn.position = CollumnSpawnPosition
		collumn.Use = false
		collumn.NextCollumnAt = Global.DIRECTION.LEFT
		collumn.DistanceToNextCollumn = 0
	NextCollumnLocation = Vector3.ZERO
	_cooking_columns()
	
func _cooking_columns():
	Collumns[0].position = StartCollumnLocation
	Collumns[0].Use = true
	Collumns[0].canShake = false
	#Collumns[0].rdMesh.scale = Vector3(1, 1, 1)
	Collumns[0].put_collumn()

	match randi_range(0, 2):
		0:
			await _spawn_column(Global.DIRECTION.LEFT)
			await _spawn_column(Global.DIRECTION.LEFT)
			await _spawn_column(Global.DIRECTION.FORWARD)
			await _spawn_column(Global.DIRECTION.LEFT)
		1:
			await _spawn_column(Global.DIRECTION.LEFT)
			await _spawn_column(Global.DIRECTION.FORWARD)
			await _spawn_column(Global.DIRECTION.FORWARD)
			await _spawn_column(Global.DIRECTION.LEFT)
		2:
			await _spawn_column(Global.DIRECTION.LEFT)
			await _spawn_column(Global.DIRECTION.LEFT)
			await _spawn_column(Global.DIRECTION.FORWARD)
			await _spawn_column(Global.DIRECTION.FORWARD)


	Global.CollumnGenerated.emit()
	
func _spawn_next():
	print("Spawning next")
	if Global.RandomSpawn:
		Global.Direction = randi_range(0,1)
		await _spawn_column(Global.Direction)
		await delete_column()
	else:
		print("Random spawn disabled")

func _create_collumn():
	var collumn : Collumn = load("uid://pvbtwtmqm74r").instantiate() #инитим коллонну
	collumn.position = CollumnSpawnPosition
	add_child(collumn)
	collumn.delete_collumn()
	Collumns.append(collumn)
	
func _spawn_column(direction_ : Global.DIRECTION):
	var ReplacedCollumn : Collumn = null
	for it in Collumns:
		if (!it.Use):
			ReplacedCollumn = it
			break
			
	#print(" --------> Next Column is: ", ReplacedCollumn, " in pos: ", ReplacedCollumn.position)
	
	var rand_direction_next_collumn = randf_range(Global.MinDistance, Global.MaxDistance)
	
	match direction_:
		Global.DIRECTION.LEFT:
			_spawn_gem(NextCollumnLocation + Vector3(-rand_direction_next_collumn/2, 6, 0))
			NextCollumnLocation.x -= rand_direction_next_collumn
		Global.DIRECTION.FORWARD:
			_spawn_gem(NextCollumnLocation + Vector3(0, 6, -rand_direction_next_collumn/2))
			NextCollumnLocation.z -= rand_direction_next_collumn
		Global.DIRECTION.RIGHT:
			NextCollumnLocation.x += rand_direction_next_collumn
		Global.DIRECTION.BACK:
			NextCollumnLocation.z += rand_direction_next_collumn
			
	ReplacedCollumn.position = NextCollumnLocation
	ReplacedCollumn.Use = true 
	Collumns.front().NextCollumnAt = direction_
	Collumns.front().DistanceToNextCollumn = ReplacedCollumn.position.distance_to(Collumns.front().position)
	Collumns.erase(ReplacedCollumn)
	ReplacedCollumn.put_collumn()
	Collumns.push_front(ReplacedCollumn)
		
func delete_column():
	Collumns.back().reload(NextCollumnLocation)


func _create_gem():
	var gem : Gem = preload("uid://d3qfqt2oemnbr").instantiate()
	add_child(gem)
	gem.position = SpawnGemsLocation
	Gems.append(gem)

func _spawn_gem(pos_ : Vector3):
	
	if randi_range(0, 5) == 1:
		for it in Gems:
			if !it.Use:
				it.spawn(pos_)
				it.Use = true
				break
