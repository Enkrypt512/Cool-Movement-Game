extends FogVolume

@export var Target_Size: Vector3 = Vector3(25.0, 25.0, 25.0)
@export var Expand_Duration: float = 2.0
@export var Lifetime: float = 15.0
@export var Fade_Duration: float = 10.0

func _ready() -> void:
	if !material:
		material = FogMaterial.new()
	size = Target_Size
	material.density = 0.0
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(material, "density", 3.0, Expand_Duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_interval(Lifetime)
	tween.set_parallel(true)
	tween.tween_property(material, "density", 0.0, Fade_Duration).set_trans(Tween.TRANS_LINEAR)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
