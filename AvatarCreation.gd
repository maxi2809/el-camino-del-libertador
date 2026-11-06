# AvatarCreation.gd
# Selección de personaje: 5 granaderos con uniforme de gala del GDD.
extends Control

const SKIN_COUNT := 5

var selected_skin_id: int = 0

@onready var skin_label: Label = $CenterContainer/VBoxContainer/ControlsRow/SkinLabel
@onready var preview_sprite: TextureRect = $CenterContainer/VBoxContainer/PreviewContainer/AvatarSprite

# Los 5 granaderos disponibles (arte oficial, uniforme completo)
const SKIN_TEXTURES: Array[String] = [
	"res://assets/gdd/avatar_skin_0.png",
	"res://assets/gdd/avatar_skin_1.png",
	"res://assets/gdd/avatar_skin_2.png",
	"res://assets/gdd/avatar_skin_3.png",
	"res://assets/gdd/avatar_skin_4.png",
]
const SKIN_NAMES: Array[String] = [
	"Castaño clásico",
	"Rizos del ejército",
	"Rubio cordillerano",
	"Pelirrojo valiente",
	"Granadero audaz",
]

func _ready() -> void:
	$CenterContainer/VBoxContainer/ControlsRow/NextSkinBtn.pressed.connect(_cycle_skin)
	$CenterContainer/VBoxContainer/ConfirmBtn.pressed.connect(_on_confirm)
	preview_sprite.texture = load(SKIN_TEXTURES[selected_skin_id])
	_update_labels()

func _cycle_skin() -> void:
	selected_skin_id = (selected_skin_id + 1) % SKIN_COUNT
	preview_sprite.texture = load(SKIN_TEXTURES[selected_skin_id])
	_update_labels()

func _update_labels() -> void:
	skin_label.text = "%s  (%d / %d)" % [
		SKIN_NAMES[selected_skin_id], selected_skin_id + 1, SKIN_COUNT
	]

func _on_confirm() -> void:
	UserData.avatar_skin = selected_skin_id
	get_tree().change_scene_to_file("res://scenes/IntroSanMartinDialogue.tscn")
