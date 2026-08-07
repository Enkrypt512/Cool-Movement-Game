extends Control

# Misc Variables
var Current_Button : Button
@export var Save_Path:String = "user://Settings.cfg"
var Current_Song: AudioStreamPlayer = null

# Nodes
@onready var Forward: Button = $Settings/Binds/Forward
@onready var Backward: Button = $Settings/Binds/Backward
@onready var Left: Button = $Settings/Binds/Left
@onready var Right: Button = $Settings/Binds/Right
@onready var Jump: Button = $Settings/Binds/Jump
@onready var Exit: Button = $Settings/Binds/Exit
@onready var Change_Gun: Button = $"Settings/Binds/Change Gun"
@onready var Shoot: Button = $Settings/Binds/Shoot
@onready var Reset_Bindings: Button = $Settings/Binds/Reset
@onready var Forward_Label: Label = $"Settings/Binds/Forward Label"
@onready var Backward_Label: Label = $"Settings/Binds/Backward Label"
@onready var Left_Label: Label = $"Settings/Binds/Left Label"
@onready var Right_Label: Label = $"Settings/Binds/Right Label"
@onready var Settings_Button: Button = $'Main/Settings Button'
@onready var Settings_Quit: Button = $Settings/Quit
@onready var Info_Panel: PanelContainer = $Settings/Binds/PanelContainer
@onready var Settings: Control = $Settings
@onready var Credits: Control = $Credits
@onready var Binds: Control = $Settings/Binds
@onready var Bindings_Quit: Button = $Settings/Binds/Quit
@onready var Start: Button = $Main/Start
@onready var Credits_Button: Button = $"Main/Credits Button"
@onready var Quit: Button = $Main/Quit
@onready var Bindings: Button = $Settings/Main/Bindings
@onready var Fullscreen_Check: CheckBox = $"Settings/Main/Fullscreen Check"
@onready var FPS_Check: CheckBox = $"Settings/Main/FPS Check"
@onready var Speedometer_Check: CheckBox = $"Settings/Main/Speedometer Check"
@onready var FPS_Counter: Label = $"Main/FPS Counter"
@onready var Mouse_Sensitivity_Number: SpinBox = $"Settings/Main/Mouse Sensitivity Number"
@onready var Volume_Slider: HSlider = $"Settings/Main/Volume Slider"
@onready var VSync_Check: CheckBox = $"Settings/Main/VSync Check"
@onready var FPS_Lock_Number: SpinBox = $"Settings/Main/FPS Lock Number"
@onready var Toggle_Sprint_Check: CheckBox = $"Settings/Main/Toggle Sprint Check"
@onready var Toggle_Crouch_Check: CheckBox = $"Settings/Main/Toggle Crouch Check"
@onready var No_Shake_Check: CheckBox = $"Settings/Main/No Shake Check"
@onready var Main: Control = $Settings/Main
@onready var Sprint: Button = $Settings/Binds/Sprint
@onready var Crouch: Button = $Settings/Binds/Crouch
@onready var Freelook: Button = $Settings/Binds/Freelook
@onready var Sprint_Label: Label = $"Settings/Binds/Sprint Label"
@onready var Crouch_Label: Label = $"Settings/Binds/Crouch Label"
@onready var Freelook_Label: Label = $"Settings/Binds/Freelook Label"
@onready var Jump_Label: Label = $"Settings/Binds/Jump Label"
@onready var Change_Gun_Label: Label = $"Settings/Binds/Change Gun Label"
@onready var Shoot_Label: Label = $"Settings/Binds/Shoot Label"
@onready var Exit_Label: Label = $"Settings/Binds/Exit Label"
@onready var Reset_Settings: Button = $Settings/Main/Reset
@onready var Quit_Credits: Button = $Credits/Quit
@onready var Keys: Control = $Keys
@onready var Keys_Button: Button = $"Main/Keys Button"
@onready var Keys_Quit: Button = $Keys/Quit
@onready var Version: Label = $Main/Version
@onready var Anti_Aliasing_Drop_Down: OptionButton = $"Settings/Main/Anti-Aliasing Drop Down"
@onready var Music_1: AudioStreamPlayer = $"Music/1"
@onready var Music_2: AudioStreamPlayer = $"Music/2"
@onready var Music_3: AudioStreamPlayer = $"Music/3"
@onready var Music_4: AudioStreamPlayer = $"Music/4"
@onready var Music_5: AudioStreamPlayer = $"Music/5"
@onready var Music_6: AudioStreamPlayer = $"Music/6"
@onready var Music_7: AudioStreamPlayer = $"Music/7"
@onready var Music_8: AudioStreamPlayer = $"Music/8"
@onready var Music_9: AudioStreamPlayer = $"Music/9"
@onready var Music_10: AudioStreamPlayer = $"Music/10"
@onready var Music_11: AudioStreamPlayer = $"Music/11"
@onready var Music: Array = [
	Music_1,
	Music_2,
	Music_3,
	Music_4,
	Music_5,
	Music_6,
	Music_7,
	Music_8,
	Music_9,
	Music_10,
	Music_11,
]
@onready var Renderer_Drop_Down: OptionButton = $"Settings/Main/Renderer Drop Down"

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
	Reset_Bindings.pressed.connect(Reset_Bindings_To_Default)
	Reset_Settings.pressed.connect(Reset_Settings_To_Default)
	Settings_Button.pressed.connect(func():Settings.visible = true)
	Settings_Quit.pressed.connect(Quit_From_Settings)
	Fullscreen_Check.toggled.connect(On_Fullscreen_Toggled)
	VSync_Check.toggled.connect(On_VSync_Toggled)
	Bindings.pressed.connect(Change_To_Bindings)
	Bindings_Quit.pressed.connect(Quit_From_Bindings)
	Quit.pressed.connect(func(): get_tree().quit())
	Start.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Main.tscn"))
	Exit.pressed.connect(On_Button_Pressed.bind(Exit))
	Shoot.pressed.connect(On_Button_Pressed.bind(Shoot))
	Change_Gun.pressed.connect(On_Button_Pressed.bind(Change_Gun))
	Credits_Button.pressed.connect(func(): Credits.visible = true)
	Quit_Credits.pressed.connect(func(): Credits.hide())
	FPS_Lock_Number.value_changed.connect(On_Max_FPS_Changed)
	Keys_Button.pressed.connect(func():Keys.visible = true)
	Keys_Quit.pressed.connect(func(): Keys.visible = false)
	Anti_Aliasing_Drop_Down.item_selected.connect(Change_Anti_Aliasing_Mode)
	Version.text = "Version:" + str(ProjectSettings.get_setting("application/config/version"))
	Renderer_Drop_Down.item_selected.connect(Change_Renderer_Mode)
	Update_Labels()
	Info_Panel.hide()
	var Random_Song: AudioStreamPlayer = Music.pick_random()
	Play_Song_With_Fade(Random_Song, 2.0)
	for Song in Music:
		Song.finished.connect(func():
			var Next_Song: AudioStreamPlayer = Music.pick_random()
			while Next_Song == Current_Song && Music.size() > 1:
				Next_Song = Music.pick_random()
			Play_Song_With_Fade(Next_Song, 2.0)
		)

