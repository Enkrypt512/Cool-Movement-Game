extends Control

@export var IP_Address:String = "127.0.0.1"
@onready var Host: Button = $Host
@onready var Join: Button = $Join
@onready var Main: Control = $"."
@onready var Start: Button = $"../Start"
@onready var Settings_Button: Button = $"../Settings_Button"
@onready var Quit: Button = $"../Quit"
@onready var Start_Game: Button = $"Start Game"
@export var Port:int = 8789
var Peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	multiplayer.peer_connected.connect(Player_Connected)
	multiplayer.peer_disconnected.connect(Player_Disconnected)
	multiplayer.connected_to_server.connect(Connected_To_Server)
	multiplayer.connection_failed.connect(Connection_To_Server_Failed)
	Host.pressed.connect(On_Host_Pressed)
	Join.pressed.connect(On_Join_Pressed)
	Start_Game.pressed.connect(func(): StartGame.rpc())

func Player_Connected(ID):
	print("Player Connected To Server Sucsessfully!:" + str(ID))

func Player_Disconnected(ID):
	print("Player Disconnected From Server:" + str(ID))

func Connected_To_Server():
	print("Connected To Server Sucessfully!")

func Connection_To_Server_Failed():
	print("Connection To Server Failed")

func On_Host_Pressed():
	Peer.create_server(Port)
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

func On_Join_Pressed():
	Peer.create_client(IP_Address,Port)
	Peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(Peer)

func Spawn_Player(ID = 1):
	var Player_Instance = preload("res://Scenes/Player.tscn").instantiate()
	Player_Instance.name = str(ID)
	call_deferred("add_child",Player_Instance)

func Delete_Player(ID):
	rpc("RPC_Delete_Player",ID)

@rpc("any_peer","call_remote")
func RPC_Delete_Player(ID):
	get_node(str(ID)).queue_free()

@rpc("any_peer","call_local")
func StartGame():
	var Scene_Instance = preload("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(Scene_Instance)
	Main.hide()
	Start.hide()
	Quit.hide()
	Settings_Button.hide()
