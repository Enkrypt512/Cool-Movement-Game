extends Node

var Fullscreen: bool
var FPS_Counter: bool
var Volume: int
var Mouse_Sensitivity: float
var VSync: bool
var Max_FPS: int
var Toggle_Sprint: bool
var Toggle_Crouch: bool
var No_Shake: bool
var Players: Dictionary = {}
var Enemies_Killed: int = 0
var time: float = 0.0
var Highscore: int = 0
var Most_Enemies_Killed: int = 0
var Best_Time: float = 0.0
var Speedometer: bool
var Enemies_Spawned: int
var Healt_Boxes_Used: int
var Times_Hit: int

func _ready() -> void:
	Load_Stats()

func Submit_Score(Current_Score: int, Current_Enemies: int, Current_Time: float) -> Dictionary:
	var New_Highscore_Set: bool = false
	var New_Most_Kills_Set: bool = false
	var New_Best_Time_Set: bool = false
	if Current_Score > Highscore:
		Highscore = Current_Score
		New_Highscore_Set = true
	if Current_Enemies > Most_Enemies_Killed:
		Most_Enemies_Killed = Current_Enemies
		New_Most_Kills_Set = true
	if Current_Time > Best_Time:
		Best_Time = Current_Time
		New_Best_Time_Set = true
	if New_Highscore_Set || New_Most_Kills_Set || New_Best_Time_Set:
		Save_Stats()
	return {
		"Is_New_Score": New_Highscore_Set,
		"Is_New_Kills": New_Most_Kills_Set,
		"Is_New_Time": New_Best_Time_Set
	}

func Save_Stats() -> void:
	var Config: ConfigFile = ConfigFile.new()
	Config.load("user://Settings.cfg") 
	Config.set_value("Stats", "Highscore", Highscore)
	Config.set_value("Stats", "Most Enemies Killed", Most_Enemies_Killed)
	Config.set_value("Stats", "Best Time", Best_Time)
	var error := Config.save("user://Settings.cfg")
	if error != OK:
		print("Failed to save stats. Error code: ", error)

func Load_Stats() -> void:
	var Config: ConfigFile = ConfigFile.new()
	if Config.load("user://Settings.cfg") == OK:
		Highscore = Config.get_value("Stats", "Highscore", 0)
		Most_Enemies_Killed = Config.get_value("Stats", "Most Enemies Killed", 0)
		Best_Time = Config.get_value("Stats", "Best Time", 0.0)
