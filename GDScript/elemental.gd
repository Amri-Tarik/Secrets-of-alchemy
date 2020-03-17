extends RigidBody2D

var steam_grad = preload("res://scenes/particles/Ressources/steam.tres")
var magma_grad = preload("res://scenes/particles/Ressources/magma.tres")
var earth_grad = preload("res://scenes/particles/Ressources/earth.tres")
var water_grad = preload("res://scenes/particles/Ressources/water_grad.tres")
var ice_grad = preload("res://scenes/particles/Ressources/ice_grad.tres")
var water_physics = preload("res://scenes/particles/Ressources/water.tres")
var normal_physics = preload("res://scenes/particles/Ressources/friction_normal.tres")
var lightning = preload("res://scenes/particles/lightning.tscn")


export var aoe_length = 10
var CENTRAL = Vector2()
var IMPULSE = Vector2()
var mouse_pos
var pos_burst_r
var pos_burst_l


var aura_shape = 0
var no_forces = 0
var steam = 0
var electrified = false
var magma = 0
var frozen = 0

signal ignition

var timer

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position

func _ready():
	set_mode(RigidBody2D.MODE_CHARACTER)
	timer = Timer.new()
	self.add_child(timer)
	timer.set_one_shot(true)
	timer.set_wait_time(7)
	randomize()
	timer.start()
	yield(timer,"timeout")
	timer.queue_free()
	self.queue_free()




func burst(mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit,ground,char_pos):
	call_deferred("deferred_burst",mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit,ground,char_pos)

func deferred_burst(mouse,new_scale,particle,central,impulse,follow_mouse,layer_bit,ground,char_pos):
	if layer_bit == 6:
		pos_burst_l = Vector2(-50,10) + ground
		pos_burst_r = Vector2(50,10) + ground 
	else :
		pos_burst_r = Vector2(50,20) + char_pos
		pos_burst_l = Vector2(-50,20) + char_pos
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



func aoe(mouse,new_scale,fill_height,particle,central,impulse,k,ground,layer_bit):
	call_deferred("deferred_aoe",mouse,new_scale,fill_height,particle,central,impulse,k,ground,layer_bit)

func deferred_aoe(mouse,new_scale,fill_height,particle,central,impulse,k,ground,layer_bit):
	mouse_pos = mouse
	var elemental = particle.instance()
	elemental.scale = new_scale
	self.add_child(elemental)
	$hitbox.scale = Vector2(3,3)
	if layer_bit != 6:
		elemental.set_lifetime(3)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	interaction(layer_bit)
	translate(Vector2(mouse_pos.x + aoe_length*k - 12.5*aoe_length , ground[k].y -30 -40*fill_height) )
	CENTRAL = central
	IMPULSE = Vector2( rand_range(impulse[0],impulse[1]), rand_range(impulse[2],impulse[3]) )
	if layer_bit == 1:
		elemental.gravity = Vector2(0,-140)




func aura(particle,aura_scale,layer_bit):
	call_deferred("deferred_aura",particle,aura_scale,layer_bit)

func deferred_aura(particle,aura_scale,layer_bit):
	aura_shape = 1
	var elemental = particle.instance()
	self.add_child(elemental)
	elemental.scale = aura_scale
	if layer_bit != 6:
		elemental.set_lifetime(5)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	self.set_collision_mask_bit(0,false)
	if layer_bit == 5 :
		$hitbox.scale = Vector2(5,5)
	interaction(layer_bit)
	no_forces = 1




func dash(char_pos,aoescale,fill_height,particle,central,layer_bit,flipped,front_dash):
	call_deferred("deferred_dash",char_pos,aoescale,fill_height,particle,central,layer_bit,flipped,front_dash)

func deferred_dash(char_pos,aoescale,fill_height,particle,central,layer_bit,flipped,front_dash):
	var pos_modifier = 0
	var elemental = particle.instance()
	elemental.scale = aoescale
	self.add_child(elemental)
	$hitbox.scale = Vector2(1,3)
	self.set_collision_layer_bit(layer_bit,true)
	self.set_collision_mask_bit(layer_bit,false)
	interaction(layer_bit)
	if layer_bit == 6:
		$hitbox.scale = Vector2(4,3)
	if flipped and front_dash:
		pos_modifier = 50
	elif front_dash:
		pos_modifier = -50
	translate(Vector2(char_pos.x + pos_modifier , char_pos.y +30 -40*fill_height) )
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
	if ( body.get_collision_layer_bit(3) or body.get("electrified") ) :
		call_deferred("deferred_put_out")

func deferred_put_out():
	steam = 1
	if magma == 0 :
		$hitbox.disabled = true
		get_node("CPUParticles2D").set_color_ramp(steam_grad)
	else :
		get_node("CPUParticles2D").set_color_ramp(earth_grad)
	if get("aura_shape") == 0 :
		apply_central_impulse(Vector2(0,-40))




