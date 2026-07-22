extends Control

var Player: CharacterBody3D = null
@onready var Died: Control = $"."
@onready var Menu: Control = $"../Control"
@onready var Return_To_Menu: Button = $"Return To Menu"
@onready var Quit: Button = $Quit
@onready var InGame_Menu: Control = $"../Control"

func _ready() -> void:
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

func _process(_delta: float) -> void:
	if Player == null or not ("Health" in Player):
		return
	
	if Player.Health <= 0:
		if not Died.visible: 
			Died.visible = true
			Menu.visible = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if Died.visible:
			Died.visible = false
			if not InGame_Menu.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
