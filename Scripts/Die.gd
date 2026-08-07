extends Control

var Player: CharacterBody3D = null
var Player_Scene: PackedScene = preload("res://Scenes/Player.tscn")
@onready var Died: Control = $"."
@onready var Menu: Control = $"../InGame Menu"
@onready var Return_To_Menu: Button = $"Return To Menu"
@onready var Quit: Button = $Quit
@onready var InGame_Menu: Control = $"../InGame Menu"
@onready var Crosshair: Sprite2D = null
@onready var HUD: Control = null
@onready var Enemies_Killed: Label = $"Enemies Killed"
@onready var time: Label = $Time
@onready var Score: Label = $Score
@onready var Highscore: Label = $Highscore 
@onready var Most_Enemies_Killed: Label = $"Most Enemies Killed"
@onready var Best_Time: Label = $"Best Time"
@onready var Rank_Label: Label = $Rank
@onready var Retry: Button = $Retry
@onready var Enemies: Node3D = $"../Enemies"
@onready var Health_Boxes: Node3D = $"../Health Boxes"
@onready var Main: Node3D = $".."
@onready var Hits: Label = $Hits

enum Ranks {
	D,
	C,
	B,
	A,
	S,
	SS,
	SS_Plus,
	SS_Double_Plus,
	P
}

@export var S_Threshold_Kills_Per_Minute: float = 50.0
@export var SS_Threshold_Kills_Per_Minute: float = 80.0
@export var SS_Plus_Threshold_Kills_Per_Minute: float = 100.0
@export var Minimum_Time_For_Top_Ranks: float = 300.0

func _ready() -> void:
	Retry.pressed.connect(Retry_Game)
	Return_To_Menu.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Menu.tscn"))
	Quit.pressed.connect(func(): get_tree().quit())
	get_tree().node_added.connect(On_Node_Added)
	Find_Local_Player()

func On_Node_Added(node: Node) -> void:
	if node.is_in_group("Player") && node.is_multiplayer_authority():
		Set_Player(node)

func Set_Player(player_node: Node) -> void:
	Player = player_node
	HUD = Player.get_node_or_null("HUD")
	if HUD:
		Crosshair = HUD.get_node_or_null("Crosshair")

func Find_Local_Player() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			Set_Player(player)
			break

func _process(_delta: float) -> void:
	if !is_instance_valid(Player) || !("Health" in Player):
		return
	if Player.Health <= 0:
		if !Died.visible: 
			Died.visible = true
			if is_instance_valid(Crosshair): Crosshair.visible = false
			if is_instance_valid(HUD): HUD.visible = false
			Menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			var Current_Score: int = GameManager.Enemies_Killed * 50
			var Record_Results: Dictionary = GameManager.Submit_Score(Current_Score, GameManager.Enemies_Killed, GameManager.time)
			if Record_Results.get("Is_New_Score", false):
				Highscore.text = "New Highscore!"
			else:
				Highscore.text = "Highscore: " + str(GameManager.Highscore)
			if Record_Results.get("Is_New_Kills", false):
				Most_Enemies_Killed.text = "New Enemies Record!"
			else:
				Most_Enemies_Killed.text = "Most Enemies Killed:" + str(GameManager.Most_Enemies_Killed)
			if Record_Results.get("Is_New_Time",false):
				Best_Time.text = "New Best Time!"
			else:
				var Best_Microseconds: int = int(GameManager.Best_Time * 1_000_000)
				var Best_Minutues: int = Best_Microseconds / 60_000_000
				var Best_Seconds: int = (Best_Microseconds / 1_000_000) % 60
				var Best_Ms: int = (Best_Microseconds / 1_000) % 1_000
				Best_Time.text = "Best Time: %02dm %02ds %03dms" % [Best_Minutues, Best_Seconds, Best_Ms]
			var Rank_Data: Dictionary = Calculate_Final_Rank(GameManager.Enemies_Killed, GameManager.time, Player)
			Update_Rank_UI(Rank_Data)
	else:
		if Died.visible:
			Died.visible = false
			if is_instance_valid(Crosshair): Crosshair.visible = true
			if is_instance_valid(HUD): HUD.visible = true
			if !InGame_Menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Enemies_Killed.text = "Enemies Killed: " + str(GameManager.Enemies_Killed)
	Score.text = "Score: " + str(GameManager.Enemies_Killed * 50)
	var Total_Microseconds: int = int(GameManager.time * 1_000_000)
	var Minutes: int = Total_Microseconds / 60_000_000
	var Seconds: int = (Total_Microseconds / 1_000_000) % 60
	var Milliseconds: int = (Total_Microseconds / 1_000) % 1_000
	time.text = "Time: %02dm %02ds %03dms" % [Minutes, Seconds, Milliseconds]
	Hits.text = "Hits:" + str(GameManager.Times_Hit)

