extends Control

var Player: CharacterBody3D = null
var Elapsed_Time: float
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
	if !visible:
		Elapsed_Time += delta
		GameManager.time = Elapsed_Time
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
			var Record_Results: Dictionary = GameManager.Submit_Score(Current_Score, GameManager.Enemies_Killed, Elapsed_Time)
			if Highscore:
				if Record_Results.get("Is_New_Score", false):
					Highscore.text = "New Highscore!"
				else:
					Highscore.text = "Highscore: " + str(GameManager.Highscore)
	else:
		if Died.visible:
			Died.visible = false
			Crosshair.visible = true
			HUD.visible = true
			if !InGame_Menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				
	Enemies_Killed.text = "Enemies Killed: " + str(GameManager.Enemies_Killed)
	Score.text = "Score: " + str(GameManager.Enemies_Killed * 50)
	var Total_Microseconds: int = int(Elapsed_Time * 1_000_000)
	var Minutes: int = Total_Microseconds / 60_000_000
	var Seconds: int = (Total_Microseconds / 1_000_000) % 60
	var Milliseconds: int = (Total_Microseconds / 1_000) % 1_000
	time.text = "Time: %02dm %02ds %03dms" % [Minutes, Seconds, Milliseconds]
