# LevelCompleteScreen.gd
# Muestra la promoción de rango con el retrato oficial del GDD y la
# medalla del reconocimiento, y el acceso a la siguiente misión o al Museo.
extends Control

const RANK_PORTRAITS := {
	RankData.RankType.RECLUTA: "res://assets/gdd/rank_recluta.png",
	RankData.RankType.SOLDADO: "res://assets/gdd/rank_soldado.png",
	RankData.RankType.CABO: "res://assets/gdd/rank_cabo.png",
	RankData.RankType.SARGENTO: "res://assets/gdd/rank_sargento.png",
	RankData.RankType.GRANADERO_HONORARIO: "res://assets/gdd/rank_granadero.png",
}

@onready var congrats_label: Label = $CenterContainer/VBoxContainer/CongratsLabel
@onready var rank_label: Label = $CenterContainer/VBoxContainer/RankLabel
@onready var rank_portrait: TextureRect = $CenterContainer/VBoxContainer/PortraitRow/RankPortrait
@onready var next_button: Button = $CenterContainer/VBoxContainer/NextButton

func _ready() -> void:
	next_button.pressed.connect(_on_next_pressed)
	_show_current_rank()

func _show_current_rank() -> void:
	var rank_data: Dictionary = RankData.RANKS[GameManager.current_rank]
	var stars: String = "⭐".repeat(rank_data["stars"])
	rank_label.text = "%s\n%s\n%s" % [
		UserData.player_name,
		rank_data["title"],
		stars,
	]
	if RANK_PORTRAITS.has(GameManager.current_rank):
		rank_portrait.texture = load(RANK_PORTRAITS[GameManager.current_rank])
		rank_portrait.custom_minimum_size = Vector2(300, 392)

	if GameManager.completed_minigames == 1:
		# Queda pendiente el Consejo del Saber (nivel 2)
		congrats_label.text = "¡Ascenso obtenido por servicio distinguido!"
		next_button.text = "Ir a la siguiente misión"
		next_button.disabled = false
	elif GameManager.completed_minigames == 2:
		# Queda pendiente el desafío de memoria histórica
		congrats_label.text = "¡Ascenso obtenido por servicio distinguido!"
		next_button.text = "Ir al desafío de memoria histórica"
		next_button.disabled = false
	else:
		# No quedan misiones en la demo: el destino es el Museo
		congrats_label.text = "¡Campaña completada por ahora!"
		next_button.text = "Visitar el Museo del Libertador"
		next_button.disabled = false

func _on_next_pressed() -> void:
	match GameManager.completed_minigames:
		1:
			get_tree().change_scene_to_file("res://scenes/Level2_Consejo.tscn")
		2:
			get_tree().change_scene_to_file("res://minigames/memory_challenge/Main.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/MuseoDelLibertador.tscn")
