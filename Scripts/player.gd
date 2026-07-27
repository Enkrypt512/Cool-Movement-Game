extends CharacterBody3D

# Movement variables
@export_group("Movment Variables")
@export var Current_Speed: float = 5.0
@export var Walking_Speed: float = 10.0
@export var Sprinting_Speed: float = 20.0
@export var Crouching_Speed: float = 5.0
@export var Jump_Velocity: float = 9.0

# Nodes
@onready var Head: Node3D = $Neck/Head
@onready var Crouch_Detect: RayCast3D = $"Crouch Detect"
@onready var Standing_Collision_Shape: CollisionShape3D = $"Standing Collision Shape"
@onready var Crouching_Collision_Shape: CollisionShape3D = $"Crouching Collision Shape"
@onready var Neck: Node3D = $Neck
@onready var Camera: Camera3D = $Neck/Head/Eyes/Recoil/Camera
@onready var Eyes: Node3D = $Neck/Head/Eyes
@onready var Standing_Shape: MeshInstance3D = $"Standing Shape"
@onready var Crouching_Shape: MeshInstance3D = $"Crouching Shape"
@onready var Animations: AnimationPlayer = $Animations
@onready var Multiplayer_Synchronizer: MultiplayerSynchronizer = $"Multiplayer Synchronizer"
@onready var Speed_Lines: CanvasLayer = $"Speed Lines"
@onready var Grapple_RayCast: RayCast3D = $"Neck/Head/Eyes/Recoil/Camera/Grappling/Grapple Ray"
@onready var Grapple_Rope: MeshInstance3D = $"Rope Mesh"

# States
var Walking: bool = false
var Sprinting: bool = false
var Crouching: bool = false
var Freelooking: bool = false
var Sliding: bool = false
var Dashing: bool = false
var Grappling: bool = false
var Wall_Gliding: bool = false

# Sliding Variables
@export_group("Sliding Variables")
var Slide_Timer: float = 0.0
@export var Slide_Timer_Max: float = 2.0
var Slide_Vector: Vector2 = Vector2.ZERO
@export var Slide_Speed: int = 30
var Current_Slide_Speed: float = 0.0

# Dash Variables
@export_group("Dash Variables")
var Dash_Timer: float = 0.0
@export var Dash_Timer_Max: float = 0.5
var Dash_Cooldown_Timer: float = 0.0
@export var Dash_Cooldown_Max: float = 0.2
var Dash_Vector: Vector2 = Vector2.ZERO
@export var Dash_Speed: float = 60.0
var Current_Dash_Speed: float = 0.0

# Headbobbing Variables
@export_group("Headbobbing Variables")
@export var Headbobbing_Sprinting_Speed: float = 22.0
@export var Headbobbing_Walking_Speed: float = 14.0
@export var Headbobbing_Crouching_Speed: float = 10.0
@export var Headbobbing_Sprinting_Intensity: float = 0.2
@export var Headbobbing_Walking_Intensity: float = 0.1
@export var Headbobbing_Crouching_Intensity: float = 0.05
var Headbobbing_Vector: Vector2 = Vector2.ZERO
var Headbobbing_Index: float = 0.0
var Headbobbing_Current_Intensity: float = 0.0

# Grapple Variables
@export_group("Grapple Variables")
@export var Grapple_Pull_Force: float = 20.0
@export var Grapple_Rope_Slack: float = 2.0
var Grapple_Point: Vector3 = Vector3.ZERO
var Grapple_Length: float = 0.0
var Grapple_Total_Angle: float = 0.0
var Grapple_Last_Direction: Vector3 = Vector3.ZERO
@export var Rope_Thickness: float = 0.08
@export var Rope_Texture: Texture2D = preload("res://Assets/textures/dev/grids/Dark/texture_07.png")

# Wall Jump Variables
@export_group("Wall Jump Variables")
@export var Wall_Jump_Velocity: float = 10.0
@export var Wall_Push_Force: float = 30.0
@export var Max_Wall_Jumps: int = 3
var Wall_Jumps_Left: int = 3
@export var Wall_Jump_Lock_Time: float = 0.2
var Wall_Jump_Lock_Timer: float = 0.0

# Wall Glide Variables
@export_group("Wall Glide Variables")
@export var Wall_Glide_Fall_Speed: float = -3.0
@export var Wall_Glide_Speed: float = 18.0
@export var Wall_Glide_Tilt_Angle: float = 8.0

