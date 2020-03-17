extends Area2D

var element

func trap_ready(trap_element):
	element = trap_element
# warning-ignore:return_value_discarded
	yield(get_tree().create_timer(3),"timeout")
	triggered()

func triggered():
	get_parent().call_deferred("trigger",element,global_position)
	queue_free()
