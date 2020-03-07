extends AnimatedSprite

signal finished_drawing

func _ready():
	self.play("idle1")
# warning-ignore:return_value_discarded
	get_node("..").connect("draw_s",self,"draw_s")
# warning-ignore:return_value_discarded
	get_node("..").connect("sheat_s",self,"sheat_s")

func draw_s():
	play("draw")
	yield(self,"animation_finished")
	emit_signal("finished_drawing")

func sheat_s():
	play("sheat")
	yield(self,"animation_finished")
	emit_signal("finished_drawing")
