extends Node3D

@onready var Body_Detection: Area3D = $"Body Detection"
@export var Knife_Damage: int = 20

func _ready() -> void:
	Body_Detection.body_entered.connect(On_Body_Entered)
	Body_Detection.monitoring = false

func Swing_Knife() -> void:
	if !visible:
		return
	Body_Detection.monitoring = true
	await get_tree().create_timer(0.2).timeout
	Body_Detection.monitoring = false

func On_Body_Entered(Body: Node) -> void:
	if !visible:
		return
	var Local_Player = get_multiplayer_authority()
	if Body.is_multiplayer_authority() && Body.name == owner.name:
		return
	if Body.is_in_group("Player") or Body.is_in_group("Enemy") or Body.name == "Enemy":
		if "Health" in Body:
			Body.Health -= Knife_Damage
		elif Body.has_method("take_damage"):
			Body.take_damage(Knife_Damage)
