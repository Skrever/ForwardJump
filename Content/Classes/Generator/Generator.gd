extends Node3D

@export_category("Columns Settings")
@export var StartColumnLocation = Vector3.ZERO
@export var SpawnDistance : float = 3.0
@export var CountColumns : int

#Буфер колонн
var Collumns: Array[Collumn]
var used_columns: Array[Node]
var CollumnSpawnPosition := Vector3(0,30,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Инициализация буферного массива
	for i in Global.MaxCountCollumns + 3: _create_collumn()
	
	Collumns[0].position = StartColumnLocation
	Collumns[0].Use = true
	
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)
	
	Global.player.MovingFinished.connect(_spawn_next)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _spawn_next():
	_spawn_column(Global.Direction)
	delete_column()

func _create_collumn():
	var collumn = load("uid://pvbtwtmqm74r").instantiate() #инитим коллонну
	add_child(collumn)
	collumn.position = CollumnSpawnPosition
	Collumns.append(collumn)
	print("Creating collumn ", collumn.name, " at ", collumn.position)
	
func _spawn_column(direction_ : Global.DIRECTION):
	var Collumn
	for it in Collumns:
		if (!it.Use):
			Collumn = it
			break
	
	match direction_:
		Global.DIRECTION.LEFT:
			StartColumnLocation.x -= SpawnDistance
		Global.DIRECTION.FORWARD:
			StartColumnLocation.z -= SpawnDistance
		Global.DIRECTION.RIGHT:
			StartColumnLocation.x += SpawnDistance
		Global.DIRECTION.BACK:
			StartColumnLocation.z += SpawnDistance
			
	Collumn.position = StartColumnLocation
	Collumn.Use = true 
	Collumns.erase(Collumn)
	Collumns.push_front(Collumn)
		
func delete_column():
	Collumns.back().Use = false
	Collumns.back().position = StartColumnLocation
