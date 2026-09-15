extends Area2D

#@onready var label = $Label
#var player_nearby = false

#func _on_body_entered(body):

#	if body.is_in_group("player"):
#		player_nearby = true
#		label.visible = true

#func _on_body_exited(body):
#		label.visible = false

#func _process(delta):
#	if player_nearby and Input.is_action_just_pressed("interact"):
#		var minigame = preload("res://шлях_до/syringe_minigame.tscn").instantiate()
#		get_tree().current_scene.add_child(minigame)
