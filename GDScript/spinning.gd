extends PathFollow2D

var aura

#func _ready():
#	aura = get_parent()
#	aura.connect("set_pos",self,"set_pos")

func _process(delta):
	offset += 50 * delta

func set_pos(k):
	yield(get_tree().create_timer(2),"timeout")
	position = aura.get_curve().get_point_position(k)
