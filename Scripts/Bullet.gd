extends Node3D

@export var Speed: float = 80.0
@export var Lifetime: float = 4.0
@export var Decal_Scene: PackedScene = preload("res://Scenes/Bullet Decal.tscn")
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
		if body.is_multiplayer_authority():
			return
	if "Health" in body:
		body.Health -= Damage
	else:
		_spawn_decal(body)
	queue_free()

func _spawn_decal(Target_Body: Node) -> void:
	if not Decal_Scene or Target_Body.is_in_group("Enemy") or Target_Body.is_in_group("Player"):
		return
	var Space_state = get_world_3d().direct_space_state
	var Ray_Start = global_position + global_transform.basis.z * 1.5
	var Ray_End = global_position - global_transform.basis.z * 1.5
	var Ray_Query = PhysicsRayQueryParameters3D.create(Ray_Start, Ray_End)
	var Result = Space_state.intersect_ray(Ray_Query)
	if Result:
		var decal = Decal_Scene.instantiate() as Node3D
		Target_Body.add_child(decal)
		var Offset_Distance: float = 0.005
		decal.global_position = Result.position + (Result.normal * Offset_Distance)
		var Normal = Result.normal
		var Up_Vector = Vector3.UP if abs(Normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
		decal.look_at(decal.global_position + Normal, Up_Vector)
