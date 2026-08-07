extends CharacterBody3D

@export var Speed: float = 19.0
@export var Damage: int = 30
@export var Attack_Cooldown: float = 2.0
@export var Shooting_Range: float = 20.0
@export var Target: Node3D
@export var Arrow: PackedScene = preload("res://Scenes/Arrow.tscn")
@onready var Pathfinding: NavigationAgent3D = $Pathfinding
@onready var Bow: Node3D = $Bow
var Gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var Health: int = 100
var Cooldown_Timer: float = 0.0

func _ready() -> void:
	Pathfinding.path_desired_distance = 2.0
	Pathfinding.target_desired_distance = 0.5
	call_deferred("Actor_Setup")
	Find_Local_Player()

func _process(delta: float) -> void:
	if Health <= 0:
		queue_free()
		GameManager.Enemies_Killed += 1

func Actor_Setup() -> void:
	await get_tree().physics_frame
	Set_Movement_Target()

func _physics_process(delta: float) -> void:
	if Cooldown_Timer > 0.0:
		Cooldown_Timer -= delta
	if !is_on_floor():
		velocity.y -= Gravity * delta
	if !is_instance_valid(Target):
		Stop_Horizontal_Movement()
		move_and_slide()
		return
	Set_Movement_Target()
	var Distance_To_Target = global_position.distance_to(Target.global_position)
	Look_At_Target(Target.global_position)
	if Distance_To_Target <= Shooting_Range && Cooldown_Timer <= 0.0:
		Shoot_Arrow()
	if Pathfinding.is_navigation_finished() || Distance_To_Target <= Shooting_Range * 0.7:
		Stop_Horizontal_Movement()
	else:
		var Next_Path_Position: Vector3 = Pathfinding.get_next_path_position()
		var Current_Position: Vector3 = global_position
		var Direction: Vector3 = Current_Position.direction_to(Next_Path_Position)
		Direction.y = 0 
		Direction = Direction.normalized()
		velocity.x = Direction.x * Speed
		velocity.z = Direction.z * Speed
	move_and_slide()

func Shoot_Arrow() -> void:
	if !Arrow || !is_instance_valid(Target):
		return
	Cooldown_Timer = Attack_Cooldown
	var Arrow_Instance = Arrow.instantiate() as Node3D
	var Target_Aim_Position = Target.global_position
	Target_Aim_Position.y += 1.0 
	get_tree().current_scene.add_child(Arrow_Instance)
	Arrow_Instance.global_position = Bow.global_position
	Arrow_Instance.look_at(Target_Aim_Position, Vector3.UP)

func Look_At_Target(Target_Position: Vector3) -> void:
	var Look_Position: Vector3 = Vector3(Target_Position.x, global_position.y, Target_Position.z)
	if global_position.distance_squared_to(Look_Position) > 0.001:
		look_at(Look_Position, Vector3.UP)

func Set_Movement_Target() -> void:
	if is_instance_valid(Target):
		Pathfinding.target_position = Target.global_position

func Stop_Horizontal_Movement() -> void:
	velocity.x = move_toward(velocity.x, 0, Speed)
	velocity.z = move_toward(velocity.z, 0, Speed)

func Find_Local_Player():
	for target in get_tree().get_nodes_in_group("Player"):
		if target.is_multiplayer_authority():
			Target = target
			break

func Take_Damage(Amount: int, Knockback: Vector3 = Vector3.ZERO) -> void:
	Health -= Amount
	if Knockback != Vector3.ZERO:
		velocity += Knockback
