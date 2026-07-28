extends Node3D

@export var Speed: float = 80.0
@export var Lifetime: float = 4.0
@onready var Collision_Detection: Area3D = $"Collision Detection"

var Damage: int = 10
var Gun_Type: String = ""
var Time_Alive: float = 0.0

func _ready() -> void:
	if Collision_Detection:
		Collision_Detection.body_entered.connect(On_Bullet_Hit)

func _physics_process(delta: float) -> void:
	global_position += -global_transform.basis.z * Speed * delta
	Time_Alive += delta
	if Time_Alive >= Lifetime:
		queue_free()

func On_Bullet_Hit(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		return
	if "Health" in body:
		body.Health -= Damage
	queue_free()
