extends Camera2D

var cam_offset = Vector2()
var char_pos = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		cam_offset = event.relative*0.2

func _process(_delta):
	char_pos = to_local(get_parent().global_position)
	position = position + cam_offset
	cam_offset = Vector2()
	position.x = clamp(position.x,char_pos.x-200,char_pos.x+200)
	position.y = clamp(position.y,char_pos.y-150,char_pos.y+150)
