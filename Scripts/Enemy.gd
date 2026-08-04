extends CharacterBody3D

@export var Speed: float = 19.0
@export var Damage: int = 30
@export var Attack_Cooldown: float = 1.0
@export var Target: Node3D
@onready var Pathfinding: NavigationAgent3D = $Pathfinding
@onready var Collision_Detection: Area3D = $"Collision Detection"

var Gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var Health: int = 100
var Can_Damage: bool = true

func _ready() -> void:
	Collision_Detection.body_entered.connect(Body_Detected)
	Collision_Detection.area_entered.connect(Body_Detected)
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
	if !is_on_floor():
		velocity.y -= Gravity * delta
	if Can_Damage:
		for Body in Collision_Detection.get_overlapping_bodies():
			Body_Detected(Body)
		for Area in Collision_Detection.get_overlapping_areas():
			Body_Detected(Area)
	if !is_instance_valid(Target):
		Stop_Horizontal_Movement()
		move_and_slide()
		return
	Set_Movement_Target()
	if Pathfinding.is_navigation_finished():
		Stop_Horizontal_Movement()
		Look_At_Target(Target.global_position)
		move_and_slide()
		return
	var Next_Path_Position: Vector3 = Pathfinding.get_next_path_position()
	var Current_Position: Vector3 = global_position
	var Direction: Vector3 = Current_Position.direction_to(Next_Path_Position)
	Direction.y = 0 
	Direction = Direction.normalized()
	velocity.x = Direction.x * Speed
	velocity.z = Direction.z * Speed
	Look_At_Target(Target.global_position)
	move_and_slide()

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

func Body_Detected(Node_Hit):
	if !Can_Damage:
		return
	var Hit_Target: Node = Node_Hit
	while Hit_Target and not Hit_Target.is_in_group("Player") and Hit_Target.name != "Player":
		Hit_Target = Hit_Target.get_parent()
	if Hit_Target:
		if Hit_Target.has_method("Take_Damage"):
			Hit_Target.Take_Damage(Damage,Vector3(-1,0,0))
			GameManager.Times_Hit += 1
			GameManager.Current_Combo = 0
			Start_Cooldown()

func Start_Cooldown() -> void:
	Can_Damage = false
	await get_tree().create_timer(Attack_Cooldown).timeout
	Can_Damage = true

func Take_Damage(Amount: int, Knockback: Vector3 = Vector3.ZERO) -> void:
	Health -= Amount
	if Knockback != Vector3.ZERO:
		velocity += Knockback
