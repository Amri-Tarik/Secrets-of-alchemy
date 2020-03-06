extends RigidBody2D

var CENTRAL = Vector2()
var IMPULSE = Vector2()
var CHAR_POS
var mouse_pos
var pos_spark

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position

func _ready():
	mouse_pos = get_viewport().get_mouse_position()
	var timer = Timer.new()
	self.add_child(timer)
	timer.set_wait_time(3.5)
	randomize()
	timer.start()
	yield(timer,"timeout")
	timer.queue_free()
	self.queue_free()

func burst(directed_to,CHAR_POS_2):
	CHAR_POS = CHAR_POS_2
	if directed_to :
		set_right()
	else:
		set_left()

func set_right():
	var current_pos = Vector2(-30,-25) + CHAR_POS
	CENTRAL = Vector2(-1.5,-5)
	IMPULSE = Vector2(rand_range(4,8),rand_range(0,-2) + current_pos.direction_to(to_local(mouse_pos)).y*5 )
	translate(current_pos)
	

func set_left():
	var current_pos = Vector2(-110,-25) + CHAR_POS
	CENTRAL = Vector2(1.5,-5)
	IMPULSE = Vector2(rand_range(-4,-8),rand_range(0,2) + current_pos.direction_to(to_local(mouse_pos)).y*5 ) 
	translate(current_pos)
	
func aoe(k):
	translate(Vector2(mouse_pos.x + 2*k - 12.5*k,mouse_pos.y) )
	CENTRAL = Vector2(0,0)
	IMPULSE = Vector2(rand_range(-1,1),0)
	get_node("CPUParticles2D").scale_amount = 2

func _integrate_forces(state):
	add_central_force(CENTRAL)
	apply_central_impulse(IMPULSE)
	set_inertia(1000)
