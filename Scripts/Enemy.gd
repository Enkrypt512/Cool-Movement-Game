extends CharacterBody3D

@export var Speed: float = 5.0
@export var Target: Node3D
@onready var Pathfinding: NavigationAgent3D = $Pathfinding
@onready var Collision_Detection: Area3D = $"Collision Detection"
var Gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var Health:int = 100

func _ready() -> void:
	Collision_Detection.body_entered.connect(Body_Detected)
	Pathfinding.path_desired_distance = 2.0
	Pathfinding.target_desired_distance = 0.5
	call_deferred("Actor_Setup")
	Find_Local_Player()

func _process(delta: float) -> void:
	if Health <= 0:
		queue_free()

func Actor_Setup() -> void:
	await get_tree().physics_frame
	Set_Movement_Target()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= Gravity * delta
	
	if not is_instance_valid(Target):
		Stop_Horizontal_Movement()
		move_and_slide()
		return
	
	Set_Movement_Target()
	if Pathfinding.is_navigation_finished():
		Stop_Horizontal_Movement()
		move_and_slide()
		return
	
	var Next_Path_Position: Vector3 = Pathfinding.get_next_path_position()
	var Current_Position: Vector3 = global_position
	var Direction: Vector3 = Current_Position.direction_to(Next_Path_Position)
	Direction.y = 0 
	Direction = Direction.normalized()
	velocity.x = Direction.x * Speed
	velocity.z = Direction.z * Speed
	if Direction.length_squared() > 0.01:
		var Look_Target := Vector3(Next_Path_Position.x, global_position.y, Next_Path_Position.z)
		look_at(Look_Target, Vector3.UP)
	move_and_slide()

func Set_Movement_Target() -> void:
	if is_instance_valid(Target):
		Pathfinding.target_position = Target.global_position

func Stop_Horizontal_Movement() -> void:
	velocity.x = move_toward(velocity.x, 0, Speed)
	velocity.z = move_toward(velocity.z, 0, Speed)

func Find_Local_Player():
	for target in get_tree().get_nodes_in_group("Player"):
		if target.is_multiplayer_authority():
			Target = target as CharacterBody3D
			break

func Body_Detected(Body):
	if Body.is_in_group("Player") or Body.name == "Player":
		if "Health" in Body:
			Body.Health -= 30
