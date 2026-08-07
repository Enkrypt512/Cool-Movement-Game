extends VehicleBody3D

@export var Max_Steering: float = 0.5  
@export var Engine_Power: float = 300.0  
@export var Braking_Power: float = 20.0

func _physics_process(delta: float) -> void:
	var Steer_Input = Input.get_axis("Left", "Right")
	var Acceleration_Input = Input.get_axis("Backward", "Forward")
	
	if Steer_Input == 0:
		steering = move_toward(steering, 0.0, delta * 15.0)
	else:
		steering = move_toward(steering, Steer_Input * Max_Steering, delta * 10.0)
	engine_force = Acceleration_Input * Engine_Power
	
	if Input.is_action_pressed("Brake") or Input.is_action_pressed("Crouch"):
		brake = Braking_Power
	else:
		brake = 0.0
