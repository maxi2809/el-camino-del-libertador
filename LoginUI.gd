# LoginUI.gd
extends Control

@onready var username_input: LineEdit = $VBoxContainer/UsernameInput
@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	# Enter en el campo de texto también inicia la aventura
	username_input.text_submitted.connect(func(_text: String) -> void:
		_on_start_pressed())

func _on_start_pressed() -> void:
	var player_name = username_input.text.strip_edges()
	if player_name != "":
		UserData.player_name = player_name
	else:
		UserData.player_name = "Recluta"
	
	get_tree().change_scene_to_file("res://scenes/AvatarCreation.tscn")
