extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
var speed_rotation = 2.0

func _process(delta):
	print("player = ", player)
	if player != null:
		print("velocity = ", player.velocity.length())
		if player.velocity.length() > 0.1:
			rotation += speed_rotation * delta