# Fall Damage Variables
@export_group("Fall Damage Variables")
@export var Min_Fall_Velocity: float = 15.0
@export var Fall_Damage_Multiplier: float = 5.0

# Misc Variables
@export_group("Misc Variables")
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
@export var Max_Jumps: int = 2
var Jumps_Left: int

func _enter_tree() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	var Peer_ID := name.to_int() if name.is_valid_int() else 1
	set_multiplayer_authority(Peer_ID)
	if has_node("Multiplayer Synchronizer"):
		Multiplayer_Synchronizer.set_multiplayer_authority(Peer_ID)
	if not is_multiplayer_authority():
		set_process_unhandled_input(false)
		set_physics_process(false)
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
		if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			var Yaw_Delta := deg_to_rad(-event.relative.x * GameManager.Mouse_Sensitivity)
			var Pitch_delta := deg_to_rad(-event.relative.y * GameManager.Mouse_Sensitivity)
			if Freelooking:
				Neck.rotate_y(Yaw_Delta)
				Neck.rotation.y = clamp(Neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
			else:
				rotate_y(Yaw_Delta)
			Head.rotate_x(Pitch_delta)
			Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	var Input_Direction := Input.get_vector("Left", "Right", "Forward", "Backward")
	var Crouch_Just_Pressed := Input.is_action_just_pressed("Crouch")
	# Reset jump charges when grounded
	if is_on_floor():
		Jumps_Left = Max_Jumps
		Wall_Jumps_Left = Max_Wall_Jumps
	# Crouching
	if GameManager.Toggle_Crouch:
		if Crouch_Just_Pressed:
			Is_Crouching_Toggled = !Is_Crouching_Toggled
	else:
		Is_Crouching_Toggled = Input.is_action_pressed("Crouch")
	# Sprinting
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
	# Dashing
	if Dash_Cooldown_Timer > 0:
		Dash_Cooldown_Timer -= delta
	if Dashing:
		Dash_Timer -= delta
		if Dash_Timer <= 0:
			Dashing = false
	# State flags
	var Should_Crouch := Is_Crouching_Toggled || Sliding
	var Should_Sprint := Is_Sprinting_Toggled && !Should_Crouch
	# Changes The State On What You're Holding/Toggling
	if Should_Crouch:
		Head.position.y = lerp(Head.position.y, Crouching_Depth, delta * Lerp_Speed)
		Current_Speed = lerp(Current_Speed, Crouching_Speed, delta * Lerp_Speed)
		Standing_Collision_Shape.disabled = true
		Crouching_Collision_Shape.disabled = false
		Standing_Shape.visible = false
		Crouching_Shape.visible = true
		# Sliding
		if is_on_floor() && Is_Sprinting_Toggled && Input_Direction.y < 0 && !Sliding && (Crouch_Just_Pressed || Input.is_action_just_pressed("Sprint")):
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
	if Input.is_action_just_pressed("Dash") && Dash_Cooldown_Timer <= 0 && !Dashing:
		Dashing = true
		Dash_Timer = Dash_Timer_Max
		Dash_Cooldown_Timer = Dash_Cooldown_Max
		if Input_Direction != Vector2.ZERO:
			Dash_Vector = Input_Direction
		else:
			Dash_Vector = Vector2(0, -1.0)
	if Speed_Lines:
		Speed_Lines.visible = Sliding || Dashing || Grappling || Wall_Gliding || (Sprinting && Input_Direction != Vector2.ZERO)
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
	# Headbobbing
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
		if is_on_floor() && !Sliding && !Dashing && Input_Direction != Vector2.ZERO:
			Headbobbing_Vector.y = sin(Headbobbing_Index)
			Headbobbing_Vector.x = sin(Headbobbing_Index / 2) + 0.5
			Eyes.position.y = lerp(Eyes.position.y, Headbobbing_Vector.y * (Headbobbing_Current_Intensity / 2), delta * Lerp_Speed)
			Eyes.position.x = lerp(Eyes.position.x, Headbobbing_Vector.x * Headbobbing_Current_Intensity, delta * Lerp_Speed)
		else:
			Eyes.position.y = lerp(Eyes.position.y, 0.0, delta * Lerp_Speed)
			Eyes.position.x = lerp(Eyes.position.x, 0.0, delta * Lerp_Speed)
			Headbobbing_Vector.x = sin(Headbobbing_Index / 2) + 0.5
	# Camera tilt
	if not GameManager.No_Shake and not Wall_Gliding:
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
		Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(-89))
	# Grapple
	if Input.is_action_just_pressed("Grapple") and not Grappling:
		if Grapple_RayCast and Grapple_RayCast.is_colliding():
			Grapple_Point = Grapple_RayCast.get_collision_point()
			Grapple_Length = global_position.distance_to(Grapple_Point)
			Grapple_Total_Angle = 0.0
			Grapple_Last_Direction = (global_position - Grapple_Point).normalized()
			Grappling = true
	elif not Input.is_action_pressed("Grapple") and Grappling:
		Grappling = false
		if Grapple_Rope:
			Grapple_Rope.mesh = null
	if Grappling:
		var Current_Direction := (global_position - Grapple_Point).normalized()
		var Step_Angle := Grapple_Last_Direction.angle_to(Current_Direction)
		Grapple_Total_Angle += Step_Angle
		Grapple_Last_Direction = Current_Direction
		if Grapple_Total_Angle >= PI or Input.is_action_just_pressed("Jump"):
			Grappling = false
			if Grapple_Rope:
				Grapple_Rope.mesh = null
			if Input.is_action_just_pressed("Jump"):
				velocity += Vector3.UP * (Jump_Velocity * 0.5)
		else:
			var Current_Distance := global_position.distance_to(Grapple_Point)
			var Rope_Direction := (Grapple_Point - global_position).normalized()
			if Current_Distance > (Grapple_Length + Grapple_Rope_Slack):
				var Stretch := Current_Distance - Grapple_Length
				velocity += Rope_Direction * Stretch * Grapple_Pull_Force * delta
			Grapple_Length = move_toward(Grapple_Length, 2.0, delta * (Grapple_Pull_Force * 0.2))
			if Input_Direction != Vector2.ZERO:
				var Swing_Steering := (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized()
				velocity += Swing_Steering * Sprinting_Speed * delta
			if Grapple_Rope:
				var Immediate_Mesh: ImmediateMesh
				if Grapple_Rope.mesh is ImmediateMesh:
					Immediate_Mesh = Grapple_Rope.mesh as ImmediateMesh
					Immediate_Mesh.clear_surfaces()
				else:
					Immediate_Mesh = ImmediateMesh.new()
					Grapple_Rope.mesh = Immediate_Mesh
				if not Grapple_Rope.material_override:
					var Rope_Material := StandardMaterial3D.new()
					Rope_Material.albedo_texture = Rope_Texture
					Rope_Material.uv1_triplanar = true
					Rope_Material.uv2_triplanar = true
					Rope_Material.cull_mode = BaseMaterial3D.CULL_DISABLED
					Grapple_Rope.material_override = Rope_Material
				var Start_Position := Grapple_Rope.to_local(global_position)
				var End_Position := Grapple_Rope.to_local(Grapple_Point)
				var Mesh_Rope_Direction := (End_Position - Start_Position).normalized()
				var Camera_Direction := (global_position - Camera.global_position).normalized()
				var Side_Direction := Mesh_Rope_Direction.cross(Camera_Direction).normalized() * (Rope_Thickness * 0.5)
				if Side_Direction.length_squared() < 0.001:
					Side_Direction = Mesh_Rope_Direction.cross(Vector3.UP).normalized() * (Rope_Thickness * 0.5)
				Immediate_Mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
				var First_Vertex := Start_Position - Side_Direction
				var Second_Vertex := Start_Position + Side_Direction
				var Third_Vertex := End_Position + Side_Direction
				var Fourth_Vertext := End_Position - Side_Direction
				Immediate_Mesh.surface_add_vertex(First_Vertex)
				Immediate_Mesh.surface_add_vertex(Second_Vertex)
				Immediate_Mesh.surface_add_vertex(Third_Vertex)
				Immediate_Mesh.surface_add_vertex(First_Vertex)
				Immediate_Mesh.surface_add_vertex(Third_Vertex)
				Immediate_Mesh.surface_add_vertex(Fourth_Vertext)
				Immediate_Mesh.surface_end()
	else:
		# Jumping & Wall Jumping
		if Input.is_action_just_pressed("Jump"):
			if is_on_wall() and not is_on_floor() and Wall_Jumps_Left > 0:
				var Wall_Normal := get_wall_normal()
				velocity.y = Wall_Jump_Velocity
				velocity.x = Wall_Normal.x * Wall_Push_Force
				velocity.z = Wall_Normal.z * Wall_Push_Force
				Wall_Jump_Lock_Timer = Wall_Jump_Lock_Time
				Direction = Vector3(Wall_Normal.x, 0, Wall_Normal.z).normalized()
				Wall_Jumps_Left -= 1
				Jumps_Left = Max_Jumps - 1
				if GameManager.Toggle_Crouch and Sliding:
					Crouching = false
				Sliding = false
				Freelooking = false
			elif Jumps_Left > 0:
				velocity.y = Jump_Velocity
				Jumps_Left -= 1
				if GameManager.Toggle_Crouch and Sliding:
					Crouching = false 
				Sliding = false
				Freelooking = false
	if Wall_Jump_Lock_Timer > 0:
		Wall_Jump_Lock_Timer -= delta
	# Wall Gliding
	var Wall_Normal := get_wall_normal() if is_on_wall() else Vector3.ZERO
	Wall_Gliding = is_on_wall() and not is_on_floor() and velocity.y < 0 and Input_Direction != Vector2.ZERO
	if is_on_floor():
		Direction = lerp(Direction, (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized(), delta * Lerp_Speed)
	elif Wall_Gliding:
		if velocity.y < Wall_Glide_Fall_Speed:
			velocity.y = lerp(velocity.y, Wall_Glide_Fall_Speed, delta * 10.0)
		var Raw_Direction := (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized()
		var Wall_Slide_Direction := Raw_Direction.slide(Wall_Normal).normalized()
		Direction = lerp(Direction, Wall_Slide_Direction, delta * Air_Lerp_Speed)
		Current_Speed = lerp(Current_Speed, Wall_Glide_Speed, delta * Lerp_Speed)
		# Wall Gliding camera tilt
		var Wall_Side := transform.basis.x.dot(Wall_Normal)
		if Wall_Side > 0:
			Camera.rotation.z = lerp(Camera.rotation.z, deg_to_rad(-Wall_Glide_Tilt_Angle), delta * 10.0)
		else:
			Camera.rotation.z = lerp(Camera.rotation.z, deg_to_rad(Wall_Glide_Tilt_Angle), delta * 10.0)
	else:
		if Input_Direction != Vector2.ZERO and not Grappling and Wall_Jump_Lock_Timer <= 0:
			Direction = lerp(Direction, (transform.basis * Vector3(Input_Direction.x, 0, Input_Direction.y)).normalized(), delta * Air_Lerp_Speed)
	if Sliding:
		Direction = (transform.basis * Vector3(Slide_Vector.x, 0, Slide_Vector.y)).normalized()
		Current_Speed = (Slide_Timer + 0.1) * Slide_Speed
		var Horizontal_Velocity := Vector3(velocity.x, 0, velocity.z)
		Current_Slide_Speed = Horizontal_Velocity.length()
		if Current_Slide_Speed < Crouching_Speed:
			Sliding = false
			Freelooking = false
			Current_Speed = Crouching_Speed
	# Dashing
	if Dashing:
		Direction = (transform.basis * Vector3(Dash_Vector.x, 0, Dash_Vector.y)).normalized()
		Current_Speed = (Dash_Timer + 0.1) * Dash_Speed
		var Horizontal_Velocity := Vector3(velocity.x, 0, velocity.z)
		Current_Dash_Speed = Horizontal_Velocity.length()
		if Current_Dash_Speed < Walking_Speed:
			Dashing = false
			Current_Speed = Walking_Speed
	if not Grappling:
		if Direction:
			velocity.x = Direction.x * Current_Speed
			velocity.z = Direction.z * Current_Speed
		else:
			velocity.x = move_toward(velocity.x, 0, Current_Speed)
			velocity.z = move_toward(velocity.z, 0, Current_Speed)
	Last_Velocity = velocity
	move_and_slide()
	if is_on_floor() and Last_Velocity.y < -Min_Fall_Velocity:
		var Excess_Speed = abs(Last_Velocity.y) - Min_Fall_Velocity
		Health = max(0, Health - int(Excess_Speed * Fall_Damage_Multiplier))
