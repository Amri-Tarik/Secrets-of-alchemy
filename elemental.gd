extends RigidBody2D

export var aoe_length = 10
var CENTRAL = Vector2()
var IMPULSE = Vector2()
var ground
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
	timer.set_wait_time(3.5)
	randomize()
	timer.start()
	yield(timer,"timeout")
	timer.queue_free()
	self.queue_free()


func burst(particle,central,impulse):
	var elemental = particle.instance()
	self.add_child(elemental)
	CENTRAL = central
	if get_node("../Hero/AnimatedSprite").flip_h :
		IMPULSE = Vector2(-rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_l.direction_to(to_local(mouse_pos+Vector2(0,100))).y*5 )
		translate(pos_burst_l)
	else :
		IMPULSE = Vector2(rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_r.direction_to(to_local(mouse_pos+Vector2(0,100))).y*5 )
		translate(pos_burst_r)


func aoe(particle,k,ground):
	var elemental = particle.instance()
	self.add_child(elemental)
	translate(Vector2(mouse_pos.x + aoe_length*k - 12.5*aoe_length,ground[k].y - 30) )
	CENTRAL = Vector2(0,0)
	IMPULSE = Vector2(rand_range(-1,1),0)
	elemental.scale_amount = 2
	elemental.gravity = Vector2(0,-500)
#	self.scale = Vector2(2,2) 


func _integrate_forces(state):
	add_central_force(CENTRAL)
	apply_central_impulse(IMPULSE)
	set_inertia(1000)