func On_Button_Pressed(button: Button) -> void:
	Current_Button = button
	Info_Panel.show()

func _process(delta: float) -> void:
	if FPS_Check.button_pressed:
		GameManager.FPS_Counter = true
		FPS_Counter.text = 'FPS:' + str(int(Engine.get_frames_per_second()))
		FPS_Counter.visible = true
	else:
		GameManager.FPS_Counter = false
		FPS_Counter.text = ''
		FPS_Counter.visible = false
	GameManager.FPS_Counter = FPS_Check.button_pressed
	GameManager.Fullscreen = Fullscreen_Check.button_pressed
	GameManager.Volume = Volume_Slider.value
	GameManager.Mouse_Sensitivity = Mouse_Sensitivity_Number.value
	GameManager.VSync = VSync_Check.button_pressed
	GameManager.Max_FPS = int(FPS_Lock_Number.value)
	GameManager.Toggle_Sprint = Toggle_Sprint_Check.button_pressed
	GameManager.Toggle_Crouch = Toggle_Crouch_Check.button_pressed
	GameManager.No_Shake = No_Shake_Check.button_pressed
	GameManager.Speedometer = Speedometer_Check.button_pressed
	GameManager.Anti_Aliasing_Mode = Anti_Aliasing_Drop_Down.selected
	GameManager.Renderer = Renderer_Drop_Down.selected
	for Song in Music:
		Song.volume_db = linear_to_db(GameManager.Volume / 100.0)

