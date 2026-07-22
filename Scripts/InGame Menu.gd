extends Control

var Current_Button : Button
@export var Save_Path:String = "user://Settings.cfg"

@onready var Forward: Button = $Settings/Binds/Forward
@onready var Backward: Button = $Settings/Binds/Backward
@onready var Left: Button = $Settings/Binds/Left
@onready var Right: Button = $Settings/Binds/Right
@onready var Sprint: Button = $Settings/Binds/Sprint
@onready var Crouch: Button = $Settings/Binds/Crouch
@onready var Freelook: Button = $Settings/Binds/Freelook
@onready var Jump: Button = $Settings/Binds/Jump
@onready var Change_Weapon: Button = $"Settings/Binds/Change Gun"
@onready var Shoot: Button = $Settings/Binds/Shoot
@onready var Exit: Button = $Settings/Binds/Exit
@onready var Reset: Button = $Settings/Binds/Reset
@onready var Forward_Label: Label = $"Settings/Binds/Forward Label"
@onready var Backward_Label: Label = $"Settings/Binds/Backward Label"
@onready var Left_Label: Label = $"Settings/Binds/Left Label"
@onready var Right_Label: Label = $"Settings/Binds/Right Label"
@onready var Sprint_Label: Label = $"Settings/Binds/Sprint Label"
@onready var Crouch_Label: Label = $"Settings/Binds/Crouch Label"
@onready var Freelook_Label: Label = $"Settings/Binds/Freelook Label"
@onready var Jump_Label: Label = $"Settings/Binds/Jump Label"
@onready var Change_Weapon_Label: Label = $"Settings/Binds/Change Gun Label"
@onready var Shoot_Label: Label = $"Settings/Binds/Shoot Label"
@onready var Exit_Label: Label = $"Settings/Binds/Exit Label"
@onready var Settings_Button: Button = $Settings_Button
@onready var Settings_Quit: Button = $Settings/Quit
@onready var Info_Panel: PanelContainer = $Settings/Binds/PanelContainer
@onready var Settings: Control = $Settings
@onready var Main: Control = $Settings/Main
@onready var Binds: Control = $Settings/Binds
@onready var Bindings_Quit: Button = $Settings/Binds/Quit
@onready var Start: Button = $Start
@onready var Quit: Button = $Quit
@onready var Bindings: Button = $Settings/Main/Bindings
@onready var Fullscreen_Check: CheckBox = $"Settings/Main/Fullscreen Check"
@onready var FPS_Check: CheckBox = $"Settings/Main/FPS Check"
@onready var Volume_Slider: HSlider = $"Settings/Main/Volume Slider"
@onready var Mouse_Sensitivity_Number: SpinBox = $"Settings/Main/Mouse Sensitivity Number"
@onready var Joystick_Sensitivity_Number: SpinBox = $"Settings/Main/Joystick Sensitivity Number"
@onready var VSync_Check: CheckBox = $"Settings/Main/VSync Check"
@onready var FPS_Lock_Number: SpinBox = $"Settings/Main/FPS Lock Number"
@onready var Toggle_Sprint_Check: CheckBox = $"Settings/Main/Toggle Sprint Check"
@onready var Toggle_Crouch_Check: CheckBox = $"Settings/Main/Toggle Crouch Check"
@onready var No_Shake_Check: CheckBox = $"Settings/Main/No Shake Check"
@onready var InGame_Menu: Control = $"."
@onready var Back_To_Menu: Button = $"Back To Menu"
@onready var Reset_Settings: Button = $Settings/Main/Reset

