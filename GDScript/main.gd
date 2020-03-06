extends Node2D

const atom = preload("res://scenes/elemental.tscn")

#aoe_fill = 2 is one node
var flame = { "particle" : preload("res://scenes/spark.tscn"),"burstscale" : Vector2(1,1),"aoescale" : Vector2(2,2), "centralburst" : Vector2(-1.5,-5),"impulseburst" : [4,8,0,-2],"centralaoe" : Vector2(0,0),"impulseaoe" : [-1,1,0,0], "follow_mouse" : 1, "aoe_coef" : 2, "aoe_fill" : 1 } 
var gas = { "particle" : preload("res://scenes/gas.tscn"),"burstscale" : Vector2(3,3), "aoescale" : Vector2(3,3), "centralburst" : Vector2(0,-0.5),"impulseburst" : [-0.5,0.5,-0.5,0.5],"centralaoe" : Vector2(0,-0.3),"impulseaoe" : [-0.8,0.8,0,-0.5], "follow_mouse" : 0, "aoe_coef" : 0, "aoe_fill" : 3 }

var element = [flame,gas]
var i = 0
var ground = {}
var mouse_pos
export var aoe_length = 10

signal change_element

func _ready():
# warning-ignore:return_value_discarded
	$Hero.connect("burst",self,"burst")
# warning-ignore:return_value_discarded
	$Hero.connect("aoe",self,"aoe")

func _process(_delta):
	if(Input.is_action_just_pressed("ui_switch")):
		emit_signal("change_element")
		if i :
			i = 0
		else :
			i = 1

func _physics_process(_delta):
	if(Input.is_action_just_pressed("ui_aoe")) :
		mouse_pos = get_viewport().get_mouse_position()
		for col in range(25) :
			var space_state = get_world_2d().direct_space_state
			ground[col] = space_state.intersect_ray(Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length,mouse_pos.y),Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length, 1400),[],1).position

func burst():
	for _k in range(25):
			var elemental = atom.instance()
			self.add_child(elemental)
			elemental.burst(element[i].burstscale,element[i].particle, element[i].centralburst, element[i].impulseburst, element[i].follow_mouse)

func aoe():
	yield(get_tree().create_timer(0.2),"timeout")
	for k in range(25):
		for fill_height in range(element[i].aoe_fill):
			var elemental = atom.instance()
			self.add_child(elemental)
			elemental.aoe(element[i].aoescale,fill_height,element[i].particle,element[i].centralaoe, element[i].impulseaoe,k,ground,element[i].aoe_coef)
