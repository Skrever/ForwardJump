extends Node3D

enum DIRECTION 
{
LEFT,
RIGHT,
FORWARD,
BACK
}

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
	spawn_column("left")
	spawn_column("left")
	spawn_column("left")
	spawn_column("left")
	delete_column()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _spawn_next(direction: String):
	delete_column()
	spawn_column(direction)

func spawn_column(direction : String):
	var Column
	for it in columns:
		if (!it.Use):
			Column = it
			break
	
	if (direction == "left"):
		StartColumnLocation.x -= SpawnDistance
		Column.position =StartColumnLocation
		Column.Use = true 
		used_columns.append(Column)
	elif (direction == "forward"):
		StartColumnLocation.z -= SpawnDistance
		Column.position =StartColumnLocation
		Column.Use = true 
		used_columns.append(Column)
		
func delete_column():
	used_columns.front().Use = false
	used_columns.erase(used_columns.front())
