extends ColorRect

var elapsed_time = 0.0
var max_chaos = 15.0        
var time_to_max = 60.0      

func _process(delta):
	elapsed_time += delta
	
	var progress = min(elapsed_time / time_to_max, 1.0)   
	var current_chaos = progress * max_chaos
	
	material.set_shader_parameter("chaos", current_chaos)
