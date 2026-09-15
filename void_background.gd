extends Sprite2D

@export var palette: Array[Color] = [
	Color("00c9a7"),
	Color("480ca8"),
	Color("7209b7"),
	Color("f72585"),
	Color("ff9e7d"),
	Color("1d3557")
]

@export var transition_duration: float = 4.5

var current_index: int = 0


func _ready() -> void:
	if palette.is_empty():
		return
	
	if not material or not material is ShaderMaterial:
		return
	
	_animate_gradient()


func _animate_gradient() -> void:
	var next_top_idx = (current_index + 1) % palette.size()
	var next_bottom_idx = (current_index + 3) % palette.size()

	var target_top = palette[next_top_idx]
	var target_bottom = palette[next_bottom_idx]

	current_index = next_top_idx

	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		material,
		"shader_parameter/color_top",
		target_top,
		transition_duration
	)

	tween.tween_property(
		material,
		"shader_parameter/color_bottom",
		target_bottom,
		transition_duration
	)

	tween.chain().tween_callback(_animate_gradient)
