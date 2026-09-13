extends CharacterBody2D

const MAX_SPEED = 300.1

var target_speed = Vector2.ZERO     
var current_speed = Vector2.ZERO     
var koeficient_iteracii = 0.05             
var syla_dreyfa = Vector2.ZERO  

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D 
var maximum_displacement = 150.0   

func _physics_process(delta):
	var direction = Input.get_vector("move_left ", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		target_speed = direction.normalized() * MAX_SPEED
	else:
		target_speed = Vector2.ZERO
	
	current_speed = current_speed.lerp(target_speed, koeficient_iteracii)
	
	var noise = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * syla_dreyfa
	velocity = current_speed + noise
	

	if direction != Vector2.ZERO:
		animated_sprite.play("hotbya")
			
	else: 
		animated_sprite.play("Spokiy")
	
	
	move_and_slide() 
	
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction_pos = mouse_pos - global_position  
	var shift = direction_pos.limit_length(maximum_displacement)
	camera.offset = camera.offset.lerp(shift, 0.1)
	animated_sprite.look_at(mouse_pos)
	animated_sprite.rotation += PI / 2