func electrify(body):
	if ( body.get("electrified") or body.get_collision_layer_bit(4) ):
		call_deferred("deferred_electrify",body)

func deferred_electrify(body):
#	body.get_node("hitbox").scale = Vector2(3,1)
	electrified = true
	if body.get("electrified") == false :
		body.queue_free()
	set_collision_layer_bit(4,true)
	set_collision_mask_bit(4,false)
	set_collision_layer_bit(3,false)
	set_collision_mask_bit(3,true)
	$hitbox.scale = Vector2(10,3)
	var particle = lightning.instance()
	particle.scale = Vector2(1.5,1.5)
	add_child(particle)



func melt(body):
	if ( body.get_collision_layer_bit(1) && body.get("steam") == 0 && magma == 0 ) :
		call_deferred("deferred_melt",body)

func deferred_melt(body):
	magma = 1
	get_node("CPUParticles2D/Area2D").queue_free()
	set_mode(RigidBody2D.MODE_CHARACTER)
	add_central_force(Vector2(rand_range(-70,70),300))
	get_node("CPUParticles2D").set_color_ramp(magma_grad)
	set_collision_layer_bit(1,true)
	set_collision_mask_bit(1,false)
	set_collision_layer_bit(6,false)
	set_collision_mask_bit(6,true)
	set_collision_mask_bit(0,true)
	if body.get("magma") == 0 :
		body.queue_free()



func wind_push(body):
	if body.get_collision_layer_bit(6) and body.get("magma") == 0 and body.get_mode() == RigidBody2D.MODE_STATIC:
		call_deferred("earth_bullet",body)
	if body.get_collision_layer_bit(3) and body.get("frozen") == 0 :
		body.call_deferred("freeze")
		call_deferred("wind_disable")
	elif body.get_collision_layer_bit(19):
		if aura_shape :
			body.wind_float()
		else :
			body.wind_push()
			call_deferred("wind_disable")
	else :
		yield(get_tree().create_timer(0.4),"timeout")
		call_deferred("wind_disable")

func wind_disable():
	$hitbox.disabled = true


func freeze():
	frozen = 1
	set_mode(RigidBody2D.MODE_STATIC)
	set_collision_mask_bit(19,true)
	no_forces = 1
	get_node("CPUParticles2D").set_color_ramp(ice_grad)
	get_node("CPUParticles2D").initial_velocity=0


func defreeze(body):
	call_deferred("deferred_defreeze",body)

func deferred_defreeze(body):
	if body.get_collision_layer_bit(1) and frozen == 1 :
		frozen = 0
		set_mode(RigidBody2D.MODE_CHARACTER)
		set_collision_mask_bit(19,false)
		no_forces = 0
		get_node("CPUParticles2D").set_color_ramp(water_grad)
		get_node("CPUParticles2D").initial_velocity=7

func earth_bullet(body):
	body.set_collision_mask_bit(0,true)
	body.set_mode(RigidBody2D.MODE_CHARACTER)
	body.set_weight(0.0001)



func interaction(layer_bit):
	if layer_bit == 1 :
		set_contact_monitor(true)
		set_max_contacts_reported(1)
# warning-ignore:return_value_discarded
		connect("body_entered",self,"check_contact")
	elif layer_bit == 3 :
		$hitbox.scale = Vector2(3,3)
		set_physics_material_override(water_physics)
		set_contact_monitor(true)
		set_max_contacts_reported(1)
# warning-ignore:return_value_discarded
		connect("body_entered",self,"check_contact")
# warning-ignore:return_value_discarded
		get_node("CPUParticles2D/Area2D").connect("body_entered",self,"defreeze")
	elif layer_bit == 4 :
		mass = 0.1
		set_contact_monitor(true)
		set_max_contacts_reported(1)
# warning-ignore:return_value_discarded
		connect("body_entered",self,"check_contact")
	elif layer_bit == 5:
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(19,true)
		set_contact_monitor(true)
		set_max_contacts_reported(1)
		connect("body_entered",self,"check_contact")
	elif layer_bit == 6:
		set_collision_mask_bit(0,false)
		set_contact_monitor(true)
		set_max_contacts_reported(1)
		yield(get_tree().create_timer(0.5),"timeout")
		set_mode(RigidBody2D.MODE_STATIC)
		no_forces = 1
# warning-ignore:return_value_discarded
		get_node("CPUParticles2D/Area2D").connect("body_entered",self,"melt")
		



func check_contact(body):
	if get_collision_layer_bit(1) and steam == 0 :
		put_out(body)
		ignite(body)
	elif get_collision_layer_bit(4) :
		ignite(body)
	elif get_collision_layer_bit(3) and electrified == false:
		electrify(body)
	elif get_collision_layer_bit(5) :
		wind_push(body)

func _integrate_forces(state):
	if no_forces == 0 :
		state.add_central_force(CENTRAL)
		state.apply_central_impulse(IMPULSE)
