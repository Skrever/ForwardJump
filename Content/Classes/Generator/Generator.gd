class_name Generator
extends Node3D



@export_category("Columns Settings")
@export var StartCollumnLocation = Vector3.ZERO
var NextCollumnLocation = Vector3.ZERO

#Буфер колонн
var Collumns: Array[Collumn]
var CollumnSpawnPosition := Vector3(0, 30, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	NextCollumnLocation = StartCollumnLocation
	Global.generator = self
	Global.GameReload.connect(_on_game_reload)
	#Инициализация буферного массива
	for i in Global.MaxCountCollumns + 3: _create_collumn()
	_cooking_columns()
	
	Global.GenerateNextCollumn.connect(_spawn_next)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	
	if ((CountUsageCollumns < 5)): return
	
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

	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)

	Global.CollumnGenerated.emit()
	
func _spawn_next():
	print("Spawning next")
	if Global.RandomSpawn:
		Global.Direction = randi_range(0,1)
		_spawn_column(Global.Direction)
		delete_column()
	else:
		print("Random spawn disabled")

func _create_collumn():
	var collumn : Collumn = load("uid://pvbtwtmqm74r").instantiate() #инитим коллонну
	collumn.position = CollumnSpawnPosition
	add_child(collumn)
	collumn.delete_collumn()
	Collumns.append(collumn)
	
func _spawn_column(direction_ : Global.DIRECTION):
	var ReplacedCollumn : Collumn
	for it in Collumns:
		if (!it.Use):
			ReplacedCollumn = it
			break
	
	match direction_:
		Global.DIRECTION.LEFT:
			NextCollumnLocation.x -= randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.FORWARD:
			NextCollumnLocation.z -= randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.RIGHT:
			NextCollumnLocation.x += randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.BACK:
			NextCollumnLocation.z += randf_range(Global.MinDistance, Global.MaxDistance)
			
	ReplacedCollumn.position = NextCollumnLocation
	ReplacedCollumn.Use = true 
	Collumns.front().NextCollumnAt = direction_
	Collumns.front().DistanceToNextCollumn = ReplacedCollumn.position.distance_to(Collumns.front().position)
	Collumns.erase(ReplacedCollumn)
	ReplacedCollumn.put_collumn()
	Collumns.push_front(ReplacedCollumn)
		
func delete_column():
	Collumns.back().reload(NextCollumnLocation)