func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.keycode == KEY_F11 && event.pressed:
		var Is_Fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		Fullscreen_Check.toggled.disconnect(On_Fullscreen_Toggled)
		On_Fullscreen_Toggled(!Is_Fullscreen)
		Fullscreen_Check.button_pressed = !Is_Fullscreen
		Fullscreen_Check.toggled.connect(On_Fullscreen_Toggled)
		get_viewport().set_input_as_handled()
		Save_Game_Settings()
		Apply_Loaded_Settings()
		return
	if !Current_Button:
		return
	if event is InputEventMouseMotion || event is InputEventPanGesture:
		return
	get_viewport().set_input_as_handled()
	var Target_Action: String = Current_Button.name
	if !InputMap.has_action(Target_Action) && InputMap.has_action(Target_Action.to_lower()):
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
	Set_Label_Text(Exit_Label,"Exit")
	Set_Label_Text(Shoot_Label,"Shoot")
	Set_Label_Text(Change_Gun_Label,"Change Gun")

func Set_Label_Text(label: Label, Action_Name: String) -> void:
	var Actual_Action: String = Action_Name
	if !InputMap.has_action(Actual_Action) && InputMap.has_action(Action_Name.to_lower()):
		Actual_Action = Action_Name.to_lower()
	var Events : Array = InputMap.action_get_events(Actual_Action)
	if !Events.is_empty():
		var Text_List : Array[String] = []
		for Event in Events:
			Text_List.append(Event.as_text())
		label.text = " | ".join(Text_List)
	else:
		label.text = "None"

# Reset Bindings
func Reset_Bindings_To_Default() -> void:
	InputMap.load_from_project_settings()
	Update_Labels()

# Reset Settings
func Reset_Settings_To_Default() -> void:
	GameManager.Volume = 100.0
	GameManager.Fullscreen = false
	GameManager.FPS_Counter = false
	GameManager.VSync = true
	GameManager.Mouse_Sensitivity = 0.5
	GameManager.Max_FPS = 0
	GameManager.Toggle_Sprint = false
	GameManager.Toggle_Crouch = false
	GameManager.No_Shake = false
	GameManager.Speedometer = false
	GameManager.Anti_Aliasing_Mode = 0
	GameManager.Renderer = 0
	Apply_Loaded_Settings()

func Clear_Action_Inputs(Action_Name: String) -> void:
	InputMap.action_erase_events(Action_Name)
	Update_Labels()

# Quit From Settings Menu
func Quit_From_Settings():
	Settings.visible = false
	GameManager.Max_FPS = int(FPS_Lock_Number.value)
	Engine.max_fps = GameManager.Max_FPS
	Save_Game_Settings()

# Change To Bindings Menu
func Change_To_Bindings():
	Main.visible = false
	Settings_Quit.visible = false
	Binds.visible = true

# Quit From Bindings Menu
func Quit_From_Bindings():
	Save_Game_Settings()
	Settings.visible = true
	Main.visible = true
	Settings_Quit.visible = true
	Binds.visible = false

# Toggle Fullscreen
func On_Fullscreen_Toggled(Is_Checked: bool) -> void:
	GameManager.Fullscreen = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if Settings.visible:
		Save_Game_Settings()