func Calculate_Final_Rank(Kills: int, Total_Seconds: float, Player_Node: CharacterBody3D) -> Dictionary:
	if Total_Seconds <= 0:
		return {"Tier": Ranks.D, "String": "D"}
	var Minutes: float = Total_Seconds / 60.0
	var Kills_Per_Minute: float = float(Kills) / Minutes
	var Final_Tier: Ranks = Ranks.D
	if Kills_Per_Minute >= SS_Plus_Threshold_Kills_Per_Minute:
		Final_Tier = Ranks.SS_Plus
	elif Kills_Per_Minute >= SS_Threshold_Kills_Per_Minute:
		Final_Tier = Ranks.SS
	elif Kills_Per_Minute >= S_Threshold_Kills_Per_Minute:
		Final_Tier = Ranks.S
	elif Kills_Per_Minute >= 30.0:
		Final_Tier = Ranks.A
	elif Kills_Per_Minute >= 20.0:
		Final_Tier = Ranks.B
	elif Kills_Per_Minute >= 10.0:
		Final_Tier = Ranks.C
	else:
		Final_Tier = Ranks.D
	var Boxes_Used: int = GameManager.Health_Boxes_Used
	var Total_Enemies_Spawned: int = GameManager.Enemies_Spawned 
	var Actual_Enemies_Killed: int = GameManager.Enemies_Killed
	var No_Hit: bool = (Boxes_Used == 0 && GameManager.Times_Hit == 0)
	var Killed_All_Enemies: bool = (Actual_Enemies_Killed >= Total_Enemies_Spawned) && (Total_Enemies_Spawned > 0)
	var Qualifies_For_SS_Double_Plus: bool = (Final_Tier >= Ranks.SS_Plus) && (Total_Seconds >= Minimum_Time_For_Top_Ranks) && No_Hit
	if Qualifies_For_SS_Double_Plus:
		Final_Tier = Ranks.SS_Double_Plus
	var Qualifies_For_P_Rank: bool = (Final_Tier >= Ranks.SS_Plus) && No_Hit && Killed_All_Enemies
	if Qualifies_For_P_Rank:
		Final_Tier = Ranks.P
	var Rank_String: String = "D"
	match Final_Tier:
		Ranks.D: Rank_String = "D"
		Ranks.C: Rank_String = "C"
		Ranks.B: Rank_String = "B"
		Ranks.A: Rank_String = "A"
		Ranks.S: Rank_String = "S"
		Ranks.SS: Rank_String = "SS"
		Ranks.SS_Plus: Rank_String = "SS+"
		Ranks.SS_Double_Plus: Rank_String = "SS++"
		Ranks.P: Rank_String = "P"
	return {"Tier": Final_Tier, "String": Rank_String}

func Update_Rank_UI(Rank_Data: Dictionary) -> void:
	if !Rank_Label:
		return
	Rank_Label.text = "RANK: " + Rank_Data["String"]
	match Rank_Data["Tier"]:
		Ranks.P:
			Rank_Label.add_theme_color_override("font_color", Color(0.915, 0.6, 0.0, 1.0))
		Ranks.SS_Double_Plus:
			Rank_Label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
		Ranks.SS_Plus:
			Rank_Label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		Ranks.SS:
			Rank_Label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		Ranks.S:
			Rank_Label.add_theme_color_override("font_color", Color(0.85, 0.0, 0.0))

func Retry_Game():
	var Died_Music = Main.get_node_or_null("Died_Music")
	if Died_Music && Died_Music is AudioStreamPlayer && Died_Music.playing:
		Died_Music.stop()
	if is_instance_valid(Player):
		Player.queue_free()
	Player = null
	HUD = null
	Crosshair = null
	for Enemy in Enemies.get_children():
		Enemy.queue_free()
	for Health_Box in Health_Boxes.get_children():
		Health_Box.queue_free()
	var Player_Instance = Player_Scene.instantiate()
	Player_Instance.global_position.y += 2
	Main.add_child(Player_Instance)
	GameManager.time = 0
	GameManager.Enemies_Killed = 0
	GameManager.Times_Hit = 0
	GameManager.Max_Combo = 0
	Main.Elapsed_Time = 0
	Main.Play_Song_With_Fade(Main.Music.pick_random())
