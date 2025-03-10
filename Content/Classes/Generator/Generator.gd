extends Node3D

@export_category("Columns Settings")
@export var StartColumnLocation = Vector3.ZERO
@export var SpawnDistance : float = 3.0
@export var CountColumns : int

#Буфер колонн
var columns: Array[Node]
var used_columns: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	#Спавн и инициализация первой колонны
	get_node("Column").position = StartColumnLocation
	get_node("Column").Use = true
	used_columns.append(get_node("Column"))
	columns.append(get_node("Column"))
	
	#Инициализация буферного массива
	var str_columns : String
	for i in range(2, CountColumns):
		if(get_node("Column" + str(i)) != null):
			columns.append(get_node("Column" + str(i)))
	
	#Тестовое
	spawn_column(Global.DIRECTION.LEFT)
	spawn_column(Global.DIRECTION.LEFT)
	spawn_column(Global.DIRECTION.LEFT)
	spawn_column(Global.DIRECTION.LEFT)
	delete_column()
	
	Global.player.MovingFinished.connect(_spawn_next)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _spawn_next():
	delete_column()
	spawn_column(Global.Direction)

func spawn_column(direction_ : Global.DIRECTION):
	var Column
	for it in columns:
		if (!it.Use):
			Column = it
			break
	
	match direction_:
		Global.DIRECTION.LEFT:
			StartColumnLocation.x -= SpawnDistance
			Column.position =StartColumnLocation
			Column.Use = true 
			used_columns.append(Column)
		Global.DIRECTION.FORWARD:
			StartColumnLocation.z -= SpawnDistance
			Column.position = StartColumnLocation
			Column.Use = true 
			used_columns.append(Column)
		
func delete_column():
	used_columns.front().Use = false
	used_columns.erase(used_columns.front())
