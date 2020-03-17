extends Area2D

var element

func trap_ready(trap_element):
	element = trap_element
# warning-ignore:return_value_discarded
	connect("body_entered",self,"triggered")

func triggered(_body):
	get_parent().call_deferred("trigger",element,global_position)
	queue_free()
