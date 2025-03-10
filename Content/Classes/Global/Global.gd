extends Node

enum DIRECTION 
{
	LEFT,
	RIGHT,
	FORWARD,
	BACK
}

# Сторона и длинна, куда должен двигаться игрок и спавниться колоннки
var Direction : DIRECTION = DIRECTION.LEFT
var Distance : int = 3
var MaxCountCollumns : int = 10

var player : Player
