extends CPUParticles2D

func _ready():
	emitting = false
	yield(get_tree().create_timer(0.2), "timeout")
	emitting = true
