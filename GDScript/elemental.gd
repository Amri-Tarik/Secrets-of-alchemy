extends RigidBody2D

var steam_grad = preload("res://scenes/particles/Ressources/steam.tres")
var water_physics = preload("res://scenes/particles/Ressources/water.tres")

export var aoe_length = 10
var CENTRAL = Vector2()
var IMPULSE = Vector2()
var CHAR_POS
var mouse_pos
var pos_burst_r
var pos_burst_l


var aura_shape = 0
var no_forces = 0
var steam = 0

signal ignition

var timer

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position

func _ready():
	timer = Timer.new()
	self.add_child(timer)
	timer.set_one_shot(true)
	timer.set_wait_time(7)
	randomize()
	timer.start()
	yield(timer,"timeout")
#	if aura_shape :
#		timer.set_wait_time(2)
#		timer.start()
#		yield(timer,"timeout")
	timer.queue_free()
	self.queue_free()




func burst(mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit):
	call_deferred("deferred_burst",mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit)

func deferred_burst(mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit):
	CHAR_POS = get_node("../Hero").transform.get_origin()
	pos_burst_r = Vector2(50,20) + CHAR_POS
	pos_burst_l = Vector2(-50,20) + CHAR_POS
	var pos_modifier_x = 0
	var pos_modifier_y = 0
	mouse_pos = mouse
	var elemental = particle.instance()
	elemental.scale = new_scale
	self.add_child(elemental)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	interaction(layer_bit)
	if layer_bit == 2 :
		pos_modifier_x = rand_range(20,120)
		pos_modifier_y = rand_range(10,60)
	if get_node("../Hero/AnimatedSprite").flip_h :
		translate( Vector2( pos_burst_l.x - pos_modifier_x, pos_burst_l.y - pos_modifier_y ) )
		IMPULSE = Vector2(-rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_l.direction_to( mouse ).y*10*follow_mouse )
		CENTRAL = central
	else :
		translate( Vector2( pos_burst_r.x + pos_modifier_x, pos_burst_r.y - pos_modifier_y ) )
		IMPULSE = Vector2(rand_range(impulse[0],impulse[1]),rand_range(impulse[2],impulse[3]) + pos_burst_r.direction_to( mouse ).y*10*follow_mouse )
		CENTRAL = central



func aoe(mouse,new_scale,fill_height,particle,central,impulse,k,ground,aoe_coef,layer_bit):
	call_deferred("deferred_aoe",mouse,new_scale,fill_height,particle,central,impulse,k,ground,aoe_coef,layer_bit)

func deferred_aoe(mouse,new_scale,fill_height,particle,central,impulse,k,ground,aoe_coef,layer_bit):
	CHAR_POS = get_node("../Hero").transform.get_origin()
	mouse_pos = mouse
	var elemental = particle.instance()
	elemental.scale = new_scale
	self.add_child(elemental)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	interaction(layer_bit)
	translate(Vector2(mouse_pos.x + aoe_length*k - 12.5*aoe_length , ground[k].y -30 -40*fill_height) )
	CENTRAL = central
	IMPULSE = Vector2( rand_range(impulse[0],impulse[1]), rand_range(impulse[2],impulse[3]) )
	elemental.gravity = Vector2(0,-250*aoe_coef)
#	self.scale = Vector2(2,2) 
#	elemental.scale_amount = elemental.scale_amount




func aura(particle,aura_scale,layer_bit):
	call_deferred("deferred_aura",particle,aura_scale,layer_bit)

func deferred_aura(particle,aura_scale,layer_bit):
	aura_shape = 1
	var elemental = particle.instance()
	self.add_child(elemental)
	elemental.scale = aura_scale
	elemental.set_lifetime(5)
#	elemental.set_gravity(Vector2(0,-10))
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	self.set_collision_mask_bit(0,false)
	interaction(layer_bit)
#	translate(spawn_pos)
	no_forces = 1




func dash(char_pos,aoescale,fill_height,particle,central,layer_bit):
	call_deferred("deferred_dash",char_pos,aoescale,fill_height,particle,central,layer_bit)

func deferred_dash(char_pos,aoescale,fill_height,particle,central,layer_bit):
	var elemental = particle.instance()
	elemental.scale = aoescale
	self.add_child(elemental)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	interaction(layer_bit)
	translate(Vector2(char_pos.x , char_pos.y +30 -40*fill_height) )
	CENTRAL = central



func ignite(body):
	if ( body.get_collision_layer_bit(2) && steam == 0 ) :
		call_deferred("deferred_ignite",body)

func deferred_ignite(body):
	body.get_node("hitbox").disabled = true
	$hitbox.disabled = true
	emit_signal("ignition",global_position)
	body.queue_free()
	queue_free()

func burst_from_gas(particle,contact_pos):
	call_deferred("deferred_burst_from_gas",particle,contact_pos)

func deferred_burst_from_gas(particle,contact_pos):
	var elemental = particle.instance()
	elemental.scale = Vector2(2,2)
	self.add_child(elemental)
	self.set_collision_layer_bit(1,true)
	self.set_collision_mask_bit(1,false)
	interaction(1)
	translate(contact_pos)
	IMPULSE = Vector2( rand_range(-3,3), rand_range(-3,3) )
	CENTRAL = Vector2(0,-5)




func put_out(body):
	if ( body.get_collision_layer_bit(1) && body.get("steam") == 0) :
		call_deferred("deferred_put_out",body)

func deferred_put_out(body):
	body.get_node("hitbox").disabled = true
	body.set("steam",1)
	body.get_node("CPUParticles2D").set_color_ramp(steam_grad)
	if body.get("aura_shape") == 0 :
		body.apply_central_impulse(Vector2(0,-40))




func interaction(layer_bit):
	if layer_bit == 1 :
		set_contact_monitor(true)
		set_max_contacts_reported(1)
# warning-ignore:return_value_discarded
		connect("body_entered",self,"ignite")
	if layer_bit == 3 :
		$hitbox.scale = Vector2(3,3)
		set_physics_material_override(water_physics)
		set_contact_monitor(true)
		set_max_contacts_reported(1)
# warning-ignore:return_value_discarded
		connect("body_entered",self,"put_out")




func _integrate_forces(_state):
	if no_forces == 0 :
		add_central_force(CENTRAL)
		apply_central_impulse(IMPULSE)
		set_inertia(10000000000)
