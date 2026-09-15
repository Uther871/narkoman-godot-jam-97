extends Control

@onready var result_label = $ResultLabel
@onready var syringe_node = $Syringe
@onready var track = $Track
@onready var hand_node = $hand
@onready var game_over_image = $GameOverImage
@onready var attempts_label = $AttemptsLabel
@onready var bar_background = $BarBackground
@onready var zone_rect = $BarBackground/ZoneRect
@onready var indicator = $BarBackground/Indicator

var syringe_position = 0.0
var direction = 1
var oscillation_speed = 0.5
var target_zone_center = 0.5
var target_zone_width = 0.3
var attempts_count = 0
var max_attempts = 3
var successful_hits = 0
var required_hits = 3
var state = "AIMING"
var track_start = Vector2(-50, -50)
var track_end = Vector2(90, 90)
var waiting_for_restart = false

func _ready():
	syringe_node.play("idle")
	game_over_image.visible = false

	update_zone_visual()
	update_indicator_position()
	update_attempts_label()

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
		update_indicator_position()


func update_syringe_position():
	syringe_node.position = track_start.lerp(track_end, syringe_position)


func update_indicator_position() -> void:
	indicator.position.x = syringe_position * bar_background.size.x


func update_zone_visual() -> void:
	var zone_left = (target_zone_center - target_zone_width / 2) * bar_background.size.x

	zone_rect.position.x = zone_left
	zone_rect.size = Vector2(
		target_zone_width * bar_background.size.x,
		zone_rect.size.y
	)

func update_attempts_label() -> void:
	attempts_label.text = str(successful_hits) + " / " + str(required_hits)

func _input(event):
	if state == "AIMING" and event.is_action_pressed("interact"):

		var lower_limit = target_zone_center - target_zone_width / 2
		var upper_limit = target_zone_center + target_zone_width / 2

		if syringe_position >= lower_limit and syringe_position <= upper_limit:
			successful_hits += 1
			update_attempts_label()

			if successful_hits >= required_hits:
				state = "SUCCESS"
				on_success()
			else:
				oscillation_speed *= 1.1

		else:
			attempts_count += 1

			target_zone_width *= 0.7
			oscillation_speed *= 1.15

			update_zone_visual()

			if attempts_count >= max_attempts:
				state = "FAILED"
				on_failed()

func on_success():
	result_label.text = "..."
	result_label.visible = true

	syringe_node.play("inject")

	var tween = create_tween()

	tween.tween_property(
		syringe_node,
		"position",
		hand_node.position,
		0.3
	)

	tween.tween_interval(1.0)

	tween.tween_callback(
		func():
			get_tree().change_scene_to_file("res://hatyna.tscn")
	)

func on_failed():
	result_label.text = "Не пробил!"
	result_label.visible = true

	game_over_image.visible = true

	waiting_for_restart = true
