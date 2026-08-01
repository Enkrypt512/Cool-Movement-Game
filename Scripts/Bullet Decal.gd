extends Sprite3D

@onready var Fade_Timer: Timer = $Timer

func _ready() -> void:
	Fade_Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
