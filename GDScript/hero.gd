extends KinematicBody2D

signal draw_s
signal sheat_s
signal burst
signal aoe
signal aura


var idle = 1
export var SPEED = 400
var screen_size
var cast_pos = Vector2()
var velocity = Vector2()
var i = {"right" : 0, "left" : 0, "jump" : 0, "sheat" : 0, "cast" : 0, "aoe" : 0,"aura" : 0}
export var GRAVITY = 10
export var JUMP_POWER = -300
var jumping = 0
var in_anim = 0
var cast_timer 

func _ready():
	cast_timer = Timer.new()
	cast_timer.set_wait_time(0.6)
	cast_timer.set_one_shot(true)
	add_child(cast_timer)
	screen_size = get_viewport_rect().size
# warning-ignore:return_value_discarded
	$AnimatedSprite.connect("finished_drawing",self,"draw_finish")

func draw_finish():
	yield($AnimatedSprite,"animation_finished")
	in_anim = 0

func get_input():
	if in_anim:
		yield($AnimatedSprite,"animation_finished")
	if (Input.is_action_just_pressed("ui_accept")) and cast_timer.get_time_left() == 0:
		cast_timer.start()
		i.sheat = 1
	if (Input.is_action_just_pressed("ui_up") and is_on_floor() ):
		i.jump = 1
	if (Input.is_action_pressed("ui_right")):
		i.right = 1
	if (Input.is_action_pressed("ui_left")):
		i.left = 1
	if (Input.is_action_just_pressed("ui_select")) and cast_timer.get_time_left() == 0:
		cast_timer.start()
		i.cast = 1
	if (Input.is_action_just_pressed("ui_aoe"))  and cast_timer.get_time_left() == 0:
		cast_timer.start()
		i.aoe = 1
	if (Input.is_action_just_pressed("ui_aura"))  and cast_timer.get_time_left() == 0:
		cast_timer.start()
		i.aura = 1
	
func _process(_delta):
	get_input()
	if i.sheat and (idle == 1) :
		i.sheat = 0
		idle = 2
		in_anim = 1
		emit_signal("draw_s")
	elif i.sheat and (idle == 2) :
		i.sheat = 0
		idle = 1
		in_anim = 1
		emit_signal("sheat_s")
	if i.cast :
		in_anim=1
		i.cast = 0
		emit_signal("burst")
		$AnimatedSprite.play("cast")
		draw_finish()
	if i.aoe :
		in_anim=1
		i.aoe = 0
		emit_signal("aoe")
		$AnimatedSprite.play("aoe_cast")
		draw_finish()
	if i.aura :
		in_anim=1
		i.aura = 0
		emit_signal("aura")
		$AnimatedSprite.play("aura_cast")
		draw_finish()

func _physics_process(_delta):
	if i.jump :
		velocity.y += JUMP_POWER
		i.jump = 0
		jumping = 1
	if i.right:
		if (is_on_floor() == true) and in_anim == 0:
			$AnimatedSprite.play("run")
		velocity.x = 1
		$AnimatedSprite.flip_h = false
		i.right = 0
	elif i.left:
		if (is_on_floor() == true) and in_anim == 0:
			$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = true
		velocity.x = -1
		i.left = 0
	else:
		velocity.x = 0
		if  (in_anim == 0) and (is_on_floor()) and (i.right == 0) and (i.left == 0):
			if get_viewport().get_mouse_position().x <= global_position.x :
				$AnimatedSprite.flip_h = true
			else : 
				$AnimatedSprite.flip_h = false
			if (idle==1) :
				$AnimatedSprite.play("idle1")
			elif (idle==2) :
				$AnimatedSprite.play("idle2")
	if velocity.y < 0 and jumping:
		$AnimatedSprite.play("jump")
	if velocity.y > 20 and is_on_floor() == false:
		$AnimatedSprite.play("fall")
		jumping = 0
	
	velocity.y += GRAVITY
	velocity.x = velocity.x * SPEED
	
	velocity = move_and_slide(velocity,Vector2(0,-1),true,2)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func play_draw():
	emit_signal("draw_done")

func play_sheat():
	emit_signal("sheat_done")
