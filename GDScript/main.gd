extends Node2D

const atom = preload("res://scenes/elemental.tscn")
var flame = { "particle" : preload("res://scenes/spark.tscn"), "centralburst" : Vector2(-1.5,-5),"impulseburst" : [4,8,0,-2]   }
var gas = {  }
var element = [flame,gas]
var i = 0
var ground = {}
var mouse_pos
export var aoe_length = 10

func _ready():
	$Hero.connect("burst",self,"burst")
	$Hero.connect("aoe",self,"aoe")

func _process(_delta):
	if(Input.is_action_just_pressed("ui_switch")):
		if i :
			i = 0
		else :
			i = 1

func _physics_process(_delta):
	if(Input.is_action_just_pressed("ui_aoe")) :
		mouse_pos = get_viewport().get_mouse_position()
		for col in range(25) :
			var space_state = get_world_2d().direct_space_state
			ground[col] = space_state.intersect_ray(Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length,mouse_pos.y),Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length, 1400),[],2).position

func burst():
	for _k in range(25):
			var elemental = atom.instance()
			self.add_child(elemental)
			elemental.burst(element[i].particle, element[i].centralburst, element[i].impulseburst)

func aoe():
	yield(get_tree().create_timer(0.2),"timeout")
	for k in range(25):
			var elemental = atom.instance()
			self.add_child(elemental)
			elemental.aoe(element[i].particle,k,ground)
