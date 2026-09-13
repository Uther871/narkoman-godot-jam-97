extends ColorRect

var elapsed_time = 0.0
var max_chaos = 15.0        # максимальна сила спотворення
var time_to_max = 60.0      # за скільки секунд досягне максимуму

func _process(delta):
	elapsed_time += delta
	
	var progress = min(elapsed_time / time_to_max, 1.0)   # від 0.0 до 1.0
	var current_chaos = progress * max_chaos
	
	material.set_shader_parameter("chaos", current_chaos)
