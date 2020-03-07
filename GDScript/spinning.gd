extends PathFollow2D

var spinning = 0
var timer
var elemental

func _ready():
# warning-ignore:return_value_discarded
	get_node("../../..").connect("aura",self,"aura")
	timer = Timer.new()
	timer.set_wait_time(9)
	timer.set_one_shot(true)
	add_child(timer)
	self.set_offset(get_meta("offset_value")*14)

func _process(delta):
	if spinning :
		offset += 50 * delta
		call_deferred("align")

func aura(atom,particle,aurascale,layer_bit):
	elemental = atom.instance()
	self.add_child(elemental)
	elemental.connect("ignition",get_node("../../.."),"ignite")
	elemental.aura(particle,aurascale,layer_bit)
	timer.start()
	spinning = 1
	yield(timer,"timeout")
	spinning = 0

func align():
	if timer.get_time_left() > 8 :
		for child in get_children():
			if child != timer :
				child.global_position = global_position
