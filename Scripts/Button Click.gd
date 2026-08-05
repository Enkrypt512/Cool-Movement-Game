extends Node

var Player: AudioStreamPlayer
var Playback: AudioStreamPlaybackPolyphonic

func _enter_tree() -> void:
	Player = AudioStreamPlayer.new()
	add_child(Player)
	var Stream = AudioStreamPolyphonic.new()
	Stream.polyphony = 32
	Player.stream = Stream
	Player.play()
	Playback = Player.get_stream_playback()
	get_tree().node_added.connect(On_Node_Added)

func On_Node_Added(node: Node) -> void:
	if node is Button:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			node.mouse_entered.connect(Play_Hover)
			node.pressed.connect(Play_Pressed)

func Play_Hover() -> void:
	Player.volume_db = linear_to_db(GameManager.Volume / 100.0)
	Playback.play_stream(preload('res://Assets/SFX/Button Click.ogg'), 0, 0, randf_range(0.9, 1.1))

func Play_Pressed() -> void:
	Player.volume_db = linear_to_db(GameManager.Volume / 100.0)
	Playback.play_stream(preload('res://Assets/SFX/Button Click.ogg'), 0, 0, randf_range(0.9, 1.1))
