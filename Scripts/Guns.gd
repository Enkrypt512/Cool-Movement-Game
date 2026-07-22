extends Node3D

@onready var Percision: Node3D = $Percision
@onready var Glock: Node3D = $Glock
@onready var Minigun: Node3D = $Minigun
@onready var Blaster: Node3D = $Blaster
@onready var Player: CharacterBody3D = $"../../../../../.."
@onready var Gun_Animations: AnimationPlayer = $"Gun Animations"
@onready var Recoil: Node3D = $"../.."
@export var Guns: Array = []
var Current_Gun: int = 0
var Bullet = preload("res://Scenes/Bullet.tscn")
var Last_Shot_Time: float = 0.0
var Continuous_Fire_Time: float = 0.0

@export var Gun_Cooldowns = {
	"Percision": 0.3,
	"Glock": 0.25,
	"Minigun": 0.05,
	"Blaster": 0.6
}

@export var Gun_Damages = {
	"Percision": 50,
	"Glock": 20,
	"Minigun": 10,
	"Blaster": 70
}

@export var Gun_Recoils = {
	"Percision": Vector3(12.0, 0.5, 0.5),
	"Glock": Vector3(3.5, 1.5, 1.0),
	"Minigun": Vector3(5.0, 3.0, 2.0),
	"Blaster": Vector3(80.0, 0.2, 3.0)
}

@export var Gun_Recoil_Speeds = {
	"Percision": Vector2(20.0, 3.0),
	"Glock":     Vector2(18.0, 4.0),
	"Minigun":   Vector2(20.0, 2.0),
	"Blaster":   Vector2(12.0, 2.5)
}

func _ready() -> void:
	Guns = [Percision, Glock, Minigun, Blaster]

func _process(delta: float) -> void:
	if not Input.is_action_pressed("Shoot"):
		Continuous_Fire_Time = move_toward(Continuous_Fire_Time, 0.0, delta * 4.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Change Gun"):
		Current_Gun = (Current_Gun + 1) % Guns.size()
		for Gun in Guns:
			Gun.visible = false
		Guns[Current_Gun].visible = true
		Continuous_Fire_Time = 0.0

func _physics_process(delta: float) -> void:
	if Player.is_multiplayer_authority():
		if Input.is_action_pressed("Shoot"):
			var Current_Gun_Name = Guns[Current_Gun].name
			var Shoot_Cooldown = Gun_Cooldowns.get(Current_Gun_Name, 0.1)
			var Current_Time = Time.get_ticks_msec() / 1000.0
			if Current_Time - Last_Shot_Time >= Shoot_Cooldown:
				Last_Shot_Time = Current_Time
				Continuous_Fire_Time += Shoot_Cooldown
				var Bullet_Instance = Bullet.instantiate()
				get_tree().current_scene.add_child(Bullet_Instance)
				var Active_Gun = Guns[Current_Gun]
				Bullet_Instance.global_transform = Active_Gun.global_transform
				Bullet_Instance.Damage = Gun_Damages.get(Current_Gun_Name, 10)
				Bullet_Instance.Gun_Type = Current_Gun_Name
				if Gun_Animations.has_animation(str(Guns[Current_Gun].name) + " Recoil"):
					Gun_Animations.play(str(Guns[Current_Gun].name) + " Recoil")
				var Current_Recoil: Vector3 = Gun_Recoils.get(Current_Gun_Name, Vector3(2.0, 1.0, 0.5))
				var Current_Speeds: Vector2 = Gun_Recoil_Speeds.get(Current_Gun_Name, Vector2(15.0, 8.0))
				Recoil.Add_Recoil(Current_Recoil, Current_Speeds.x, Current_Speeds.y)
