extends Node3D
@export var Speed: float = 30.0
@export var Damage: int = 15
@export var Lifetime: float = 5.0
@onready var Collision_Detection: Area3D = $"Collision Detection"

func _ready() -> void:
	Collision_Detection.body_entered.connect(On_Body_Entered)
	await get_tree().create_timer(Lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_transform.origin -= global_transform.basis.z * Speed * delta

func On_Body_Entered(Body: Node3D) -> void:
	if Body.is_in_group("Enemy"):
		return
	var Hit_Target: Node = Body
	while Hit_Target && !Hit_Target.is_in_group("Player") && Hit_Target.name != "Player":
		Hit_Target = Hit_Target.get_parent()
	if Hit_Target:
		Hit_Target.Take_Damage(Damage, -global_transform.basis.z * 5.0)
		GameManager.Times_Hit += 1
		GameManager.Current_Combo = 0
		queue_free()
