extends ColorRect

func _ready():
# warning-ignore:return_value_discarded
	get_parent().get_parent().connect("change_element",self,"active")
	color = Color("f47302")

func active(i):
	if i == 0:
		color = Color("f47302")
	elif i == 1 :
		color = Color("30f800")
	elif i == 2 :
		color = Color("208bf2")
	elif i == 3 :
		color = Color("FFFFFF")
	elif i == 4 :
		color = Color("AAAAAA")
	elif i == 5 :
		color = Color("875523")
