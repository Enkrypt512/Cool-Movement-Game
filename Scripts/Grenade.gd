extends RigidBody3D

@export_group("Grenade Parameters")
@export var Fuse_Time: float = 2.5
@export var Blast_Force: float = 20.0
@export var Max_Damage: float = 100.0
@export var Weight: float = 1.4

@onready var Blast_Area: Area3D = $"Blast Area"
@onready var Blast_Area_Collision_Shape: CollisionShape3D = $"Blast Area/Collision Shape"

func _ready() -> void:
	gravity_scale = Weight
	linear_damp = 0.1
	angular_damp = 0.5
	get_tree().create_timer(Fuse_Time).timeout.connect(Explode)
	get_tree().create_timer(Fuse_Time).timeout.connect(Explode)

func Explode() -> void:
	var Bodies = Blast_Area.get_overlapping_bodies()
	var Blast_Radius: float = 5.0
	if Blast_Area_Collision_Shape && Blast_Area_Collision_Shape.shape is SphereShape3D:
		Blast_Radius = Blast_Area_Collision_Shape.shape.radius
	for body in Bodies:
		if body == self:
			continue
		var Distance := global_position.distance_to(body.global_position)
		var Damage_Factor := clampf(1.0 - (Distance / Blast_Radius), 0.1, 1.0)
		var Damage_To_Apply := int(Max_Damage * Damage_Factor)
		var Direction = (body.global_position - global_position).normalized()
		Direction.y += 0.3
		if body is RigidBody3D:
			body.apply_central_impulse(Direction * Blast_Force * Damage_Factor)
		if body.has_method("Take_Damage"):
			var Knockback_Impulse = Direction * (Blast_Force * Damage_Factor)
			body.Take_Damage(Damage_To_Apply, Knockback_Impulse)
		elif "Health" in body:
			body.Health -= Damage_To_Apply
	# TODO: Add explosion VFX & SFX here
	queue_free()
