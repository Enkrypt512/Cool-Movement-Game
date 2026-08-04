extends Control

@export var IP_Address: String = "127.0.0.1"
@export var Port: int = 8789

@onready var Host: Button = $Host
@onready var Join: Button = $Join
@onready var Main: Control = $"."
@onready var Start: Button = $"../Main/Start"
@onready var Settings_Button: Button = $"../Main/Settings Button"
@onready var Quit: Button = $"../Main/Quit"
@onready var Start_Game: Button = $"Start Game"
var Peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	multiplayer.peer_connected.connect(Player_Connected)
	multiplayer.peer_disconnected.connect(Player_Disconnected)
	multiplayer.connected_to_server.connect(Connected_To_Server)
	multiplayer.connection_failed.connect(Connection_To_Server_Failed)
	Host.pressed.connect(On_Host_Pressed)
	Join.pressed.connect(On_Join_Pressed)
	Start_Game.pressed.connect(func(): StartGame.rpc())

func Player_Connected(ID: int) -> void:
	print("Player Connected To Server Successfully!: ", ID)

func Player_Disconnected(ID: int) -> void:
	print("Player Disconnected From Server: ", ID)

func Connected_To_Server() -> void:
	print("Connected To Server Successfully!")

func Connection_To_Server_Failed() -> void:
	print("Connection To Server Failed")

func On_Host_Pressed() -> void:
	var error = Peer.create_server(Port)
	if error != OK:
		print("Failed to host: ", error)
		return
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)
	print("Server hosted on port ", Port)

func On_Join_Pressed() -> void:
	var error = Peer.create_client(IP_Address, Port)
	if error != OK:
		print("Failed to join: ", error)
		return
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

@rpc("call_local", "authority", "reliable")
func StartGame() -> void:
	Main.hide()
	Start.hide()
	Quit.hide()
	Settings_Button.hide()
	if get_tree().root.has_node("Main"):
		return
	var Scene_Instance: Node3D = preload("res://Scenes/Main.tscn").instantiate()
	Scene_Instance.name = "Main"
	get_tree().root.add_child(Scene_Instance)
	if !multiplayer.is_server():
		Client_Ready.rpc_id(1)
	else:
		Scene_Instance.Spawn_All_Players()

@rpc("any_peer", "call_local", "reliable")
func Client_Ready() -> void:
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		var main_node = get_tree().root.get_node_or_null("Main")
		if main_node:
			main_node.Spawn_Player(sender_id)
