extends Node3D

@export var Max_Radius: float = 300.0
@export var Expansion_Speed: float = 25.0
@export var Push_Force: float = 500.0

@onready var Shockwave: MeshInstance3D = $Shockwave
@onready var Sparks: GPUParticles3D = $Sparks
@onready var Push_Area: Area3D = $PushArea

var Current_Scale: float = 0.1
var Shockwave_Material: StandardMaterial3D

func _ready() -> void:
	if is_instance_valid(Sparks):
		Sparks.restart()
	if is_instance_valid(Shockwave) and Shockwave.get_active_material(0):
		Shockwave_Material = Shockwave.get_active_material(0).duplicate() as StandardMaterial3D
		Shockwave.set_surface_override_material(0, Shockwave_Material)

func _physics_process(delta: float) -> void:
	if Current_Scale < Max_Radius:
		Current_Scale = move_toward(Current_Scale, Max_Radius, Expansion_Speed * delta)
		Shockwave.scale = Vector3.ONE * Current_Scale
		if is_instance_valid(Push_Area):
			Push_Area.scale = Vector3.ONE * Current_Scale
		var Progress: float = Current_Scale / Max_Radius
		var Current_Alpha: float = 1.0 - Progress
		if Shockwave_Material:
			Shockwave_Material.albedo_color.a = Current_Alpha
			Shockwave_Material.emission_energy_multiplier = Current_Alpha * 12.0
		if is_instance_valid(Push_Area):
			for Body in Push_Area.get_overlapping_bodies():
				var Push_Direction: Vector3 = (Body.global_position - global_position).normalized()
				Push_Direction.y += 0.25
				if Body is CharacterBody3D:
					Body.velocity += Push_Direction.normalized() * (Push_Force * delta * 60.0)
				elif Body is RigidBody3D:
					Body.apply_central_impulse(Push_Direction.normalized() * (Push_Force * delta * 30.0))
	else:
		Cleanup_Explosion()

func Cleanup_Explosion() -> void:
	set_physics_process(false)
	if is_instance_valid(Push_Area):
		Push_Area.queue_free()
	if is_instance_valid(Sparks) and Sparks.emitting:
		await get_tree().create_timer(Sparks.lifetime).timeout
	queue_free()
