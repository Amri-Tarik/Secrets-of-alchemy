extends RigidBody2D

export var aoe_length = 10
var CENTRAL = Vector2()
var IMPULSE = Vector2()
var CHAR_POS
var mouse_pos
var pos_burst_r
var pos_burst_l

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position

func _ready():
	mouse_pos = get_viewport().get_mouse_position()
	CHAR_POS = get_node("../Hero").transform.get_origin()
	pos_burst_r = Vector2(-30,-25) + CHAR_POS
	pos_burst_l = Vector2(-110,-25) + CHAR_POS
	var timer = Timer.new()
	self.add_child(timer)
	timer.set_wait_time(5)
	randomize()
	timer.start()
	yield(timer,"timeout")
	timer.queue_free()
	self.queue_free()


func burst(new_scale,particle,central,impulse,follow_mouse):
	var elemental = particle.instance()
	elemental.scale = new_scale
	self.add_child(elemental)
	CENTRAL = central
	if get_node("../Hero/AnimatedSprite").flip_h :
		IMPULSE = Vector2(-rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_l.direction_to(to_local(mouse_pos+Vector2(0,100))).y*5*follow_mouse )
		translate(pos_burst_l)
	else :
		IMPULSE = Vector2(rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_r.direction_to(to_local(mouse_pos+Vector2(0,100))).y*5*follow_mouse )
		translate(pos_burst_r)


func aoe(new_scale,fill_height,particle,central,impulse,k,ground,aoe_coef):
	var elemental = particle.instance()
	elemental.scale = new_scale
	self.add_child(elemental)
	translate(Vector2(mouse_pos.x + aoe_length*k - 12.5*aoe_length , ground[k].y -30 -40*fill_height) )
	CENTRAL = central
	IMPULSE = Vector2( rand_range(impulse[0],impulse[1]), rand_range(impulse[2],impulse[3]) )
	elemental.gravity = Vector2(0,-250*aoe_coef)
#	self.scale = Vector2(2,2) 
#	elemental.scale_amount = elemental.scale_amount


func _integrate_forces(_state):
	add_central_force(CENTRAL)
	apply_central_impulse(IMPULSE)
	set_inertia(1000)
