extends KinematicBody2D

export var SPEED = 150
var velocity = Vector2()
export var GRAVITY = 10
export var JUMP_POWER = -300
export var MAX_SPEED = 400
var jumping = 0
var idling = 0
var idle_timer

var i = {"right" : 0, "left" : 0, "jump" : 0}

func _ready():
	randomize()
	idle_timer = Timer.new()
	idle_timer.set_one_shot(true)
	add_child(idle_timer)
	idle_timer.connect("timeout",self,"switch_idling")

func _process(_delta):
	if idling == 0 :
		i.right = 0
		i.left = 0
		idling = 1
		var direction = floor(rand_range(0,5))
		idle_timer.set_wait_time(floor(rand_range(1,4)))
		idle_timer.start()
		if direction == 0 :
			i.right = 1
		elif direction == 1:
			i.left = 1
	if  is_on_wall() :
		idling = 0
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h

func switch_idling():
	idling = 0

func _physics_process(_delta):
	if i.jump :
		velocity.y += JUMP_POWER
		i.jump = 0
		jumping = 1
	if i.right :
		if (is_on_floor() == true) :
			$AnimatedSprite.play("walk")
		velocity.x = SPEED
		$AnimatedSprite.flip_h = false
	elif i.left :
		if (is_on_floor() == true) :
			$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = true
		velocity.x = -SPEED
	else:
		velocity.x = 0
		if (is_on_floor()) and (i.right == 0) and (i.left == 0):
			$AnimatedSprite.play("idle")
	
	velocity.y += GRAVITY 
	if velocity.y < 400 and is_on_floor() == false :
		$AnimatedSprite.play("jump")
	if velocity.y > 400 and is_on_floor() == false :
		$AnimatedSprite.play("fall")
		jumping = 0
	velocity = move_and_slide(velocity,Vector2(0,-1),true,2)