func _ready() -> void:
	Load_Game_Settings()
	Forward.pressed.connect(On_Button_Pressed.bind(Forward))
	Backward.pressed.connect(On_Button_Pressed.bind(Backward))
	Left.pressed.connect(On_Button_Pressed.bind(Left))
	Right.pressed.connect(On_Button_Pressed.bind(Right))
	Sprint.pressed.connect(On_Button_Pressed.bind(Sprint))
	Crouch.pressed.connect(On_Button_Pressed.bind(Crouch))
	Freelook.pressed.connect(On_Button_Pressed.bind(Freelook))
	Jump.pressed.connect(On_Button_Pressed.bind(Jump))
	Change_Weapon.pressed.connect(On_Button_Pressed.bind(Change_Weapon))
	Shoot.pressed.connect(On_Button_Pressed.bind(Shoot))
	Exit.pressed.connect(On_Button_Pressed.bind(Exit))
	Reset.pressed.connect(Reset_To_Defaults)
	Reset_Settings.pressed.connect(Reset_Settings_To_Default)
	Settings_Button.pressed.connect(Change_To_Settings)
	Settings_Quit.pressed.connect(Quit_From_Settings)
	Fullscreen_Check.toggled.connect(On_Fullscreen_Toggled)
	VSync_Check.toggled.connect(On_VSync_Toggled)
	Bindings.pressed.connect(Change_To_Bindings)
	Bindings_Quit.pressed.connect(Quit_From_Bindings)
	Quit.pressed.connect(func(): get_tree().quit())
	Start.pressed.connect(func(): Save_Game_Settings(); InGame_Menu.visible = false)
	Back_To_Menu.pressed.connect(func (): get_tree().change_scene_to_file("res://Scenes/Menu.tscn"))
	Update_Labels()
	Info_Panel.hide()

func On_Button_Pressed(button: Button) -> void:
	Current_Button = button
	Info_Panel.show()

func _process(_delta: float) -> void:
	GameManager.FPS_Counter = FPS_Check.button_pressed
	GameManager.Fullscreen = Fullscreen_Check.button_pressed
	GameManager.Volume = Volume_Slider.value  
	GameManager.Mouse_Sensitivity = Mouse_Sensitivity_Number.value
	GameManager.Joystick_Sensitivity = Joystick_Sensitivity_Number.value
	GameManager.VSync = VSync_Check.button_pressed
	GameManager.Toggle_Sprint = Toggle_Sprint_Check.button_pressed
	GameManager.Toggle_Crouch = Toggle_Crouch_Check.button_pressed
	GameManager.No_Shake = No_Shake_Check.button_pressed

func _input(event: InputEvent) -> void:
	if Current_Button == null:
		return

	if event is InputEventMouseMotion or event is InputEventPanGesture:
		return
		
	if event is InputEventJoypadMotion and abs(event.axis_value) < 0.5:
		return
	
	get_viewport().set_input_as_handled()
	
	var Target_Action : String = Current_Button.name
	if not InputMap.has_action(Target_Action) and InputMap.has_action(Target_Action.to_lower()):
		Target_Action = Target_Action.to_lower()
		
	for Existing_Event in InputMap.action_get_events(Target_Action):
		if Existing_Event.is_match(event):
			Finish_Remapping()
			return

	for Action in InputMap.get_actions():
		if Action != Target_Action:
			for Action_Event in InputMap.action_get_events(Action):
				if Action_Event.is_match(event):
					InputMap.action_erase_event(Action, Action_Event)
					
	InputMap.action_add_event(Target_Action, event)
	Finish_Remapping()

func Finish_Remapping() -> void:
	Current_Button = null
	Info_Panel.hide()
	Update_Labels()

func Update_Labels() -> void:
	Set_Label_Text(Forward_Label, "Forward")
	Set_Label_Text(Backward_Label, "Backward")
	Set_Label_Text(Left_Label, "Left")
	Set_Label_Text(Right_Label, "Right")
	Set_Label_Text(Sprint_Label,"Sprint")
	Set_Label_Text(Crouch_Label,"Crouch")
	Set_Label_Text(Freelook_Label,"Freelook")
	Set_Label_Text(Jump_Label,"Jump")
	Set_Label_Text(Change_Weapon_Label,"Change Weapon")
	Set_Label_Text(Shoot_Label,"Shoot")
	Set_Label_Text(Exit_Label,"Exit")

