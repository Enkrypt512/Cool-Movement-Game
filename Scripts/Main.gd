extends Node3D

@onready var FPS_Counter: Label = $"FPS Counter"
@onready var InGame_Menu: Control = $Control
@onready var Floor: CSGBox3D = $"Navigation Region/Floor"
@onready var Spawn_Locations: Node3D = $"Spawn Locations"
@onready var Binds: Control = $Control/Settings/Binds
@onready var Main_Settings: Control = $Control/Settings/Main
@onready var Quit_Settings: Button = $Control/Settings/Quit
@onready var Resume: Button = $Control/Start
@onready var Settings_Button: Button = $"Control/Settings Button"
@onready var Quit_Menu: Button = $Control/Quit
@onready var Back_To_Menu: Button = $"Control/Back To Menu"
@onready var Enemies_Killed: Label = $"Enemies Killed"
@onready var Score: Label = $Score
@onready var time: Label = $Time
@onready var Highscore: Label = $Highscore
@onready var Best_Time: Label = $"Best Time"
@onready var Most_Enemies_Killed: Label = $"Most Enemies Killed"

var Health_Box: PackedScene = preload("res://Scenes/Healing_Box.tscn")
var Enemey: PackedScene = preload("res://Scenes/Enemy.tscn")
var Last_Spawn_Time: float = 0.0
var Last_Enemy_Spawn_Time: float = 0.0
var Local_Player: CharacterBody3D = null
@export var Deadzone: float = 0.2
var Virtual_Mouse_Position: Vector2 = Vector2.ZERO
var Elapsed_Time: float = 0.0

func _ready() -> void:
	GameManager.Enemies_Killed = 0
	GameManager.time = 0.0
	Virtual_Mouse_Position = get_viewport().get_mouse_position()
	get_tree().node_added.connect(On_Node_Added)
	Find_Local_Player()
	Resume.pressed.connect(Resume_Game)
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(Spawn_Player)
		multiplayer.peer_disconnected.connect(Despawn_Player)

func Spawn_All_Players() -> void:
	if !multiplayer.is_server():
		return
	Spawn_Player(1)
	for Peer_ID in multiplayer.get_peers():
		Spawn_Player(Peer_ID)

func Spawn_Player(Peer_ID: int) -> void:
	if !multiplayer.is_server():
		return
	if has_node(str(Peer_ID)):
		return
	var Player_Instance = preload("res://Scenes/Player.tscn").instantiate()
	Player_Instance.name = str(Peer_ID)
	Player_Instance.set_multiplayer_authority(Peer_ID)
	var Spawn_Position = Vector3(0, 2, 0)
	if Spawn_Locations && Spawn_Locations.get_child_count() > 0:
		var Spawn_Point = Spawn_Locations.get_children().pick_random()
		Spawn_Position = Spawn_Point.global_position + Vector3(0, 1.5, 0)
	Player_Instance.global_position = Spawn_Position
	add_child(Player_Instance, true)

func Despawn_Player(Peer_ID: int) -> void:
	if has_node(str(Peer_ID)):
		get_node(str(Peer_ID)).queue_free()

func On_Node_Added(node: Node) -> void:
	if node.is_in_group("Player"):
		if node.name.is_valid_int():
			node.set_multiplayer_authority(node.name.to_int())
		if node.is_multiplayer_authority():
			Local_Player = node as CharacterBody3D

func Find_Local_Player() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			Local_Player = player as CharacterBody3D
			break

