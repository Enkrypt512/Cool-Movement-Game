extends RigidBody3D

@export var Smoke_Scene: PackedScene = preload("res://Scenes/Smoke.tscn")
@export var Fuse_Time: float = 2.0
@onready var SFX: AudioStreamPlayer3D = $SFX

func _ready() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = Fuse_Time
	timer.one_shot = true
	timer.timeout.connect(Detonate)
	add_child(timer)
	timer.start()

func Detonate() -> void:
	SFX.pitch_scale = randf_range(0.9,1.1)
	SFX.volume_db = linear_to_db(GameManager.Volume / 100.0)
	if Smoke_Scene:
		var Smoke_Instance = Smoke_Scene.instantiate()
		get_tree().current_scene.add_child(Smoke_Instance)
		Smoke_Instance.global_position = global_position
	queue_free()
