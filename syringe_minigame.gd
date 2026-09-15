extends Control

@export var bar_sheet: Texture2D
@onready var result_label = $ResultLabel
@onready var syringe_node = $Syringe
@onready var game_over_image = $GameOverImage
@onready var attempts_label = $AttemptsLabel
@onready var timing_bar: TextureRect = $TimingBar
@onready var indicator: TextureRect = $TimingBar/Indicator
@onready var target_zone: Control = $TimingBar/TargetZone

const SOURCE_BAR_SIZE := Vector2(198, 20)

const BAR_REGIONS := [
	Rect2(1, 0, 198, 20),
	Rect2(201, 0, 198, 20),
	Rect2(401, 0, 198, 20)
]

const TARGET_RECTS := [
	Rect2(90, 0, 18, 20),
	Rect2(70, 0, 58, 20),
	Rect2(50, 0, 98, 20)
]

const BAR_ORDER := [2, 1, 0]
const MAX_ATTEMPTS := 2
const REQUIRED_HITS := 3

var bar_variants: Array[Texture2D] = []
var current_round := 0
var indicator_position := 0.0
var direction := 1.0
var indicator_speed := 180.0
var attempts_count := 0
var successful_hits := 0
var state := "AIMING"
var waiting_for_restart := false


func _ready() -> void:
	if bar_sheet == null:
		push_error("Признач PNG бара у поле Bar Sheet.")
		return

	syringe_node.play("idle")
	result_label.hide()
	game_over_image.hide()

	create_bar_variants()

	target_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_current_bar()
	update_indicator_position()
	update_attempts_label()


func create_bar_variants() -> void:
	bar_variants.clear()

	for region in BAR_REGIONS:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = bar_sheet
		atlas_texture.region = region
		bar_variants.append(atlas_texture)


func set_current_bar() -> void:
	var bar_index: int = BAR_ORDER[current_round]

	timing_bar.texture = bar_variants[bar_index]

	var target_rect: Rect2 = TARGET_RECTS[bar_index]

	var scale_x := timing_bar.size.x / SOURCE_BAR_SIZE.x
	var scale_y := timing_bar.size.y / SOURCE_BAR_SIZE.y

	target_zone.position = Vector2(
		target_rect.position.x * scale_x,
		target_rect.position.y * scale_y
	)

	target_zone.size = Vector2(
		target_rect.size.x * scale_x,
		target_rect.size.y * scale_y
	)


func _process(delta: float) -> void:
	if waiting_for_restart:
		if Input.is_action_just_pressed("interact"):
			get_tree().reload_current_scene()
		return

	if state != "AIMING":
		return

	indicator_position += direction * indicator_speed * delta

	var max_position := maxf(
		0.0,
		timing_bar.size.x - indicator.size.x
	)

	if indicator_position >= max_position:
		indicator_position = max_position
		direction = -1.0
	elif indicator_position <= 0.0:
		indicator_position = 0.0
		direction = 1.0

	update_indicator_position()


func update_indicator_position() -> void:
	indicator.position.x = indicator_position


func _input(event: InputEvent) -> void:
	if state == "AIMING" and event.is_action_pressed("interact"):
		check_hit()


func is_indicator_in_target_zone() -> bool:
	var indicator_hitbox := Rect2(
		Vector2(
			indicator.position.x + indicator.size.x * 0.5 - 2.0,
			0.0
		),
		Vector2(4.0, timing_bar.size.y)
	)

	var target_hitbox := Rect2(
		target_zone.position,
		target_zone.size
	)

	return indicator_hitbox.intersects(target_hitbox)


func check_hit() -> void:
	if is_indicator_in_target_zone():
		successful_hits += 1
		update_attempts_label()

		if successful_hits >= REQUIRED_HITS:
			state = "SUCCESS"
			on_success()
			return

		current_round += 1
		indicator_speed *= 1.15

		set_current_bar()

	else:
		attempts_count += 1
		indicator_speed *= 1.2

		if attempts_count >= MAX_ATTEMPTS:
			state = "FAILED"
			on_failed()


func update_attempts_label() -> void:
	attempts_label.text = str(successful_hits) + " / " + str(REQUIRED_HITS)


func on_success() -> void:
	result_label.text = "Успішно!"
	result_label.show()

	syringe_node.play("inject")

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://hatyna.tscn")


func on_failed() -> void:
	result_label.text = "Лузер"
	result_label.show()
	game_over_image.show()
	waiting_for_restart = true
