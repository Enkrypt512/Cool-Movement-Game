extends Node

var Player: AudioStreamPlayer
var Playback: AudioStreamPlaybackPolyphonic
var Button_Sound_Effect = preload("res://Assets/SFX/Button Click.ogg")

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Player = AudioStreamPlayer.new()
	Player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(Player)
	var Stream = AudioStreamPolyphonic.new()
	Stream.polyphony = 32
	Player.stream = Stream
	Player.play()
	Playback = Player.get_stream_playback()
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Button:
		if !node.mouse_entered.is_connected(Play_Sound_Effect):
			node.mouse_entered.connect(Play_Sound_Effect)
		if !node.pressed.is_connected(Play_Sound_Effect):
			node.pressed.connect(Play_Sound_Effect)

func Play_Sound_Effect() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	if Playback:
		Player.volume_db = linear_to_db(GameManager.Volume / 100.0)
		Playback.play_stream(Button_Sound_Effect, 0, 0, randf_range(0.9, 1.1))
