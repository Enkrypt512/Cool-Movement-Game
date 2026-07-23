extends Node3D

@onready var FPS_Counter: Label = $"FPS Counter"
@onready var InGame_Menu: Control = $Control
@onready var Floor: CSGBox3D = $"Navigation Region/Floor"
@onready var Spawn_Locations: Node3D = $"Spawn Locations"
var Health_Box:PackedScene = preload("res://Scenes/Healing_Box.tscn")
var Enemey:PackedScene = preload("res://Scenes/Enemy.tscn")
var Last_Spawn_Time: float = 0.0
var Last_Enemy_Spawn_Time: float = 0.0
var Local_Player: CharacterBody3D = null
@export var Deadzone:float = 0.2
var Virtual_Mouse_Position:Vector2 = Vector2.ZERO

func _ready() -> void:
	Virtual_Mouse_Position = get_viewport().get_mouse_position()
	get_tree().node_added.connect(On_Node_Added)
	Find_Local_Player()

func On_Node_Added(node: Node) -> void:
	if node.is_in_group("Player"):
		if node.name.is_valid_int():
			node.set_multiplayer_authority(node.name.to_int())
		if node.is_multiplayer_authority():
			Local_Player = node as CharacterBody3D
			if Local_Player.has_method("Setup_Camera"):
				Local_Player.Setup_Camera()

func Despawn_Player(Peer_ID: int) -> void:
	if has_node(str(Peer_ID)):
		get_node(str(Peer_ID)).queue_free()

func Find_Local_Player() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			Local_Player = player as CharacterBody3D
			break

func _process(delta: float) -> void:
	if GameManager.FPS_Counter:
		FPS_Counter.text = 'FPS:' + str(Engine.get_frames_per_second())
		FPS_Counter.visible = true
	else:
		FPS_Counter.visible = false
	if multiplayer.is_server():
		var Current_Time:float = Time.get_ticks_msec() / 1000.0
		var Spawn_Cooldown:float = 10.0
		if Current_Time - Last_Spawn_Time >= Spawn_Cooldown:
			Last_Spawn_Time = Current_Time
			Spawn_Health_Box()
		
		var Enemy_Spawn_Cooldown:float = 1.0
		if Current_Time - Last_Enemy_Spawn_Time >= Enemy_Spawn_Cooldown:
			Last_Enemy_Spawn_Time = Current_Time
			Spawn_Enemy()

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		var Raw_Cursor_X_Position:float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var Raw_Cursor_Y_Position:float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		var Stick_Input:Vector2 = Vector2(
			Raw_Cursor_X_Position if abs(Raw_Cursor_X_Position) > Deadzone else 0.0,
			Raw_Cursor_Y_Position if abs(Raw_Cursor_Y_Position) > Deadzone else 0.0
		)
		if Stick_Input != Vector2.ZERO:
			var Speed:float = GameManager.Joystick_Sensitivity * 1200.0
			var Viewport_Size = get_viewport().size
			Virtual_Mouse_Position += Stick_Input * Speed * delta
			Virtual_Mouse_Position.x = clamp(Virtual_Mouse_Position.x, 0.0, Viewport_Size.x)
			Virtual_Mouse_Position.y = clamp(Virtual_Mouse_Position.y, 0.0, Viewport_Size.y)
			Input.warp_mouse(Virtual_Mouse_Position)

func Spawn_Health_Box() -> void:
	var Health_Box_Instance:Node = Health_Box.instantiate()
	var Margin:float = 1.0
	var Random_X_Position:float = randf_range(Floor.global_position.x - (Floor.size.x / 2.0) + Margin, Floor.global_position.x + (Floor.size.x / 2.0) - Margin)
	var Random_Z_Position:float = randf_range(Floor.global_position.z - (Floor.size.z / 2.0) + Margin, Floor.global_position.z + (Floor.size.z / 2.0) - Margin)
	Health_Box_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	add_child(Health_Box_Instance, true)

func Spawn_Enemy() -> void:
	var Enemy_Instance:Node = Enemey.instantiate()
	var Margin:float = 1.0
	var Random_X_Position:float = randf_range(Floor.global_position.x - (Floor.size.x / 2.0) + Margin, Floor.global_position.x + (Floor.size.x / 2.0) - Margin)
	var Random_Z_Position:float = randf_range(Floor.global_position.z - (Floor.size.z / 2.0) + Margin, Floor.global_position.z + (Floor.size.z / 2.0) - Margin)
	Enemy_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	add_child(Enemy_Instance, true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F11 and event.pressed:
		var Is_Fullscreen:bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		On_Fullscreen_Toggled(!Is_Fullscreen)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Exit") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if InGame_Menu.visible:
			if InGame_Menu.has_method("Save_Game_Settings"):
				InGame_Menu.Save_Game_Settings()
			InGame_Menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Set_HUD_Visibility(true)
		else:
			InGame_Menu.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Set_HUD_Visibility(false)
		return

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if event is InputEventMouseMotion:
			Virtual_Mouse_Position = event.position

	if event.is_action("Jump") and not event.is_echo():
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			var Click_Event:InputEventMouseButton = InputEventMouseButton.new()
			Click_Event.button_index = MOUSE_BUTTON_LEFT
			Click_Event.pressed = event.is_pressed()
			Click_Event.position = Virtual_Mouse_Position
			Click_Event.global_position = Virtual_Mouse_Position
			get_viewport().push_input(Click_Event)
			return

func Set_HUD_Visibility(Is_Visible: bool) -> void:
	if not is_instance_valid(Local_Player):
		return    
	var HUD = Local_Player.get_node_or_null("HUD")
	var Crosshair = Local_Player.get_node_or_null("Crosshair")
	if HUD:
		HUD.visible = Is_Visible
	if Crosshair:
		Crosshair.visible = Is_Visible

func On_Fullscreen_Toggled(Is_Checked: bool) -> void:
	GameManager.Fullscreen = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
