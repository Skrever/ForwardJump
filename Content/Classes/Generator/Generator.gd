class_name Generator
extends Node3D



@export_category("Columns Settings")
@export var StartColumnLocation = Vector3.ZERO

#Буфер колонн
var Collumns: Array[Collumn]
var CollumnSpawnPosition := Vector3(0, 30, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.generator = self
	Global.GameReload.connect(_on_reload_game)
	#Инициализация буферного массива
	for i in Global.MaxCountCollumns + 3: _create_collumn()
	_cooking_columns()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_reload_game():
	for collumn in Collumns:
		collumn.position = CollumnSpawnPosition
		collumn.Use = false
		collumn.NextCollumnAt = Global.DIRECTION.LEFT
		collumn.DistanceToNextCollumn = 0
	StartColumnLocation = Vector3.ZERO
	_cooking_columns()
	
func _cooking_columns():
	Collumns[0].position = StartColumnLocation
	Collumns[0].Use = true

	_spawn_column(Global.DIRECTION.LEFT)
	await get_tree().create_timer(1).timeout
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.FORWARD)
	_spawn_column(Global.DIRECTION.LEFT)
	
	Global.player.MovingFinished.connect(_spawn_next)
	Global.CollumnGenerated.emit()
	
func _spawn_next():
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
	Collumns.append(collumn)
	
func _spawn_column(direction_ : Global.DIRECTION):
	var ReplacedCollumn : Collumn
	for it in Collumns:
		if (!it.Use):
			ReplacedCollumn = it
			break
	
	match direction_:
		Global.DIRECTION.LEFT:
			StartColumnLocation.x -= randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.FORWARD:
			StartColumnLocation.z -= randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.RIGHT:
			StartColumnLocation.x += randf_range(Global.MinDistance, Global.MaxDistance)
		Global.DIRECTION.BACK:
			StartColumnLocation.z += randf_range(Global.MinDistance, Global.MaxDistance)
			
	ReplacedCollumn.position = StartColumnLocation
	ReplacedCollumn.Use = true 
	Collumns.front().NextCollumnAt = direction_
	Collumns.front().DistanceToNextCollumn = ReplacedCollumn.position.distance_to(Collumns.front().position)
	Collumns.erase(ReplacedCollumn)
	Collumns.push_front(ReplacedCollumn)
		
func delete_column():
	Collumns.back().Use = false
	Collumns.back().position = StartColumnLocation
