extends CPUParticles2D

var lightning_texture = preload("res://scenes/particles/Ressources/lightning.tres")
#var lightning_script = load("res://GDScript/lightning_script.gd")

func _ready():
	set_texture(lightning_texture.duplicate())
	lightning_texture.set_script(load("res://GDScript/lightning_script.gd"))
	emitting = false
# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"emit_start")
	$Timer.start()

func emit_start():
	emitting = true