func _process(delta: float) -> void:
	if !get_tree().paused:
		Elapsed_Time += delta
		GameManager.time = Elapsed_Time
	if GameManager.FPS_Counter:
		FPS_Counter.text = 'FPS:' + str(int(Engine.get_frames_per_second()))
		FPS_Counter.visible = true
	else:
		FPS_Counter.visible = false
	if !get_tree().paused:
		if multiplayer.is_server():
			var Current_Time: float = Time.get_ticks_msec() / 1000.0
			var Spawn_Cooldown: float = 10.0
			if Current_Time - Last_Spawn_Time >= Spawn_Cooldown:
				Last_Spawn_Time = Current_Time
				Spawn_Health_Box()
			var Enemy_Spawn_Cooldown: float = 1.0
			if Current_Time - Last_Enemy_Spawn_Time >= Enemy_Spawn_Cooldown:
				Last_Enemy_Spawn_Time = Current_Time
				Spawn_Enemy()
				
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		var Raw_Cursor_X_Position: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var Raw_Cursor_Y_Position: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		var Stick_Input: Vector2 = Vector2(
			Raw_Cursor_X_Position if abs(Raw_Cursor_X_Position) > Deadzone else 0.0,
			Raw_Cursor_Y_Position if abs(Raw_Cursor_Y_Position) > Deadzone else 0.0
		)
		if Stick_Input != Vector2.ZERO:
			var Speed: float = GameManager.Joystick_Sensitivity * 600.0
			var Viewport_Size = get_viewport().size
			Virtual_Mouse_Position += Stick_Input * Speed * delta
			Virtual_Mouse_Position.x = clamp(Virtual_Mouse_Position.x, 0.0, Viewport_Size.x)
			Virtual_Mouse_Position.y = clamp(Virtual_Mouse_Position.y, 0.0, Viewport_Size.y)
			Input.warp_mouse(Virtual_Mouse_Position)
	Enemies_Killed.text = "Enemies Killed: " + str(GameManager.Enemies_Killed)
	Score.text = "Score: " + str(GameManager.Enemies_Killed * 50)
	var Total_Microseconds: int = int(Elapsed_Time * 1_000_000)
	var Minutes: int = Total_Microseconds / 60_000_000
	var Seconds: int = (Total_Microseconds / 1_000_000) % 60
	var Milliseconds: int = (Total_Microseconds / 1_000) % 1_000
	time.text = "Time: %02dm %02ds %03dms" % [Minutes, Seconds, Milliseconds]
	if Highscore:
		Highscore.text = "Highscore: " + str(GameManager.Highscore)
	if Most_Enemies_Killed:
		Most_Enemies_Killed.text = "Most Kills: " + str(GameManager.Most_Enemies_Killed)
	if Best_Time:
		var Best_Microseconds: int = int(GameManager.Best_Time * 1_000_000)
		var Best_Mins: int = Best_Microseconds / 60_000_000
		var Best_Secs: int = (Best_Microseconds / 1_000_000) % 60
		var Best_Ms: int = (Best_Microseconds / 1_000) % 1_000
		Best_Time.text = "Best Time: %02dm %02ds %03dms" % [Best_Mins, Best_Secs, Best_Ms]

func Spawn_Health_Box() -> void:
	var Health_Box_Instance: Node = Health_Box.instantiate()
	var Margin: float = 1.0
	var Random_X_Position: float = randf_range(Floor.global_position.x - (Floor.size.x / 2.0) + Margin, Floor.global_position.x + (Floor.size.x / 2.0) - Margin)
	var Random_Z_Position: float = randf_range(Floor.global_position.z - (Floor.size.z / 2.0) + Margin, Floor.global_position.z + (Floor.size.z / 2.0) - Margin)
	Health_Box_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	add_child(Health_Box_Instance, true)

func Spawn_Enemy() -> void:
	var Enemy_Instance: Node = Enemey.instantiate()
	var Margin: float = 1.0
	var Random_X_Position: float = randf_range(Floor.global_position.x - (Floor.size.x / 2.0) + Margin, Floor.global_position.x + (Floor.size.x / 2.0) - Margin)
	var Random_Z_Position: float = randf_range(Floor.global_position.z - (Floor.size.z / 2.0) + Margin, Floor.global_position.z + (Floor.size.z / 2.0) - Margin)
	Enemy_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	add_child(Enemy_Instance, true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.keycode == KEY_F11 && event.pressed:
		var Is_Fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		On_Fullscreen_Toggled(!Is_Fullscreen)
		get_viewport().set_input_as_handled()
		return
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if event is InputEventMouseMotion:
			Virtual_Mouse_Position = event.position
	if event.is_action("ui_accept") && !event.is_echo():
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			var Click_Event: InputEventMouseButton = InputEventMouseButton.new()
			Click_Event.button_index = MOUSE_BUTTON_LEFT
			Click_Event.pressed = event.is_pressed()
			Click_Event.position = Virtual_Mouse_Position
			Click_Event.global_position = Virtual_Mouse_Position
			get_viewport().push_input(Click_Event)
			return

func Set_HUD_Visibility(Is_Visible: bool) -> void:
	if !is_instance_valid(Local_Player):
		return    
	var HUD_Node = Local_Player.get_node_or_null("HUD")
	var Crosshair_Node = Local_Player.get_node_or_null("Crosshair")
	if HUD_Node:
		HUD_Node.visible = Is_Visible
	if Crosshair_Node:
		Crosshair_Node.visible = Is_Visible

func On_Fullscreen_Toggled(Is_Checked: bool) -> void:
	GameManager.Fullscreen = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func Pause_Game() -> void:
	InGame_Menu.visible = true
	Quit_Settings.visible = true
	Binds.visible = false
	Main_Settings.visible = false
	Resume.visible = true
	Settings_Button.visible = true
	Quit_Menu.visible = true
	Back_To_Menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Set_HUD_Visibility(false)
	get_tree().paused = true

func Resume_Game() -> void:
	if InGame_Menu.has_method("Save_Game_Settings"):
		InGame_Menu.Save_Game_Settings()
	InGame_Menu.visible = false
	Quit_Settings.visible = false
	Binds.visible = false
	Main_Settings.visible = false
	Resume.visible = true
	Settings_Button.visible = true
	Quit_Menu.visible = true
	Back_To_Menu.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Set_HUD_Visibility(true)
	get_tree().paused = false