func Set_Label_Text(label: Label, Action_Name: String) -> void:
	var Actual_Action:String = Action_Name
	if not InputMap.has_action(Actual_Action) and InputMap.has_action(Action_Name.to_lower()):
		Actual_Action = Action_Name.to_lower()
	
	var Events : Array[InputEvent] = InputMap.action_get_events(Actual_Action)
	if !Events.is_empty():
		var Text_List : Array[String] = []
		for Event in Events:
			Text_List.append(Event.as_text())
		label.text = " | ".join(Text_List)
	else:
		label.text = "None"

func Reset_To_Defaults() -> void:
	InputMap.load_from_project_settings()
	Update_Labels()

func Reset_Settings_To_Default() -> void:
	GameManager.Volume = 100.0
	GameManager.Fullscreen = false
	GameManager.FPS_Counter = false
	GameManager.VSync = true
	GameManager.Mouse_Sensitivity = 0.5
	GameManager.Joystick_Sensitivity = 3.0
	GameManager.Max_FPS = 0
	GameManager.Toggle_Sprint = false
	GameManager.Toggle_Crouch = false
	GameManager.No_Shake = false
	Apply_Loaded_Settings()


func Clear_Action_Inputs(Action_Name: String) -> void:
	InputMap.action_erase_events(Action_Name)
	Update_Labels()

func Change_To_Settings():
	Settings.visible = true
	Main.visible = true
	Binds.visible = false
	Start.visible = false
	Quit.visible = false
	Settings_Button.visible = false
	Back_To_Menu.visible = false

func Quit_From_Settings():
	Save_Game_Settings()
	Settings.visible = false
	Start.visible = true
	Quit.visible = true
	Settings_Button.visible = true
	Back_To_Menu.visible = true

func Change_To_Bindings():
	Main.visible = false
	Settings_Quit.visible = false
	Binds.visible = true

func Quit_From_Bindings():
	Save_Game_Settings()
	Settings.visible = true
	Main.visible = true
	Binds.visible = false
	Start.visible = false
	Quit.visible = false
	Settings_Button.visible = false
	Settings_Quit.visible = true
	Engine.max_fps = FPS_Lock_Number.value


func Save_Game_Settings() -> void:
	var Config:ConfigFile = ConfigFile.new()
	Config.set_value("Settings", "Volume", GameManager.Volume)
	Config.set_value("Settings", "Fullscreen", GameManager.Fullscreen)
	Config.set_value("Settings", "FPS Counter", GameManager.FPS_Counter)
	Config.set_value("Settings", "Mouse Senstivity", GameManager.Mouse_Sensitivity)
	Config.set_value("Settings", "Joystick Senstivity", GameManager.Joystick_Sensitivity)
	Config.set_value("Settings", "VSync", GameManager.VSync)
	Config.set_value("Settings", "Max FPS", GameManager.Max_FPS)
	Config.set_value("Settings", "Toggle Sprint", GameManager.Toggle_Sprint)
	Config.set_value("Settings", "Toggle Crouch", GameManager.Toggle_Crouch)
	Config.set_value("Settings", "No Shake", GameManager.No_Shake)
	var Actions:Array = ["Forward", "Backward", "Left", "Right","Sprint","Crouch","Freelook","Jump","Exit","Shoot","Change Gun"]
	for Action in Actions:
		var Actual_Action:String = Action
		if not InputMap.has_action(Actual_Action) and InputMap.has_action(Action.to_lower()):
			Actual_Action = Action.to_lower()
		var Events := InputMap.action_get_events(Actual_Action)
		Config.set_value("Binds", Action, Events)
			
	var error := Config.save(Save_Path)
	if error != OK:
		print("Failed to save settings. Error code: ", error)

