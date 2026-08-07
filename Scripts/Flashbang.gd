extends RigidBody3D

@export var Fuse_Time: float = 1.5
@export var Max_Range: float = 70.0
@onready var Sound_Effect: AudioStreamPlayer3D = $SFX
@onready var Blast_Radius: Area3D = $"Blast Radius"

func _ready() -> void:
	await get_tree().create_timer(Fuse_Time).timeout
	Explode()

func Explode() -> void:
	if Sound_Effect:
		Sound_Effect.volume_db = linear_to_db(GameManager.Volume / 100.0)
		Sound_Effect.pitch_scale = randf_range(0.9,1.1)
		Sound_Effect.play()
	for Body in Blast_Radius.get_overlapping_bodies():
		if Body is CharacterBody3D || Body.has_method("Apply_Flash"):
			Calculate_Flash_Intensity(Body)
	if Sound_Effect:
		await Sound_Effect.finished
	queue_free()

func Calculate_Flash_Intensity(Player: CharacterBody3D) -> void:
	var Distance = global_position.distance_to(Player.global_position)
	if Distance > Max_Range:
		return
	var Distance_Factor = clamp(1.0 - (Distance / Max_Range), 0.0, 1.0)
	var Space_State = get_world_3d().direct_space_state
	var Query = PhysicsRayQueryParameters3D.create(global_position, Player.global_position)
	Query.exclude = [self]
	var Result = Space_State.intersect_ray(Query)
	if Result && Result.collider != Player:
		return
	var Camera = Player.get_node_or_null("Neck/Head/Eyes/Recoil/Camera")
	var Flash_Intensity = Distance_Factor
	if Camera:
		var Player_Forward = -Camera.global_transform.basis.z
		var Direction_to_Flash = (global_position - Camera.global_position).normalized()
		var Dot_Product = Player_Forward.dot(Direction_to_Flash)
		if Dot_Product < 0:
			Flash_Intensity *= 0.5
		else:
			Flash_Intensity *= 1
	if Player.has_method("Apply_Flash"):
		Player.Apply_Flash(Flash_Intensity)
