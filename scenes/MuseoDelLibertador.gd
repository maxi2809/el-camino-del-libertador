# MuseoDelLibertador.gd
# Meta final del GDD: el video de la entrega del diploma como
# protagonista, con el recorrido, el rango y las estadísticas por
# debajo, todo sobre el logo del juego de fondo.
extends Control

const MISSIONS_TOTAL := 4

@onready var recorrido_label: Label = $Margin/VBoxContainer/BottomRow/RecorridoBox/RecorridoLabel
@onready var rank_label: Label = $Margin/VBoxContainer/BottomRow/RangoBox/RankLabel
@onready var stats_label: Label = $Margin/VBoxContainer/BottomRow/StatsBox/StatsLabel
@onready var ceremony_label: Label = $Margin/VBoxContainer/CeremonyRow/CeremonyLabel
@onready var back_button: Button = $Margin/VBoxContainer/CeremonyRow/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	# Video de la entrega del diploma, en bucle
	var video: VideoStreamPlayer = $Margin/VBoxContainer/VideoArea/CeremonyVideo
	video.finished.connect(video.play)
	_fill_recorrido()
	_fill_rank()
	_fill_stats()
	_fill_ceremony()

func _fill_recorrido() -> void:
	var lines: Array[String] = []
	lines.append("✔ Campamento del Plumerillo — logística")
	if GameManager.completed_minigames >= 2:
		lines.append("✔ Consejo del Saber — historia")
	if GameManager.completed_minigames >= 3:
		lines.append("✔ Desafío de memoria histórica")
	for i in range(GameManager.completed_minigames + 1, MISSIONS_TOTAL + 1):
		lines.append("○ Misión %d: por escribirse en la historia" % i)
	recorrido_label.text = "\n".join(lines)

func _fill_rank() -> void:
	var rank_data: Dictionary = RankData.RANKS[GameManager.current_rank]
	rank_label.text = "%s\n%s\n%s" % [
		UserData.player_name,
		rank_data["title"],
		"⭐".repeat(rank_data["stars"]),
	]

func _fill_stats() -> void:
	stats_label.text = "Puntaje total: %d\nMisiones completadas: %d / %d" % [
		GameManager.total_score,
		GameManager.completed_minigames,
		MISSIONS_TOTAL,
	]

func _fill_ceremony() -> void:
	if GameManager.current_rank == RankData.RankType.GRANADERO_HONORARIO:
		ceremony_label.text = "¡Diploma y medalla entregados! Sos Granadero Honorario del Ejército de los Andes."
	else:
		ceremony_label.text = "El diploma de Granadero Honorario te espera al completar la campaña: cada decisión te acerca al ideal."

func _on_back_pressed() -> void:
	UserData.reset()
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/LoginUI.tscn")
