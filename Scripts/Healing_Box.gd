extends Node3D

@onready var Collision_Detection: Area3D = $"Collision Detection"
@onready var Gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var Floor_Y_Position: float = 0.5

func _process(delta: float) -> void:
	if position.y > Floor_Y_Position:
		position.y -= Gravity * delta * 2	
		if position.y < Floor_Y_Position:
			position.y = Floor_Y_Position

func _ready() -> void:
	Collision_Detection.body_entered.connect(Body_Entered)

func Body_Entered(Body):
	if Body.name == "Player":
		if Body.Health >= 99:
			Body.Health += 30
		else:
			pass
		queue_free()
