extends Control

@export var IP_Address: String = "127.0.0.1"
@onready var Host: Button = $Host
@onready var Join: Button = $Join
@onready var Main: Control = $"."
@onready var Start: Button = $"../Start"
@onready var Settings_Button: Button = $"../Settings Button"
@onready var Quit: Button = $"../Quit"
@onready var Start_Game: Button = $"Start Game"
@export var Port: int = 8789
var Peer = ENetMultiplayerPeer.new()

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
	Peer.create_server(Port)
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

func On_Join_Pressed() -> void:
	Peer.create_client(IP_Address, Port)
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

@rpc("call_local", "authority", "reliable")
func StartGame() -> void:
	var Scene_Instance = preload("res://Scenes/Main.tscn").instantiate()
	Scene_Instance.name = "Main"
	get_tree().root.add_child(Scene_Instance)
	Main.hide()
	Start.hide()
	Quit.hide()
	Settings_Button.hide()
	if multiplayer.is_server():
		Scene_Instance.call_deferred("Spawn_All_Players")
