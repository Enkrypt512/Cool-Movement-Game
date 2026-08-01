extends Control

var Player: CharacterBody3D = null
@onready var Died: Control = $"."
@onready var Menu: Control = $"../InGame Menu"
@onready var Return_To_Menu: Button = $"Return To Menu"
@onready var Quit: Button = $Quit
@onready var InGame_Menu: Control = $"../InGame Menu"
@onready var Crosshair: Sprite2D = $"../Player/HUD/Crosshair"
@onready var HUD: Control = $"../Player/HUD"
@onready var Enemies_Killed: Label = $"Enemies Killed"
@onready var time: Label = $Time
@onready var Score: Label = $Score
@onready var Highscore: Label = $Highscore 
@onready var Most_Enemies_Killed: Label = $"Most Enemies Killed"
@onready var Rank_Label: Label = $Rank

enum Rank { D, C, B, A, S, SS, SS_Plus, SS_Double_Plus, P }

@export var S_Threshold_Kills_Per_Minute: float = 20.0
@export var SS_Threshold_Kills_Per_Minute: float = 30.0
@export var SS_Plus_Threshold_Kills_Per_Minute: float = 40.0
@export var Minimum_Time_For_Top_Ranks: float = 300.0

func _ready() -> void:
	Return_To_Menu.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Menu.tscn"))
	Quit.pressed.connect(func(): get_tree().quit())
	get_tree().node_added.connect(On_Node_Added)
	Find_Local_Player()

func On_Node_Added(node: Node) -> void:
	if Player == null && node.is_in_group("Player") && node.is_multiplayer_authority():
		Player = node as CharacterBody3D

func Find_Local_Player() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			Player = player as CharacterBody3D
			break

func _process(delta: float) -> void:
	if Player == null or !("Health" in Player):
		return
	if Player.Health <= 0:
		if !Died.visible: 
			Died.visible = true
			Crosshair.visible = false
			HUD.visible = false
			Menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			var Current_Score: int = GameManager.Enemies_Killed * 50
			var Record_Results: Dictionary = GameManager.Submit_Score(Current_Score, GameManager.Enemies_Killed, GameManager.time)
			if Highscore:
				if Record_Results.get("Is_New_Score", false):
					Highscore.text = "New Highscore!"
				else:
					Highscore.text = "Highscore: " + str(GameManager.Highscore)
			var Rank_Data: Dictionary = Calculate_Final_Rank(GameManager.Enemies_Killed, GameManager.time, Player)
			Update_Rank_UI(Rank_Data)
	else:
		if Died.visible:
			Died.visible = false
			Crosshair.visible = true
			HUD.visible = true
			if !InGame_Menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Enemies_Killed.text = "Enemies Killed: " + str(GameManager.Enemies_Killed)
	Score.text = "Score: " + str(GameManager.Enemies_Killed * 50)
	var Total_Microseconds: int = int(GameManager.time * 1_000_000)
	var Minutes: int = Total_Microseconds / 60_000_000
	var Seconds: int = (Total_Microseconds / 1_000_000) % 60
	var Milliseconds: int = (Total_Microseconds / 1_000) % 1_000
	time.text = "Time: %02dm %02ds %03dms" % [Minutes, Seconds, Milliseconds]

func Calculate_Final_Rank(Kills: int, Total_Seconds: float, Player_Node: CharacterBody3D) -> Dictionary:
	if Total_Seconds <= 0:
		return {"Tier": Rank.D, "String": "D"}
	var Minutes: float = Total_Seconds / 60.0
	var Kills_Per_Minute: float = float(Kills) / Minutes
	var Final_Tier: Rank = Rank.D
	if Kills_Per_Minute >= SS_Plus_Threshold_Kills_Per_Minute:
		Final_Tier = Rank.SS_Plus
	elif Kills_Per_Minute >= SS_Threshold_Kills_Per_Minute:
		Final_Tier = Rank.SS
	elif Kills_Per_Minute >= S_Threshold_Kills_Per_Minute:
		Final_Tier = Rank.S
	elif Kills_Per_Minute >= 14.0:
		Final_Tier = Rank.A
	elif Kills_Per_Minute >= 8.0:
		Final_Tier = Rank.B
	elif Kills_Per_Minute >= 4.0:
		Final_Tier = Rank.C
	else:
		Final_Tier = Rank.D
	var Boxes_Used: int = Player_Node.get("Health_Boxes_Used") if "Health_Boxes_Used" in Player_Node else 0
	var Total_Enemies_Spawned: int = GameManager.get("Enemies_Spawned") if GameManager.get("Enemies_Spawned") != null else 0
	var Actual_Enemies_Killed: int = GameManager.get("Enemies_Killed") if GameManager.get("Enemies_Killed") != null else Kills
	var No_Hit: bool = (Boxes_Used == 0 && GameManager.Times_Hit == 0)
	var Killed_All_Enemies: bool = (Actual_Enemies_Killed >= Total_Enemies_Spawned) && (Total_Enemies_Spawned > 0)
	var Qualifies_For_SS_Double_Plus: bool = (Final_Tier >= Rank.SS_Plus) && (Total_Seconds >= Minimum_Time_For_Top_Ranks) && No_Hit
	if Qualifies_For_SS_Double_Plus:
		Final_Tier = Rank.SS_Double_Plus
	var Qualifies_For_P_Rank: bool = (Final_Tier >= Rank.SS_Plus) && No_Hit && Killed_All_Enemies
	if Qualifies_For_P_Rank:
		Final_Tier = Rank.P
	var Rank_String: String = "D"
	match Final_Tier:
		Rank.D: Rank_String = "D"
		Rank.C: Rank_String = "C"
		Rank.B: Rank_String = "B"
		Rank.A: Rank_String = "A"
		Rank.S: Rank_String = "S"
		Rank.SS: Rank_String = "SS"
		Rank.SS_Plus: Rank_String = "SS+"
		Rank.SS_Double_Plus: Rank_String = "SS++"
		Rank.P: Rank_String = "P"
	return {"Tier": Final_Tier, "String": Rank_String}

func Update_Rank_UI(Rank_Data: Dictionary) -> void:
	if !Rank_Label:
		return
	Rank_Label.text = "RANK: " + Rank_Data["String"]
	match Rank_Data["Tier"]:
		Rank.P:
			Rank_Label.add_theme_color_override("font_color", Color(0.915, 0.6, 0.0, 1.0))
		Rank.SS_Double_Plus:
			Rank_Label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
		Rank.SS_Plus:
			Rank_Label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
		Rank.SS:
			Rank_Label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		Rank.S:
			Rank_Label.add_theme_color_override("font_color", Color(0.85, 0.0, 0.0))
