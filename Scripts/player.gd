extends CharacterBody3D

# Movement variables
@export var Current_Speed: float = 5.0
@export var Walking_Speed: float = 10.0
@export var Sprinting_Speed: float = 20.0
@export var Crouching_Speed: float = 5.0
@export var Jump_Velocity: float = 4.5

# Nodes
@onready var Head: Node3D = $Neck/Head
@onready var Crouch_Detect: RayCast3D = $"Crouch Detect"
@onready var Standing_Collision_Shape: CollisionShape3D = $"Standing Collision Shape"
@onready var Crouching_Collision_Shape: CollisionShape3D = $"Crouching Collision Shape"
@onready var Neck: Node3D = $Neck
@onready var Camera: Camera3D = $Neck/Head/Eyes/Recoil/Camera3D
@onready var Eyes: Node3D = $Neck/Head/Eyes
@onready var Standing_Shape: MeshInstance3D = $"Standing Shape"
@onready var Crouching_Shape: MeshInstance3D = $"Crouching Shape"
@onready var Animations: AnimationPlayer = $Animations
@onready var Multiplayer_Synchronizer: MultiplayerSynchronizer = $"Multiplayer Synchronizer"
@onready var Speed_Lines: CanvasLayer = $"Speed Lines"

# States
var Walking: bool = false
var Sprinting: bool = false
var Crouching: bool = false
var Freelooking: bool = false
var Sliding: bool = false

# Sliding Variables
var Slide_Timer: float = 0.0
@export var Slide_Timer_Max: float = 2.0
var Slide_Vector: Vector2 = Vector2.ZERO
@export var Slide_Speed: int = 30
var Current_Slide_Speed: float = 0.0

# Headbobbing Variables
@export var Headbobbing_Sprinting_Speed: float = 22.0
@export var Headbobbing_Walking_Speed: float = 14.0
@export var Headbobbing_Crouching_Speed: float = 10.0

@export var Headbobbing_Sprinting_Intensity: float = 0.2
@export var Headbobbing_Walking_Intensity: float = 0.1
@export var Headbobbing_Crouching_Intensity: float = 0.05

var Headbobbing_Vector: Vector2 = Vector2.ZERO
var Headbobbing_Index: float = 0.0
var Headbobbing_Current_Intensity: float = 0.0

# Misc Variables
@export var Lerp_Speed: float = 10.0
var Direction: Vector3 = Vector3.ZERO
@export var Crouching_Depth: float = -0.5
@export var Freelook_Tilt_Amount: int = 10
@export var Air_Lerp_Speed: int = 3
@export var Health: int = 100
var Is_Crouching_Toggled: bool = false
var Is_Sprinting_Toggled: bool = false
@export var Camera_Tilt: int = 5 
var Last_Velocity: Vector3 = Vector3.ZERO

func _enter_tree() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())
	Setup_Camera()

