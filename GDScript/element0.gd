extends ColorRect

var a = 1

func _ready():
# warning-ignore:return_value_discarded
	get_parent().connect("change_element",self,"active")

func active():
	if a == 1:
		a = 0
		color = Color("30f800")
	else :
		a = 1
		color = Color("f47302")
