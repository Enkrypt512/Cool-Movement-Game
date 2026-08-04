extends Node3D

@onready var FPS_Counter: Label = $"HUD/FPS Counter"
@onready var InGame_Menu: Control = $"InGame Menu"
@onready var Floor: CSGBox3D = $"Navigation Region/Floor"
@onready var Spawn_Locations: Node3D = $"Spawn Locations"
@onready var Binds: Control = $"InGame Menu/Settings/Binds"
@onready var Main_Settings: Control = $"InGame Menu/Settings/Main"
@onready var Quit_Settings: Button = $"InGame Menu/Settings/Quit"
@onready var Resume: Button = $"InGame Menu/Main/Resume"
@onready var Settings_Button: Button = $"InGame Menu/Main/Settings Button"
@onready var Quit_Menu: Button = $"InGame Menu/Main/Quit"
@onready var Back_To_Menu: Button = $"InGame Menu/Main/Back To Menu"
@onready var Enemies_Killed: Label = $"HUD/Enemies Killed"
@onready var Score: Label = $HUD/Score
@onready var time: Label = $HUD/Time
@onready var Hits: Label = $HUD/Hits
@onready var Highscore: Label = $HUD/Highscore
@onready var Best_Time: Label = $"HUD/Best Time"
@onready var Most_Enemies_Killed: Label = $"HUD/Most Enemies Killed"
@onready var Enemies: Node3D = $Enemies
@onready var Health_Boxes: Node3D = $"Health Boxes"
@onready var Combo: Label = $HUD/Combo
@onready var Best_Run_Combo: Label = $"HUD/Best Run Combo"
@onready var Best_Lifetime_Combo: Label = $"HUD/Best Lifetime Combo"

var Health_Box: PackedScene = preload("res://Scenes/Health Box.tscn")
var Enemey: PackedScene = preload("res://Scenes/Enemy.tscn")
var Ram_Enemy: PackedScene = preload("res://Scenes/Ram Enemy.tscn")
var Last_Spawn_Time: float = 0.0
var Last_Enemy_Spawn_Time: float = 0.0
var Local_Player: CharacterBody3D = null
var Elapsed_Time: float = 0.0

func _ready() -> void:
	GameManager.Enemies_Killed = 0
	GameManager.time = 0.0
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
	var Player_Instance:CharacterBody3D = preload("res://Scenes/Player.tscn").instantiate()
	Player_Instance.name = str(Peer_ID)
	Player_Instance.set_multiplayer_authority(Peer_ID)
	var Spawn_Position: Vector3 = Vector3(0, 2, 0)
	if Spawn_Locations && Spawn_Locations.get_child_count() > 0:
		var Spawn_Point: Node3D = Spawn_Locations.get_children().pick_random()
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
			Local_Player = node

func Find_Local_Player() -> void:
	for Player in get_tree().get_nodes_in_group("Player"):
		if Player.is_multiplayer_authority():
			Local_Player = Player 
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
			var Enemy_Spawn_Cooldown: float = 1.5
			if Current_Time - Last_Enemy_Spawn_Time >= Enemy_Spawn_Cooldown:
				Last_Enemy_Spawn_Time = Current_Time
				Spawn_Enemy()
				GameManager.Enemies_Spawned += 1
	Enemies_Killed.text = "Enemies Killed: " + str(GameManager.Enemies_Killed)
	Score.text = "Score: " + str(GameManager.Enemies_Killed * 50)
	var Total_Microseconds: int = int(Elapsed_Time * 1_000_000)
	var Minutes: int = Total_Microseconds / 60_000_000
	var Seconds: int = (Total_Microseconds / 1_000_000) % 60
	var Milliseconds: int = (Total_Microseconds / 1_000) % 1_000
	time.text = "Time: %02dm %02ds %03dms" % [Minutes, Seconds, Milliseconds]
	Hits.text = "Hits:" +  str(GameManager.Times_Hit)
	Combo.text = "Combo:" + str(GameManager.Current_Combo) + "x"
	Best_Run_Combo.text = "Best Run Combo:" + str(GameManager.Max_Combo) + "x"
	Best_Lifetime_Combo.text = "Best Lifetime Combo:" + str(GameManager.Highest_Lifetime_Combo) + "x"
	Highscore.text = "Highscore: " + str(GameManager.Highscore)
	Most_Enemies_Killed.text = "Most Kills: " + str(GameManager.Most_Enemies_Killed)
	var Best_Microseconds: int = int(GameManager.Best_Time * 1_000_000)
	var Best_Minutues: int = Best_Microseconds / 60_000_000
	var Best_Seconds: int = (Best_Microseconds / 1_000_000) % 60
	var Best_Ms: int = (Best_Microseconds / 1_000) % 1_000
	Best_Time.text = "Best Time: %02dm %02ds %03dms" % [Best_Minutues, Best_Seconds, Best_Ms]

func Spawn_Health_Box() -> void:
	var Health_Box_Instance: Node = Health_Box.instantiate()
	var Margin: float = 1.0
	var Random_X_Position: float = randf_range(Floor.global_position.x - (Floor.size.x / 2.0) + Margin, Floor.global_position.x + (Floor.size.x / 2.0) - Margin)
	var Random_Z_Position: float = randf_range(Floor.global_position.z - (Floor.size.z / 2.0) + Margin, Floor.global_position.z + (Floor.size.z / 2.0) - Margin)
	Health_Box_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	Health_Boxes.add_child(Health_Box_Instance, true)

func Spawn_Enemy() -> void:
	var Selected_Enemy_Scene: PackedScene = Enemey if randf() < 0.5 else Ram_Enemy
	var Enemy_Instance: Node3D = Selected_Enemy_Scene.instantiate()
	var Margin: float = 1.0
	var Half_X: float = Floor.size.x / 2.0
	var Half_Z: float = Floor.size.z / 2.0
	var Random_X_Position: float = randf_range(Floor.global_position.x - Half_X + Margin, Floor.global_position.x + Half_X - Margin)
	var Random_Z_Position: float = randf_range(Floor.global_position.z - Half_Z + Margin, Floor.global_position.z + Half_Z - Margin)
	Enemy_Instance.global_position = Vector3(Random_X_Position, 20.0, Random_Z_Position)
	Enemies.add_child(Enemy_Instance, true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.keycode == KEY_F11 && event.pressed:
		var Is_Fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		On_Fullscreen_Toggled(!Is_Fullscreen)
		get_viewport().set_input_as_handled()
		return

func Set_HUD_Visibility(Is_Visible: bool) -> void:
	if !is_instance_valid(Local_Player):
		return    
	var HUD_Node: Control = Local_Player.get_node_or_null("HUD")
	var Crosshair_Node: Sprite2D = Local_Player.get_node_or_null("Crosshair")
	if HUD_Node:
		HUD_Node.visible = Is_Visible
	if Crosshair_Node:
		Crosshair_Node.visible = Is_Visible
	if Most_Enemies_Killed:
		Most_Enemies_Killed.visible = Is_Visible
	if time:
		time.visible = Is_Visible
	if Enemies_Killed:
		Enemies_Killed.visible = Is_Visible
	if Score:
		Score.visible = Is_Visible
	if Highscore:
		Highscore.visible = Is_Visible
	if Best_Time:
		Best_Time.visible = Is_Visible

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
