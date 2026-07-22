extends Control

@onready var Player: CharacterBody3D = $".."
@onready var Health_Bar: ProgressBar = $"Health Bar"

func _ready() -> void:
	var Style_Box:StyleBoxFlat = StyleBoxFlat.new()
	Style_Box.bg_color = Color(1.0, 0.0, 0.0, 1.0)
	Health_Bar.add_theme_stylebox_override("fill", Style_Box)

func _process(_delta: float) -> void:
	Health_Bar.value = Player.Health
