extends Area2D

var element

func _ready():
	get_parent().connect("trap_ready",self,"trap_ready")

func trap_ready(trap_element):
	element = trap_element
	connect("body_entered",self,"triggered")

func triggered(body):
	get_parent().call_deferred("trigger",element,global_position)
	queue_free()
