extends Node3D

var Current_Rotation: Vector3 = Vector3.ZERO
var Target_Rotation: Vector3 = Vector3.ZERO
@export var Snap_Amount: float = 15.0
@export var Return_Speed: float = 3.0

func _process(delta: float) -> void:
	Target_Rotation = Target_Rotation.lerp(Vector3.ZERO, Return_Speed * delta)
	Current_Rotation = Current_Rotation.lerp(Target_Rotation, Snap_Amount * delta)
	rotation_degrees = Current_Rotation

func Add_Recoil(Recoil_Values: Vector3, Custom_Snap_Amount: float = 15.0, Custom_Return_Speed: float = 3.0) -> void:
	Snap_Amount = Custom_Snap_Amount
	Return_Speed = Custom_Return_Speed
	Target_Rotation += Vector3(
		abs(Recoil_Values.x),
		randf_range(-Recoil_Values.y, Recoil_Values.y),
		randf_range(-Recoil_Values.z, Recoil_Values.z)
	)
