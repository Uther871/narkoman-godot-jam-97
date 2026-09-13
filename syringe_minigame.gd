extends Control

@onready var result_label = $ResultLabel
@onready var syringe_node = $Syringe
@onready var track = $Track  
@onready var hand_node = $hand
@onready var game_over_image = $GameOverImage
@onready var hold_progress_bar = $HoldProgressBar

var syringe_position = 0.0
var direction = 1
var oscillation_speed = 0.5
var target_zone_center = 0.5
var target_zone_width = 0.3
var attempts_count = 0
var max_attempts = 3
var hold_duration = 1.5
var hold_timer = 0.0
var hold_failures = 0
var max_hold_failures = 1
var state = "AIMING"
var track_start = Vector2(-50, -50)
var track_end = Vector2(120, 120)
var waiting_for_restart = false

func _ready():
	syringe_node.play("idle")
	game_over_image.visible = false
	hold_progress_bar.visible = false

func _process(delta):
	if waiting_for_restart:
		if Input.is_action_just_pressed("interact"):
			get_tree().reload_current_scene()
		return
	
	if state == "AIMING":
		syringe_position += direction * oscillation_speed * delta

		if syringe_position >= 1.0:
			syringe_position = 1.0
			direction = -1
		elif syringe_position <= 0.0:
			syringe_position = 0.0
			direction = 1

		update_syringe_position()

	elif state == "HOLDING":
		hold_progress_bar.visible = true
		hold_progress_bar.value = hold_timer
		
		if Input.is_action_pressed("interact"):
			hold_timer += delta

			if hold_timer >= hold_duration:
				state = "SUCCESS"
				on_success()
		else:
			hold_progress_bar.visible = false
			hold_failures += 1
			hold_timer = 0.0

			if hold_failures > max_hold_failures:
				state = "FAILED"
				on_failed()
			else:
				state = "AIMING"

func update_syringe_position():
	syringe_node.position = track_start.lerp(track_end, syringe_position)

func _input(event):
	if state == "AIMING" and event.is_action_pressed("interact"):
		var lower_limit = target_zone_center - target_zone_width / 2
		var upper_limit = target_zone_center + target_zone_width / 2

		if syringe_position >= lower_limit and syringe_position <= upper_limit:
			state = "HOLDING"
			hold_timer = 0.0
		else:
			attempts_count += 1
			target_zone_width *= 0.7
			oscillation_speed *= 1.15

			if attempts_count >= max_attempts:
				state = "FAILED"
				on_failed()

func on_success():
	result_label.text = "ЛРУПЦРПНВРІОЛРОВІОЛАОВЛДІРАДОАЛДВІОАЛДІВО АХПХАПХАХПАХПХАХПАХПХАХП!"
	result_label.visible = true
	syringe_node.play("inject")
	
	var tween = create_tween()
	tween.tween_property(syringe_node, "position", hand_node.position, 0.3)
	tween.tween_interval(1.0)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://hatyna.tscn"))

func on_failed():
	result_label.text = "Не пробил!"
	result_label.visible = true
	game_over_image.visible = true
	waiting_for_restart = true
