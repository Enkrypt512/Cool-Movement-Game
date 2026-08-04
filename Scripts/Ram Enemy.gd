extends CharacterBody3D

var Circling: bool = true
var Diving: bool = false
var Swoop_Up: bool = false

@export_group("Stats")
@export var Speed: float = 60.0
@export var Dive_Speed: float = 30.0
@export var Swoop_Speed: float = 20.0
@export var Damage: int = 25
@export var Attack_Cooldown: float = 3.0

@export_group("Flight Settings")
@export var Hover_Altitude: float = 50.0
@export var Circle_Radius: float = 200.0

var Player: Node3D = null
var Can_Damage: bool = true
var Circle_Angle: float = 0.0
@onready var Collision_Detection: Area3D = $"Collision Detection"
var Health: int = 100
var Cached_Player_Position: Vector3 = Vector3.ZERO

func _ready() -> void:
	Player = get_tree().get_first_node_in_group("Player")
	if Player:
		Cached_Player_Position = Player.global_position
	Collision_Detection.body_entered.connect(On_Body_Detected)
	Collision_Detection.area_entered.connect(On_Body_Detected)

func _physics_process(delta: float) -> void:
	if !Player:
		return
	Cached_Player_Position = Player.global_position
	if Circling:
		Circling_Around_Player(delta)
	elif Diving:
		Diving_To_Player(delta)
	elif Swoop_Up:
		Swooping_Up(delta)
	move_and_slide()
	if Can_Damage && Diving:
		for Body in Collision_Detection.get_overlapping_bodies():
			if Body.name == "Player":
				if Body.Sliding:
					Body.Sliding = false
			On_Body_Detected(Body)
		for Area in Collision_Detection.get_overlapping_areas():
			On_Body_Detected(Area)

func _process(delta: float) -> void:
	if Health <= 0:
		GameManager.Enemies_Killed += 1
		queue_free()

func Circling_Around_Player(delta: float) -> void:
	Circle_Angle += delta * (Speed / Circle_Radius)
	var Target_X: float = Cached_Player_Position.x + cos(Circle_Angle) * Circle_Radius
	var Target_Z: float = Cached_Player_Position.z + sin(Circle_Angle) * Circle_Radius
	var Target_Y: float = Cached_Player_Position.y + Hover_Altitude
	var Target_Position: Vector3 = Vector3(Target_X, Target_Y, Target_Z)
	var Direction: Vector3 = (Target_Position - global_position).normalized()
	velocity = Direction * Speed
	Smooth_Look_At(global_position + velocity)
	if Can_Damage:
		Dive()

func Dive() -> void:
	Circling = false
	Diving = true
	Swoop_Up = false

func Diving_To_Player(_delta: float) -> void:
	var Live_Target: Vector3 = Cached_Player_Position
	var Direction: Vector3 = (Live_Target - global_position).normalized()
	velocity = Direction * Dive_Speed
	Smooth_Look_At(global_position + velocity)
	if is_on_floor() || is_on_wall():
		Start_Swoop_Up()

func Start_Swoop_Up() -> void:
	Circling = false
	Diving = false
	Swoop_Up = true

func Swooping_Up(_delta: float) -> void:
	var Away_Direction: Vector3 = (global_position - Cached_Player_Position)
	Away_Direction.y = 0.0
	Away_Direction = Away_Direction.normalized()
	var Target_Direction: Vector3 = (Away_Direction + Vector3.UP).normalized()
	velocity = Target_Direction * Swoop_Speed
	Smooth_Look_At(global_position + velocity)
	if global_position.y >= Cached_Player_Position.y + Hover_Altitude:
		Circling = true
		Diving = false
		Swoop_Up = false
		Start_Cooldown()

func Smooth_Look_At(Target: Vector3) -> void:
	if global_position.distance_to(Target) > 0.1:
		look_at(Target, Vector3.UP)

func On_Body_Detected(Node_Hit: Node) -> void:
	if !Can_Damage:
		return
	var Hit_Target: Node = Node_Hit
	while Hit_Target && !Hit_Target.is_in_group("Player"):
		Hit_Target = Hit_Target.get_parent()
	if Hit_Target:
		Hit_Target.Take_Damage(Damage, -global_transform.basis.z * 5.0)
		GameManager.Times_Hit += 1
		GameManager.Current_Combo = 0
		Start_Cooldown()
		if Diving:
			Start_Swoop_Up()

func Start_Cooldown() -> void:
	Can_Damage = false
	await get_tree().create_timer(Attack_Cooldown).timeout
	Can_Damage = true
