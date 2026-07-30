extends Node3D

@onready var Body_Detection: Area3D = $"Body Detection"

func _ready() -> void:
	Body_Detection.body_entered.connect(Knife_Entered_Body)

func Knife_Entered_Body(Body):
	if Body.is_in_group("Player") || Body.name == "Player":
		if is_multiplayer_authority():
			return
		else:
			Body.Health -= 20
	else:
		Body.Health -= 20
