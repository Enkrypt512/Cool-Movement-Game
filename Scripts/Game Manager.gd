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
var Enemies_Spawned: int = 0
var Health_Boxes_Used: int = 0
var Times_Hit: int = 0
var Highscore: int = 0
var Most_Enemies_Killed: int = 0
var Best_Time: float = 0.0
var Total_Lifetime_Hits: int = 0
var Speedometer: bool
var Current_Combo: int = 0
var Max_Combo: int = 0
var Highest_Lifetime_Combo: int = 0
signal Combo_Changed(New_Combo: int)

func _ready() -> void:
	Load_Stats()

func Reset_Run_Stats() -> void:
	Enemies_Killed = 0
	time = 0.0
	Enemies_Spawned = 0
	Health_Boxes_Used = 0
	Times_Hit = 0
	Current_Combo = 0
	Max_Combo = 0
	Combo_Changed.emit(Current_Combo)

func Record_Shot() -> void:
	Current_Combo += 1
	if Current_Combo > Max_Combo:
		Max_Combo = Current_Combo
	if Current_Combo > Highest_Lifetime_Combo:
		Highest_Lifetime_Combo = Current_Combo
	Combo_Changed.emit(Current_Combo)

func Record_Hit() -> void:
	Times_Hit += 1
	Total_Lifetime_Hits += 1
	Current_Combo = 0
	Combo_Changed.emit(Current_Combo)

func Submit_Score(Current_Score: int, Current_Enemies: int, Current_Time: float) -> Dictionary:
	var New_Highscore_Set: bool = false
	var New_Most_Kills_Set: bool = false
	var New_Best_Time_Set: bool = false
	var New_Max_Combo_Set: bool = false
	if Current_Score > Highscore:
		Highscore = Current_Score
		New_Highscore_Set = true
	if Current_Enemies > Most_Enemies_Killed:
		Most_Enemies_Killed = Current_Enemies
		New_Most_Kills_Set = true
	if Current_Time > Best_Time:
		Best_Time = Current_Time
		New_Best_Time_Set = true
	Save_Stats()
	return {
		"Is_New_Score": New_Highscore_Set,
		"Is_New_Kills": New_Most_Kills_Set,
		"Is_New_Time": New_Best_Time_Set,
	}

func Save_Stats() -> void:
	var Config: ConfigFile = ConfigFile.new()
	Config.load("user://Save.cfg") 
	Config.set_value("Stats", "Highscore", Highscore)
	Config.set_value("Stats", "Most Enemies Killed", Most_Enemies_Killed)
	Config.set_value("Stats", "Best Time", Best_Time)
	Config.set_value("Stats", "Total Lifetime Hits", Total_Lifetime_Hits)
	Config.set_value("Stats", "Highest Lifetime Combo", Highest_Lifetime_Combo)
	var error := Config.save("user://Save.cfg")
	if error != OK:
		print("Failed to save stats. Error code: ", error)

func Load_Stats() -> void:
	var Config: ConfigFile = ConfigFile.new()
	if Config.load("user://Save.cfg") == OK:
		Highscore = Config.get_value("Stats", "Highscore", 0)
		Most_Enemies_Killed = Config.get_value("Stats", "Most Enemies Killed", 0)
		Best_Time = Config.get_value("Stats", "Best Time", 0.0)
		Total_Lifetime_Hits = Config.get_value("Stats", "Total Lifetime Hits", 0)
		Highest_Lifetime_Combo = Config.get_value("Stats", "Highest Lifetime Combo", 0)