func Load_Game_Settings() -> void:
	var Config:ConfigFile = ConfigFile.new()
	var error = Config.load(Save_Path)
	if error != OK:
		print("No save file found. Using default values.")
		GameManager.Volume = 100.0
		GameManager.Fullscreen = false
		GameManager.FPS_Counter = false
		GameManager.VSync = true
		GameManager.Mouse_Sensitivity = 0.5
		GameManager.Joystick_Sensitivity = 3.0
		GameManager.Max_FPS = 0
		GameManager.Toggle_Sprint = false
		GameManager.Toggle_Crouch = false
		GameManager.No_Shake = false
	else:
		GameManager.Volume = Config.get_value("Settings", "Volume", 100.0)
		GameManager.Fullscreen = Config.get_value("Settings", "Fullscreen", false)
		GameManager.FPS_Counter = Config.get_value("Settings", "FPS Counter", false)
		GameManager.VSync = Config.get_value("Settings", "VSync", true)
		GameManager.Max_FPS = Config.get_value("Settings","Max FPS",0)
		GameManager.Toggle_Sprint = Config.get_value("Settings","Toggle Sprint",false)
		GameManager.Toggle_Crouch = Config.get_value("Settings","Toggle Crouch",false)
		GameManager.No_Shake = Config.get_value("Settings","No Shake",false)
		var Loaded_Mouse_Sensitivity:float = Config.get_value("Settings", "Mouse Senstivity", 0.5)
		if Loaded_Mouse_Sensitivity == null:
			GameManager.Mouse_Sensitivity = 0.5
		else:
			GameManager.Mouse_Sensitivity = Loaded_Mouse_Sensitivity
		var Loaded_Joystick_Sensitivity:float = Config.get_value("Settings", "Joystick Senstivity", 3.0)
		if Loaded_Joystick_Sensitivity == null:
			GameManager.Joystick_Sensitivity = 3.0
		else:
			GameManager.Joystick_Sensitivity = Loaded_Joystick_Sensitivity
		var Actions:Array = ["Forward", "Backward", "Left", "Right","Sprint","Crouch","Freelook","Jump","Exit","Shoot","Change Gun"]
		for Action in Actions:
			if Config.has_section_key("Binds", Action):
				# Dont Know What Type Is Raw_Data :p
				var Raw_Data = Config.get_value("Binds", Action)
				
				var Actual_Action:String = Action
				if not InputMap.has_action(Actual_Action) and InputMap.has_action(Action.to_lower()):
					Actual_Action = Action.to_lower()
					
				InputMap.action_erase_events(Actual_Action)
				
				if Raw_Data is Array:
					for Event in Raw_Data:
						if Event is InputEvent:
							InputMap.action_add_event(Actual_Action, Event)
				elif Raw_Data is InputEvent:
					InputMap.action_add_event(Actual_Action, Raw_Data)
						
	Apply_Loaded_Settings()

func Apply_Loaded_Settings() -> void:
	Volume_Slider.value = GameManager.Volume
	Fullscreen_Check.button_pressed = GameManager.Fullscreen
	FPS_Check.button_pressed = GameManager.FPS_Counter
	Mouse_Sensitivity_Number.value = GameManager.Mouse_Sensitivity
	Joystick_Sensitivity_Number.value = GameManager.Joystick_Sensitivity
	VSync_Check.button_pressed = GameManager.VSync
	FPS_Lock_Number.value = GameManager.Max_FPS
	Toggle_Sprint_Check.button_pressed = GameManager.Toggle_Sprint
	Toggle_Crouch_Check.button_pressed = GameManager.Toggle_Crouch
	No_Shake_Check.button_pressed = GameManager.No_Shake
	if GameManager.Fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Update_Labels()
	
	if GameManager.VSync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	VSync_Check.button_pressed = GameManager.VSync
	
	Engine.max_fps = GameManager.Max_FPS

func On_Fullscreen_Toggled(Is_Checked: bool) -> void:
	GameManager.Fullscreen = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func On_VSync_Toggled(Is_Checked: bool) -> void:
	GameManager.VSync = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
