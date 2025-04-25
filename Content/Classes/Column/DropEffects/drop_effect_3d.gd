extends Sprite3D

var tween : Tween = null
var savedPosition : Vector3

func setVisible():
	savedPosition = position
	visible = true
	tween = create_tween()
	tween.tween_property(self, "scale", Vector3(2, 2, 2), 0.2)
	await get_tree().create_timer(0.2).timeout
	

func setInvisible():
	#if tween == null : visible = false
	if tween.is_running(): await tween.finished
	tween = create_tween()
	#create_tween().tween_property(self, "position", savedPosition - Vector3(0,3,0), 0.07)
	tween.tween_property(self, "modulate:a", 0, 0.2)
	await get_tree().create_timer(0.2).timeout
	visible = false
	scale = Vector3(0.1, 0.1, 0.1)
	modulate.a = 1
	position = savedPosition
	
	
	
