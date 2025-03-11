extends Node

enum DIRECTION 
{
	LEFT,
	FORWARD,
	RIGHT,
	BACK
}

# Сторона и длинна, куда должен двигаться игрок и спавниться колоннки
var Direction : DIRECTION = DIRECTION.LEFT
var Distance : int = 7
var MaxCountCollumns : int = 10
var RandomSpawn : bool = true

var player : Player
