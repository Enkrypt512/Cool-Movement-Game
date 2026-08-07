extends Node3D

@onready var Percision: Node3D = $Percision
@onready var Glock: Node3D = $Glock
@onready var Minigun: Node3D = $Minigun
@onready var Blaster: Node3D = $Blaster
@onready var Knife: Node3D = $Knife
@onready var Player: CharacterBody3D = $"../../../../../.."
@onready var Gun_Animations: AnimationPlayer = $"Gun Animations"
@onready var Recoil: Node3D = $"../.."
@onready var Camera: Camera3D = $".."
@onready var Aim_Down_Sight: CanvasLayer = $"../../../../../../Aim Down Sight"
@onready var Shoot_SFX: AudioStreamPlayer3D = $"../../../../../../SFX/Shoot"
@onready var Change_Gun_SFX: AudioStreamPlayer3D = $"../../../../../../SFX/Change Gun"
@onready var Stab_SFX: AudioStreamPlayer3D = $"../../../../../../SFX/Stab"
@onready var Change_To_Knife_SFX: AudioStreamPlayer3D = $"../../../../../../SFX/Change To Knife"

var Shoot_Playback: AudioStreamPlaybackPolyphonic
@export var Shoot_Sound: AudioStream = preload("res://Assets/SFX/Shoot.wav")
var Guns: Array = []
@export var Lerp_Speed: int = 10
var Previous_Mouse_Sensitivity: int
var Current_Gun: int = 0
var Bullet: PackedScene = preload("res://Scenes/Bullet.tscn")
var Last_Shot_Time: float = 0.0
var Continuous_Fire_Time: float = 0.0

@export var Gun_Cooldowns: Dictionary = {
	"Percision": 0.3,
	"Glock": 0.25,
	"Minigun": 0.05,
	"Blaster": 3.0,
	"Knife": 0.4
}

@export var Gun_Damages: Dictionary = {
	"Percision": 50,
	"Glock": 20,
	"Minigun": 10,
	"Blaster": 70,
	"Knife": 20
}

@export var Gun_Recoils: Dictionary = {
	"Percision": Vector3(12.0, 0.5, 0.5),
	"Glock": Vector3(3.5, 1.5, 1.0),
	"Minigun": Vector3(5.0, 3.0, 2.0),
	"Blaster": Vector3(80.0, 0.2, 3.0)
}

@export var Gun_Recoil_Speeds: Dictionary = {
	"Percision": Vector2(20.0, 3.0),
	"Glock":     Vector2(18.0, 4.0),
	"Minigun":   Vector2(20.0, 2.0),
	"Blaster":   Vector2(12.0, 2.5)
}

func _ready() -> void:
	Guns = [Percision, Glock, Minigun, Blaster, Knife]
	Shoot_SFX.play()
	Shoot_Playback = Shoot_SFX.get_stream_playback()

func _process(delta: float) -> void:
	if !Input.is_action_pressed("Shoot"):
		Continuous_Fire_Time = move_toward(Continuous_Fire_Time, 0.0, delta * 4.0)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority() && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("Change Gun"):
			Current_Gun = (Current_Gun + 1) % Guns.size()
			for Gun in Guns:
				Gun.visible = false
			Guns[Current_Gun].visible = true
			Continuous_Fire_Time = 0.0
			if Guns[Current_Gun].name != "Knife":
				Change_Gun_SFX.pitch_scale = randf_range(0.9, 1.1)
				Change_Gun_SFX.volume_db = linear_to_db(GameManager.Volume / 100.0)
				Change_Gun_SFX.play()
			else:
				Change_To_Knife_SFX.pitch_scale = randf_range(0.9, 1.1)
				Change_To_Knife_SFX.volume_db = linear_to_db(GameManager.Volume / 100.0)
				Change_To_Knife_SFX.play()

func _physics_process(delta: float) -> void:
	if Player.is_multiplayer_authority():
		# Shooting
		if Input.is_action_pressed("Shoot") && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var Current_Gun_Name: String = Guns[Current_Gun].name
			var Shoot_Cooldown: float = Gun_Cooldowns.get(Current_Gun_Name, 0.1)
			var Current_Time: float = Time.get_ticks_msec() / 1000.0
			if Current_Time - Last_Shot_Time >= Shoot_Cooldown:
				Last_Shot_Time = Current_Time
				Continuous_Fire_Time += Shoot_Cooldown
				if Current_Gun_Name != "Knife":
					var Bullet_Instance: Node3D = Bullet.instantiate()
					var Active_Gun: Node3D = Guns[Current_Gun]
					get_tree().current_scene.add_child(Bullet_Instance)
					Bullet_Instance.global_transform = Active_Gun.global_transform
					Bullet_Instance.Damage = Gun_Damages.get(Current_Gun_Name, 10)
					Bullet_Instance.Gun_Type = Current_Gun_Name
					Shoot_SFX.volume_db = linear_to_db(GameManager.Volume / 100.0)
					if Shoot_Playback:
						Shoot_Playback.play_stream(Shoot_Sound, 0.0, 0.0, randf_range(0.9, 1.1))
					var Current_Recoil: Vector3 = Gun_Recoils.get(Current_Gun_Name, Vector3(2.0, 1.0, 0.5))
					var Current_Speeds: Vector2 = Gun_Recoil_Speeds.get(Current_Gun_Name, Vector2(15.0, 8.0))
					Recoil.Add_Recoil(Current_Recoil, Current_Speeds.x, Current_Speeds.y)
				Gun_Animations.play(str(Current_Gun_Name) + " Recoil")
				if Current_Gun_Name == "Knife":
					Stab_SFX.pitch_scale = randf_range(0.9, 1.1)
					Stab_SFX.volume_db = linear_to_db(GameManager.Volume / 100.0)
					Stab_SFX.play()
		# Aim Down Sight (ADS)
		if is_multiplayer_authority():
			var Current_Gun_Name: String = Guns[Current_Gun].name
			if Input.is_action_pressed("Aim Down Sight") && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED && Current_Gun_Name != "Knife":
				Camera.fov = lerp(int(Camera.fov), 20, delta * Lerp_Speed)
				Aim_Down_Sight.visible = true
				Previous_Mouse_Sensitivity = GameManager.Mouse_Sensitivity
				GameManager.Mouse_Sensitivity = Previous_Mouse_Sensitivity / 6
			else:
				Camera.fov = lerp(int(Camera.fov), 75, delta * Lerp_Speed)
				Aim_Down_Sight.visible = false
				GameManager.Mouse_Sensitivity = Previous_Mouse_Sensitivity
