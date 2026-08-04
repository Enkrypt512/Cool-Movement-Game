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

func On_Bullet_Hit(Body: Node) -> void:
	if Body.is_in_group("Player") || Body.name == "Player":
		if Body.is_multiplayer_authority():
			return
	if "Health" in Body:
		Body.Health -= Damage
		GameManager.Record_Shot()
	else:
		Spawn_Decal(Body)
	queue_free()

func Spawn_Decal(Target_Body: Node) -> void:
	if !Decal_Scene || Target_Body.is_in_group("Enemy") || Target_Body.is_in_group("Player"):
		return
	var Space_State: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var Travel_Dir: Vector3 = -global_transform.basis.z
	var Ray_Start: Vector3 = global_position - Travel_Dir * 2.0
	var Ray_End: Vector3 = global_position + Travel_Dir * 2.0
	var Ray_Query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Ray_Start, Ray_End)
	var Result: Dictionary = Space_State.intersect_ray(Ray_Query)
	if Result:
		var decal_Instance: Node3D = Decal_Scene.instantiate()
		Target_Body.add_child(decal_Instance)
		var Offset_Distance: float = 0.005
		decal_Instance.global_position = Result.position + (Result.normal * Offset_Distance)
		var Normal: Vector3 = Result.normal
		var Up_Vector: Vector3 = Vector3.UP if abs(Normal.dot(Vector3.UP)) < 0.99 else Vector3.FORWARD
		decal_Instance.look_at(decal_Instance.global_position + Normal, Up_Vector)
