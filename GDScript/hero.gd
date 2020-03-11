extends KinematicBody2D

signal burst
signal aoe
signal aura
signal dash


export var SPEED = 200
var screen_size
var cast_pos = Vector2()
var velocity = Vector2()
var i = {"right" : 0, "left" : 0, "jump" : 0, "cast" : 0, "aoe" : 0,"aura" : 0, "dash" : 0}
export var GRAVITY = 10
export var JUMP_POWER = -300
export var MAX_SPEED = 400
var jumping = 0
var in_anim = 0
var cast_timer 
var aura_timer
var dash_timer
var mouse_pos
var front_dash = 0

func _ready():
	cast_timer = Timer.new()
	cast_timer.set_wait_time(0.65)
	cast_timer.set_one_shot(true)
	add_child(cast_timer)
	aura_timer = Timer.new()
	aura_timer.set_wait_time(1)
	aura_timer.set_one_shot(true)
	add_child(aura_timer)
	dash_timer = Timer.new()
	dash_timer.set_wait_time(0.3)
	dash_timer.set_one_shot(true)
	add_child(dash_timer)
	screen_size = get_viewport_rect().size

func anim_finish():
	yield($AnimatedSprite,"animation_finished")
	in_anim = 0

func get_input():
#	if in_anim:
#		yield($AnimatedSprite,"animation_finished")
	if (Input.is_action_just_pressed("ui_up") and is_on_floor() ):
		i.jump = 1
	if (Input.is_action_pressed("ui_right")):
		i.right = 1
	if (Input.is_action_pressed("ui_left")):
		i.left = 1
	if (Input.is_action_pressed("ui_burst")) and cast_timer.get_time_left() == 0 and dash_timer.get_time_left() == 0:
		cast_timer.start()
		i.cast = 1
	if (Input.is_action_just_pressed("ui_aoe"))  and cast_timer.get_time_left() == 0 and dash_timer.get_time_left() == 0:
		cast_timer.start()
		i.aoe = 1
	if (Input.is_action_just_pressed("ui_dash"))  and dash_timer.get_time_left() == 0:
		dash_timer.start()
		i.dash = 1
	if (Input.is_action_just_pressed("ui_aura"))  and aura_timer.get_time_left() == 0 and dash_timer.get_time_left() == 0:
		aura_timer.start()
		i.aura = 1
	
func _process(_delta):
	mouse_pos = get_viewport().get_mouse_position()
	get_input()
	if i.cast :
		in_anim=1
		i.cast = 0
		emit_signal("burst")
		$AnimatedSprite.play("burst_cast")
		anim_finish()
	if i.aoe :
		in_anim=1
		i.aoe = 0
		emit_signal("aoe")
		$AnimatedSprite.play("aoe_cast")
		anim_finish()
	if i.dash :
		i.dash = 0
		dash()
		var flipped = (mouse_pos.x <= global_position.x)
		for _k in range(7):
			yield(get_tree().create_timer(0.05),"timeout")
			emit_signal("dash",global_position,flipped,front_dash)
	if i.aura :
		in_anim=1
		i.aura = 0
		emit_signal("aura")
		$AnimatedSprite.play("aura_cast")
		anim_finish()

func _physics_process(_delta):
	if i.jump and dash_timer.get_time_left() == 0:
		velocity.y += JUMP_POWER
		i.jump = 0
		jumping = 1
	if i.right and dash_timer.get_time_left() == 0:
		if (is_on_floor() == true) and in_anim == 0:
			$AnimatedSprite.play("run")
		velocity.x += 1 * SPEED
		velocity.x = min(MAX_SPEED,velocity.x)
		$AnimatedSprite.flip_h = false
		i.right = 0
	elif i.left and dash_timer.get_time_left() == 0:
		if (is_on_floor() == true) and in_anim == 0:
			$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = true
		velocity.x += -1 * SPEED
		velocity.x = max(-MAX_SPEED,velocity.x)
		i.left = 0
	else:
		if dash_timer.get_time_left() == 0 :
			velocity.x = 0
		if mouse_pos is Vector2:
			if mouse_pos.x <= global_position.x :
				$AnimatedSprite.flip_h = true
			else : 
				$AnimatedSprite.flip_h = false
		
		if  (in_anim == 0) and (is_on_floor()) and (i.right == 0) and (i.left == 0):
			$AnimatedSprite.play("idle")
	
	velocity.y += GRAVITY 
	if velocity.y < 0 and is_on_floor() == false and in_anim == 0 and front_dash == 0:
		$AnimatedSprite.play("jump")
	if velocity.y > 20 and is_on_floor() == false and in_anim == 0 and front_dash == 0:
		$AnimatedSprite.play("fall")
		jumping = 0
	if (dash_timer.get_time_left() != 0) and front_dash:
		$AnimatedSprite.play("dash_front")
		
	
	velocity = move_and_slide(velocity,Vector2(0,-1),true,2)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func dash():
	velocity = global_position.direction_to(mouse_pos).normalized()*1200
	if (abs(velocity.x) > abs(velocity.y)):
		front_dash = 1
		yield(dash_timer,"timeout")
		front_dash = 0
