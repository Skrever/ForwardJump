extends Node3D

@export_category("Columns Settings")
@export var StartColumnLocation = Vector3.ZERO

#Буфер колонн
var Collumns: Array[Collumn]
var CollumnSpawnPosition := Vector3(0,30,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	#Инициализация буферного массива
	for i in Global.MaxCountCollumns + 3: _create_collumn()
	
	Collumns[0].position = StartColumnLocation
	Collumns[0].Use = true
	
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.LEFT)
	_spawn_column(Global.DIRECTION.FORWARD)
	_spawn_column(Global.DIRECTION.LEFT)
	
	Global.player.MovingFinished.connect(_spawn_next)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _spawn_next():
	if Global.RandomSpawn:
		Global.Direction = randi_range(0,1)
		_spawn_column(Global.Direction)
		delete_column()
	else:
		print("Random spawn disabled")

func _create_collumn():
	var collumn : Collumn = load("uid://pvbtwtmqm74r").instantiate() #инитим коллонну
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
			StartColumnLocation.x -= Global.Distance
			StartColumnLocation.x = floor(StartColumnLocation.x)
		Global.DIRECTION.FORWARD:
			StartColumnLocation.z -= Global.Distance
			StartColumnLocation.z = floor(StartColumnLocation.z)
		Global.DIRECTION.RIGHT:
			StartColumnLocation.x += Global.Distance
			StartColumnLocation.x = floor(StartColumnLocation.x)
		Global.DIRECTION.BACK:
			StartColumnLocation.z += Global.Distance
			StartColumnLocation.z = floor(StartColumnLocation.z)
			
	Collumn.position = StartColumnLocation
	Collumn.Use = true 
	Collumns.front().NextCollumnAt = direction_
	Collumns.erase(Collumn)
	Collumns.push_front(Collumn)
		
func delete_column():
	Collumns.back().Use = false
	Collumns.back().position = StartColumnLocation
