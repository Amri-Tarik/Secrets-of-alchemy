extends Path2D

var spin_script = load("res://GDScript/spinning.gd")

func _ready():
	for k in get_curve().get_point_count():
		var aura_path = PathFollow2D.new()
		aura_path.set_meta("offset_value",k)
		aura_path.set_script(spin_script)
		aura_path.set_rotate(false)
		add_child(aura_path)