func Setup_Camera() -> void:
	if is_multiplayer_authority():
		if Camera:
			Camera.make_current()
			Camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if Camera:
			Camera.current = false

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		# Mouse Look Logic
		if event is InputEventMouseMotion:
			var Yaw_Delta := deg_to_rad(-event.relative.x * GameManager.Mouse_Sensitivity)
			var Pitch_delta := deg_to_rad(-event.relative.y * GameManager.Mouse_Sensitivity)
			
			if Freelooking:
				Neck.rotate_y(Yaw_Delta)
				Neck.rotation.y = clamp(Neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
			else:
				rotate_y(Yaw_Delta)
				
			Head.rotate_x(Pitch_delta)
			Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(-89) * -1)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Input vector for movement
	var Input_Direction := Input.get_vector("Left", "Right", "Forward", "Backward")
	var Crouch_Just_Pressed := Input.is_action_just_pressed("Crouch")
	
	# Crouch Input
	if GameManager.Toggle_Crouch:
		if Crouch_Just_Pressed:
			Is_Crouching_Toggled = !Is_Crouching_Toggled
	else:
		Is_Crouching_Toggled = Input.is_action_pressed("Crouch")
		
	# Sprint Input
	if GameManager.Toggle_Sprint:
		if Input.is_action_just_pressed("Sprint"):
			Is_Sprinting_Toggled = !Is_Sprinting_Toggled
	else:
		Is_Sprinting_Toggled = Input.is_action_pressed("Sprint")
		
	# Sliding Timer Logic
	if Sliding:
		Slide_Timer -= delta
		if Slide_Timer <= 0:
			Sliding = false
			Freelooking = false
			Direction = Vector3.ZERO
			if GameManager.Toggle_Sprint:
				Is_Sprinting_Toggled = false
			if GameManager.Toggle_Crouch:
				Is_Crouching_Toggled = false
		
	# State flags
	var Should_Crouch := Is_Crouching_Toggled || Sliding
	var Should_Sprint := Is_Sprinting_Toggled && !Should_Crouch
	
	# Movement Stance Processing
	if Should_Crouch:
		Head.position.y = lerp(Head.position.y, Crouching_Depth, delta * Lerp_Speed)
		Current_Speed = lerp(Current_Speed, Crouching_Speed, delta * Lerp_Speed)
		Standing_Collision_Shape.disabled = true
		Crouching_Collision_Shape.disabled = false
		Standing_Shape.visible = false
		Crouching_Shape.visible = true
		
		# Trigger Slide
		if Is_Sprinting_Toggled && Input_Direction.y < 0 && !Sliding && (Crouch_Just_Pressed || Input.is_action_just_pressed("Sprint")): 
			Sliding = true
			Freelooking = true
			Slide_Timer = Slide_Timer_Max
			Slide_Vector = Vector2(Input_Direction.x, -1.0)
			
		Walking = false
		Sprinting = false
		Crouching = true
	elif !Crouch_Detect.is_colliding():
		Head.position.y = lerp(Head.position.y, 0.0, delta * Lerp_Speed)
		Standing_Collision_Shape.disabled = false
		Crouching_Collision_Shape.disabled = true
		Standing_Shape.visible = true
		Crouching_Shape.visible = false
		
		if Should_Sprint:
			Current_Speed = lerp(Current_Speed, Sprinting_Speed, delta * Lerp_Speed)
			Walking = false
			Sprinting = true
			Crouching = false
		else:
			Current_Speed = lerp(Current_Speed, Walking_Speed, delta * Lerp_Speed)
			Walking = true
			Sprinting = false
			Crouching = false

	if Speed_Lines:
		Speed_Lines.visible = Sliding

	# Freelooking camera tilt
	if Input.is_action_pressed("Freelook") || Sliding:
		Freelooking = true
		Camera.rotation.z = -deg_to_rad(Neck.rotation.y * Freelook_Tilt_Amount)
		if Sliding:
			Camera.rotation.z = lerp(Camera.rotation.z, -deg_to_rad(20.0), delta * 15)
	else:
		Freelooking = false
		Neck.rotation.y = lerp(Neck.rotation.y, 0.0, delta * Lerp_Speed)
		Camera.rotation.z = lerp(Camera.rotation.z, 0.0, delta * Lerp_Speed)
		
	# Headbobbing mechanics
	if not GameManager.No_Shake:
		if Sprinting:
			Headbobbing_Current_Intensity = Headbobbing_Sprinting_Intensity
			Headbobbing_Index += Headbobbing_Sprinting_Speed * delta
		elif Walking:
			Headbobbing_Current_Intensity = Headbobbing_Walking_Intensity
			Headbobbing_Index += Headbobbing_Walking_Speed * delta
		elif Crouching:
			Headbobbing_Current_Intensity = Headbobbing_Crouching_Intensity 
			Headbobbing_Index += Headbobbing_Crouching_Speed * delta
			
		if is_on_floor() && !Sliding && Input_Direction != Vector2.ZERO:
			Headbobbing_Vector.y = sin(Headbobbing_Index)
			Headbobbing_Vector.x = sin(Headbobbing_Index / 2) + 0.5
			Eyes.position.y = lerp(Eyes.position.y, Headbobbing_Vector.y * (Headbobbing_Current_Intensity / 2), delta * Lerp_Speed)
			Eyes.position.x = lerp(Eyes.position.x, Headbobbing_Vector.x * Headbobbing_Current_Intensity, delta * Lerp_Speed)
		else:
			Eyes.position.y = lerp(Eyes.position.y, 0.0, delta * Lerp_Speed)
			Eyes.position.x = lerp(Eyes.position.x, 0.0, delta * Lerp_Speed)
			Headbobbing_Vector.x = sin(Headbobbing_Index / 2) + 0.5
		
	# Strafe leaning camera tilt
	if not GameManager.No_Shake:
		if Input.is_action_pressed("Left"):
			Camera.rotation.z = lerp(Camera.rotation.z, deg_to_rad(Camera_Tilt), delta * Lerp_Speed)
		elif Input.is_action_pressed("Right"):
			Camera.rotation.z = lerp(Camera.rotation.z, deg_to_rad(-Camera_Tilt), delta * Lerp_Speed)
		else:
			Camera.rotation.z = lerp(Camera.rotation.z, 0.0, delta * Lerp_Speed)
		
	# Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Joystick/Controller Look Logic
	var Look_Direction := Input.get_vector("Camera Joystick Left", "Camera Joystick Right", "Camera Joystick Up", "Camera Joystick Down")
	if Look_Direction != Vector2.ZERO:
		var Yaw_Delta := deg_to_rad(-Look_Direction.x * GameManager.Joystick_Sensitivity * delta * 60)
		var Pitch_Delta := deg_to_rad(-Look_Direction.y * GameManager.Joystick_Sensitivity * delta * 60)
		
		if Freelooking:
			Neck.rotate_y(Yaw_Delta)
			Neck.rotation.y = clamp(Neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(Yaw_Delta)
			
		Head.rotate_x(Pitch_Delta)
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	# Handle Jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = Jump_Velocity
		if GameManager.Toggle_Crouch:
			if Sliding:
				Crouching = false 
		Sliding = false
		Freelooking = false
		
	# Direction and acceleration calculations
	if is_on_floor():
		Direction = lerp(Direction, (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized(), delta * Lerp_Speed)
	else:
		if Input_Direction != Vector2.ZERO:
			Direction = lerp(Direction, (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized(), delta * Air_Lerp_Speed)
		
	# Handle Active Sliding Mechanics
	if Sliding:
		Direction = (transform.basis * Vector3(Slide_Vector.x, 0, Slide_Vector.y)).normalized()
		Current_Speed = (Slide_Timer + 0.1) * Slide_Speed
		var Horizontal_Velocity := Vector3(velocity.x, 0, velocity.z)
		Current_Slide_Speed = Horizontal_Velocity.length()
		if Current_Slide_Speed < Crouching_Speed:
			Sliding = false
			Freelooking = false
			Current_Speed = Crouching_Speed
	
	# Apply velocities
	if Direction:
		velocity.x = Direction.x * Current_Speed
		velocity.z = Direction.z * Current_Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Current_Speed)
		velocity.z = move_toward(velocity.z, 0, Current_Speed)
		
	Last_Velocity = velocity
	move_and_slide()