# Toggle VSync
func On_VSync_Toggled(Is_Checked: bool) -> void:
	GameManager.VSync = Is_Checked
	if Is_Checked:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if Settings.visible:
		Save_Game_Settings()

# Save Settings
func Save_Game_Settings() -> void:
	var Config: ConfigFile = ConfigFile.new()
	Config.set_value("Settings", "Volume", GameManager.Volume)
	Config.set_value("Settings", "Fullscreen", GameManager.Fullscreen)
	Config.set_value("Settings", "FPS Counter", GameManager.FPS_Counter)
	Config.set_value("Settings", "Mouse Senstivity", GameManager.Mouse_Sensitivity)
	Config.set_value("Settings", "VSync", GameManager.VSync)
	Config.set_value("Settings", "Max FPS", GameManager.Max_FPS)
	Config.set_value("Settings", "Toggle Sprint", GameManager.Toggle_Sprint)
	Config.set_value("Settings", "Toggle Crouch", GameManager.Toggle_Crouch)
	Config.set_value("Settings", "No Shake", GameManager.No_Shake)
	Config.set_value("Settings", "Speedometer", GameManager.Speedometer)
	Config.set_value("Settings","Anti-Aliasing Mode",GameManager.Anti_Aliasing_Mode)
	Config.set_value("Settings","Renderer",GameManager.Renderer)
	var Actions: Array = ["Forward", "Backward", "Left", "Right","Sprint","Crouch","Freelook","Jump","Exit","Shoot","Change Gun"]
	for Action in Actions:
		var Actual_Action: String = Action
		if !InputMap.has_action(Actual_Action) && InputMap.has_action(Action.to_lower()):
			Actual_Action = Action.to_lower()
		var Events: Array = InputMap.action_get_events(Actual_Action)
		Config.set_value("Binds", Action, Events)
	var error: Error = Config.save(Save_Path)
	if error != OK:
		print("Failed to save settings. Error code: ", error)

# Load Settings
func Load_Game_Settings() -> void:
	var Config: ConfigFile = ConfigFile.new()
	var error: Error = Config.load(Save_Path)
	if error != OK:
		print("No save file found. Using default values.")
		GameManager.Volume = 100.0
		GameManager.Fullscreen = false
		GameManager.FPS_Counter = false
		GameManager.VSync = true
		GameManager.Mouse_Sensitivity = 0.5
		GameManager.Max_FPS = 0
		GameManager.Toggle_Sprint = false
		GameManager.Toggle_Crouch = false
		GameManager.No_Shake = false
		GameManager.Speedometer = false
		GameManager.Anti_Aliasing_Mode = 0
		GameManager.Renderer = 0
	else:
		GameManager.Volume = Config.get_value("Settings", "Volume", 100.0)
		GameManager.Fullscreen = Config.get_value("Settings", "Fullscreen", false)
		GameManager.FPS_Counter = Config.get_value("Settings", "FPS Counter", false)
		GameManager.VSync = Config.get_value("Settings", "VSync", true)
		GameManager.Max_FPS = Config.get_value("Settings","Max FPS",0)
		GameManager.Toggle_Sprint = Config.get_value("Settings","Toggle Sprint",false)
		GameManager.Toggle_Crouch = Config.get_value("Settings","Toggle Crouch",false)
		GameManager.No_Shake = Config.get_value("Settings","No Shake",false)
		GameManager.Speedometer = Config.get_value("Settings","Speedometer",false)
		GameManager.Anti_Aliasing_Mode = Config.get_value("Settings","Anti-Aliasing Mode",0)
		GameManager.Renderer = Config.get_value("Settings","Renderer",0)
		var Loaded_Mouse_Sensitivity: float = Config.get_value("Settings", "Mouse Senstivity", 0.5)
		if Loaded_Mouse_Sensitivity == null:
			GameManager.Mouse_Sensitivity = 0.5
		else:
			GameManager.Mouse_Sensitivity = Loaded_Mouse_Sensitivity
		var Actions: Array = ["Forward", "Backward", "Left", "Right","Sprint","Crouch","Freelook","Jump","Exit","Shoot","Change Gun"]
		for Action in Actions:
			if Config.has_section_key("Binds", Action):
				var Raw_Data = Config.get_value("Binds", Action)
				var Actual_Action: String = Action
				if !InputMap.has_action(Actual_Action) && InputMap.has_action(Action.to_lower()):
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
	VSync_Check.button_pressed = GameManager.VSync
	FPS_Lock_Number.value = GameManager.Max_FPS
	Toggle_Sprint_Check.button_pressed = GameManager.Toggle_Sprint
	Toggle_Crouch_Check.button_pressed = GameManager.Toggle_Crouch
	No_Shake_Check.button_pressed = GameManager.No_Shake
	Speedometer_Check.button_pressed = GameManager.Speedometer
	Anti_Aliasing_Drop_Down.selected = GameManager.Anti_Aliasing_Mode
	Renderer_Drop_Down.selected = GameManager.Renderer
	if GameManager.Fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	FPS_Counter.visible = GameManager.FPS_Counter
	Update_Labels()
	if GameManager.VSync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	VSync_Check.button_pressed = GameManager.VSync
	Engine.max_fps = GameManager.Max_FPS
	if Anti_Aliasing_Drop_Down.selected == 0:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",0)
	elif Anti_Aliasing_Drop_Down.selected == 1:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",1)
	elif Anti_Aliasing_Drop_Down.selected == 2:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",2)
	elif Anti_Aliasing_Drop_Down.selected == 3:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",3)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",3)

