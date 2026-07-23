extends Control

var Player: CharacterBody3D = null
@onready var Died: Control = $"."
@onready var Menu: Control = $"../Control"
@onready var Return_To_Menu: Button = $"Return To Menu"
@onready var Quit: Button = $Quit
@onready var InGame_Menu: Control = $"../Control"
@onready var Crosshair: Sprite2D = $"../Player/Crosshair"
@onready var HUD: Control = $"../Player/HUD"
@export var Deadzone:float = 0.2
var Virtual_Mouse_Position:Vector2 = Vector2.ZERO

func _ready() -> void:
	Virtual_Mouse_Position = get_viewport().get_mouse_position()
	Return_To_Menu.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/Menu.tscn"))
	Quit.pressed.connect(func(): get_tree().quit())
	get_tree().node_added.connect(On_Node_Added)
	Find_Local_Player()

func On_Node_Added(node: Node) -> void:
	if Player == null and node.is_in_group("Player") and node.is_multiplayer_authority():
		Player = node as CharacterBody3D

func Find_Local_Player() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.is_multiplayer_authority():
			Player = player as CharacterBody3D
			break

func _process(delta: float) -> void:
	if Player == null or not ("Health" in Player):
		return
	
	if Player.Health <= 0:
		if not Died.visible: 
			Died.visible = true
			Crosshair.visible = false
			HUD.visible = false
			Menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if Died.visible:
			Died.visible = false
			Crosshair.visible = true
			HUD.visible = true
			if not InGame_Menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		var Raw_Cursor_X_Position:float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var Raw_Cursor_Y_Position:float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		var Stick_Input:Vector2 = Vector2(
			Raw_Cursor_X_Position if abs(Raw_Cursor_X_Position) > Deadzone else 0.0,
			Raw_Cursor_Y_Position if abs(Raw_Cursor_Y_Position) > Deadzone else 0.0
		)
		if Stick_Input != Vector2.ZERO:
			var Speed:float = GameManager.Joystick_Sensitivity * 1200.0
			# Dont Know What Type Is Viewport_Size Is :p
			var Viewport_Size = get_viewport().size
			Virtual_Mouse_Position += Stick_Input * Speed * delta
			Virtual_Mouse_Position.x = clamp(Virtual_Mouse_Position.x, 0.0, Viewport_Size.x)
			Virtual_Mouse_Position.y = clamp(Virtual_Mouse_Position.y, 0.0, Viewport_Size.y)
			Input.warp_mouse(Virtual_Mouse_Position)

func _input(event: InputEvent) -> void:
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
