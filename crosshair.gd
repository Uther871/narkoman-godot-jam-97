extends Node2D
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("pulsacia")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	global_position = get_global_mouse_position()
