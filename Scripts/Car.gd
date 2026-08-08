extends VehicleBody3D

@export var Max_Steering: float = 0.65
@export var Steering_Speed: float = 3.0
@export var Engine_Power: float = 5000.0
@export var Braking_Power: float = 150.0

@onready var Body_Detection: Area3D = $"Body Detection"

func _ready() -> void:
	Body_Detection.body_entered.connect(On_Body_Detected)

func _physics_process(delta: float) -> void:
	var Steer_Input: float = Input.get_axis("Left", "Right")
	var Target_Steering: float = Steer_Input * Max_Steering
	steering = move_toward(steering, Target_Steering, Steering_Speed * delta)
	var Acceleration_Input: float = Input.get_axis("Backward", "Forward")
	var Braking: bool = Input.is_action_pressed("Brake") || Input.is_action_pressed("Crouch")
	if Braking:
		brake = Braking_Power
		engine_force = 0.0
	else:
		brake = 0.0
		engine_force = Acceleration_Input * Engine_Power

func On_Body_Detected(Body):
	if Body.is_multiplayer_authority:
		return
	if Body.is_in_group("Player") || Body.is_in_group("Enemy"):
		Body.Take_Damage(linear_velocity.length(),-global_transform.basis.z * 5.0)
