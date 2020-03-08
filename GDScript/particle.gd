extends CPUParticles2D

func _ready():
	emitting = false
# warning-ignore:return_value_discarded
	$Timer.connect("timeout",self,"emit_start")
	$Timer.start()

func emit_start():
	emitting = true