# Change Max FPS
func On_Max_FPS_Changed(Value: float) -> void:
	GameManager.Max_FPS = int(Value)
	Engine.max_fps = int(Value)

# Change Anti-Aliasing Mode
func Change_Anti_Aliasing_Mode(Selected: int):
	if Selected == 0:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",0)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",0)
		GameManager.Anti_Aliasing_Mode = 0
	elif Selected == 1:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",1)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",1)
		GameManager.Anti_Aliasing_Mode = 1
	elif Selected == 2:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",2)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",2)
		GameManager.Anti_Aliasing_Mode = 2
	elif Selected == 3:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d",3)
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d",3)
		GameManager.Anti_Aliasing_Mode = 3

# Play Menu Music
func Play_Song_With_Fade(Next_Song: AudioStreamPlayer, Fade_Duration: float = 1.5) -> void:
	var Target_Decibels: float = linear_to_db(GameManager.Volume / 100.0)
	if Current_Song && Current_Song != Next_Song && Current_Song.playing:
		var Fade_Out_Tween: Tween = create_tween()
		Fade_Out_Tween.tween_property(Current_Song, "volume_db", -80.0, Fade_Duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		Fade_Out_Tween.tween_callback(Current_Song.stop)
	Current_Song = Next_Song
	Current_Song.volume_db = -80.0
	Current_Song.play()
	var Fade_In_Tween: Tween = create_tween()
	Fade_In_Tween.tween_property(Current_Song, "volume_db", Target_Decibels, Fade_Duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func Change_Renderer_Mode(Index: int) -> void:
	var Rendering_Method = "forward_plus"
	if Index == 1:
		Rendering_Method = "gl_compatibility"
	ProjectSettings.set_setting("rendering/renderer/rendering_method", Rendering_Method)
	ProjectSettings.set_setting("rendering/renderer/rendering_method.mobile", Rendering_Method)
	Save_Game_Settings()
	if OS.has_feature("editor"):
		print("Renderer changes require an exported build to restart automatically.")
		return
	var Arguments = OS.get_cmdline_args()
	for Argument in range(Arguments.size() - 1, -1, -1):
		if Arguments[Argument].begins_with("--rendering-method"):
			Arguments.remove_at(Argument)
	Arguments.append("--rendering-method")
	Arguments.append(Rendering_Method)
	OS.set_restart_on_exit(true, Arguments)
	get_tree().quit()
