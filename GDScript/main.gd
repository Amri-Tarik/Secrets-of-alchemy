extends Node2D

const atom = preload("res://scenes/particles/elemental.tscn")
const trap_box = preload("res://scenes/trap.tscn")

var flame = { "particle" : preload("res://scenes/particles/spark.tscn"),"burstscale" : Vector2(1.5,1.5),"aoescale" : Vector2(2.5,2.5),"aurascale" : Vector2(2,2), "centralburst" : Vector2(-1.5,-5),"impulseburst" : [4,8,0,-2],"centralaoe" : Vector2(0,0),"impulseaoe" : [-1,1,0,0], "follow_mouse" : 1, "aoe_fill" : 2, "layer_bit" : 1 } 
var gas = { "particle" : preload("res://scenes/particles/gas.tscn"),"burstscale" : Vector2(3,3), "aoescale" : Vector2(3,3),"aurascale" : Vector2(3,3), "centralburst" : Vector2(0,-0.5),"impulseburst" : [-0.5,0.5,-0.5,0.5],"centralaoe" : Vector2(0,-0.3),"impulseaoe" : [-0.8,0.8,0,-0.5], "follow_mouse" : 0, "aoe_fill" : 3, "layer_bit" : 2}
var water = { "particle" : preload("res://scenes/particles/water.tscn"),"burstscale" : Vector2(1.5,1.5), "aoescale" : Vector2(2.5,2.5),"aurascale" : Vector2(1.5,1.5), "centralburst" : Vector2(0,12),"impulseburst" : [3,6,-5,1],"centralaoe" : Vector2(0,12),"impulseaoe" : [-6,6,0,-4], "follow_mouse" : 1, "aoe_fill" : 2, "layer_bit" : 3}
var lightning = { "particle" : preload("res://scenes/particles/lightning.tscn"),"burstscale" : Vector2(0.5,0.5), "aoescale" : Vector2(1.5,1.5),"aurascale" : Vector2(1.5,1.5), "centralburst" : Vector2(0,0),"impulseburst" : [3,6,-0.1,0.1],"centralaoe" : Vector2(0,0),"impulseaoe" : [0,0,0,0], "follow_mouse" : 1, "aoe_fill" : 3, "layer_bit" : 4}
var wind = { "particle" : preload("res://scenes/particles/wind.tscn"),"burstscale" : Vector2(1,1), "aoescale" : Vector2(1.5,1.5),"aurascale" : Vector2(1.5,1.5), "centralburst" : Vector2(0,-2),"impulseburst" : [10,20,-2,2],"centralaoe" : Vector2(0,-2),"impulseaoe" : [10,20,-2,2], "follow_mouse" : 1, "aoe_fill" : 2, "layer_bit" : 5}
var earth = { "particle" : preload("res://scenes/particles/earth.tscn"),"burstscale" : Vector2(1,1), "aoescale" : Vector2(1.5,1.5),"aurascale" : Vector2(1.5,1.5), "centralburst" : Vector2(0,0),"impulseburst" : [0,7,-10,0],"centralaoe" : Vector2(0,5),"impulseaoe" : [0,0,0,0], "follow_mouse" : 1, "aoe_fill" : 1, "layer_bit" : 6}


var element = [flame,gas,water,lightning,wind,earth]
var i = 0
var earth_source
var ground = []
var mouse_pos
var CHAR_POS
var temp_ground
export var aoe_length = 10

signal change_element
signal aura
signal trap_ready

func _ready():
	for _col in range(25):
		ground.append(Vector2())
# warning-ignore:return_value_discarded
	$Hero.connect("burst",self,"burst")
# warning-ignore:return_value_discarded
	$Hero.connect("aoe",self,"aoe")
# warning-ignore:return_value_discarded
	$Hero.connect("aura",self,"aura")
# warning-ignore:return_value_discarded
	$Hero.connect("dash",self,"dash")
# warning-ignore:return_value_discarded
	$Hero.connect("trap",self,"trap")


