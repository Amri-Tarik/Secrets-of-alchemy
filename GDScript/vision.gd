extends Area2D

var tracking = 0
var watch_timer
var Hero
signal track

func _ready():
	watch_timer = Timer.new()
	watch_timer.set_one_shot(true)
	add_child(watch_timer)
	watch_timer.set_wait_time(0.2)
	Hero = get_node("../../Hero")
#	watch_timer.connect("timeout",self,"watch_over")

func _process(_delta):
	if tracking == 0 :
		if get_node("../AnimatedSprite").flip_h :
			call_deferred("look_left")
		else :
			call_deferred("look_right")
	if watch_timer.get_time_left() == 0:
		watch_timer.start()
		hero_check()

func hero_check():
	if get_overlapping_bodies().find(Hero) != -1 :
		emit_signal("track",Hero.global_position)
		tracking = 1
		tracking_on()

func look_left():
	$left_col.disabled = false
	$right_col.disabled = true

func look_right():
	$left_col.disabled = true
	$right_col.disabled = false

func tracking_on():
	$left_col.set_deferred("disabled",false)
	$right_col.set_deferred("disabled",false)

func tracking_off():
	tracking = 0

