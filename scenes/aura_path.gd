extends Path2D

var spinning = 0
signal set_pos

var spin_script = preload("res://GDScript/spinning.gd")

func _ready():
	get_node("../..").connect("aura",self,"spin_elements")

func spin_elements(atom,particle,aurascale,layer_bit):
	if spinning == 0:
		spinning = 1
		for k in get_curve().get_point_count():
			var aura_path = PathFollow2D.new()
			aura_path.set_script(spin_script)
			aura_path.set_rotate(false)
			add_child(aura_path)
			var elemental = atom.instance()
			aura_path.add_child(elemental)
			aura_path.set_offset(k*14)
			elemental.connect("ignition",get_node("../.."),"ignite")
			elemental.aura(particle,aurascale,layer_bit)
			emit_signal("set_pos",k)
		spinning = 0