func _process(_delta):
	if(Input.is_action_just_pressed("ui_fire")):
		i = 0
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_gas")):
		i = 1
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_water")):
		i = 2
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_lightning")):
		i = 3
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_wind")):
		i = 4
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_earth")):
		i = 5
		emit_signal("change_element",i)
	elif(Input.is_action_just_pressed("ui_switch")):
		i += 1
		if i == 6:
			i = 0
		emit_signal("change_element",i)

func _physics_process(_delta):
	mouse_pos = get_global_mouse_position()
	if (Input.is_action_just_pressed("ui_aoe")) :
		for col in range(25) :
			var space_state = get_world_2d().direct_space_state
			temp_ground = space_state.intersect_ray(Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length,mouse_pos.y),Vector2(mouse_pos.x + aoe_length*col - 12.5*aoe_length, 1400),[$Hero],1)
			if !temp_ground.has("position"):
				ground[col] = Vector2(0,0)
			else :
				ground[col] = temp_ground.position
	if ( i == 5 and (Input.is_action_just_pressed("ui_burst")) ) or (Input.is_action_just_pressed("ui_trap")):
		CHAR_POS = $Hero.transform.get_origin()
		var space_state = get_world_2d().direct_space_state
		earth_source = space_state.intersect_ray(CHAR_POS,Vector2(CHAR_POS.x, 4000),[],1).position


func burst():
	call_deferred("deferred_burst")

func deferred_burst():
	CHAR_POS = $Hero.transform.get_origin()
	for _k in range(25):
		var elemental = atom.instance()
		self.add_child(elemental)
		elemental.connect("ignition",self,"ignite")
		elemental.call_deferred("deferred_burst",mouse_pos,element[i].burstscale,element[i].particle, element[i].centralburst, element[i].impulseburst, element[i].follow_mouse,element[i].layer_bit,earth_source,CHAR_POS,0)



func aoe():
	yield(get_tree().create_timer(0.2),"timeout")
	call_deferred("deferred_aoe")
	
func deferred_aoe():
	for k in range(25):
		for fill_height in range(element[i].aoe_fill):
			var elemental = atom.instance()
			self.add_child(elemental)
			elemental.connect("ignition",self,"ignite")
			elemental.call_deferred("deferred_aoe",mouse_pos,element[i].aoescale,fill_height,element[i].particle,element[i].centralaoe, element[i].impulseaoe,k,ground,element[i].layer_bit)



func ignite(contact_pos):
	call_deferred("deferred_ignite",contact_pos)

func deferred_ignite(contact_pos):
	for _k in range(2):
		var elemental = atom.instance()
		self.add_child(elemental)
		elemental.connect("ignition",self,"ignite")
		elemental.burst_from_gas(flame.particle,contact_pos)



func aura():
	call_deferred("deferred_aura")

func deferred_aura():
	emit_signal("aura",atom,element[i].particle,element[i].aurascale,element[i].layer_bit)



func dash(char_pos,flipped,front_dash):
	call_deferred("deferred_dash",char_pos,flipped,front_dash)

func deferred_dash(char_pos,flipped,front_dash):
	for fill_height in range(element[i].aoe_fill):
		var elemental = atom.instance()
		self.add_child(elemental)
		elemental.connect("ignition",self,"ignite")
		elemental.call_deferred("deferred_dash",char_pos,element[i].aoescale,fill_height,element[i].particle,element[i].centralburst,element[i].layer_bit,flipped,front_dash)


func trap():
	call_deferred("deferred_trap")

func deferred_trap():
	var TRAP_POS = earth_source
	var trap_element = element[i]
	var current_trap = trap_box.instance()
	var particle = element[i].particle.instance()
	add_child(current_trap)
	particle.set_one_shot(false)
	particle.scale = Vector2(2,2)
	current_trap.global_position = earth_source + Vector2(0,-10)
	current_trap.add_child(particle)
	yield(get_tree().create_timer(0.5),"timeout")
	emit_signal("trap_ready",trap_element)

func trigger(element,TRAP_POS):
	for _k in range(25):
		var elemental = atom.instance()
		self.add_child(elemental)
		elemental.connect("ignition",self,"ignite")
		elemental.call_deferred("deferred_trap",element.burstscale,element.particle,element.centralburst,element.layer_bit,earth_source,TRAP_POS) 
