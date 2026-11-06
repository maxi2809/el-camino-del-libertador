# GameManager.gd
extends Node

var current_rank: RankData.RankType = RankData.RankType.RECLUTA
var completed_minigames: int = 0
var total_score: int = 0 # Puntaje acumulado de todos los minijuegos (Museo)

signal rank_promoted(new_rank: RankData.RankType)

func check_promotion() -> void:
	match completed_minigames:
		1: promote_to(RankData.RankType.SOLDADO)
		2: promote_to(RankData.RankType.CABO)
		3: promote_to(RankData.RankType.SARGENTO)
		4: promote_to(RankData.RankType.GRANADERO_HONORARIO)

func promote_to(new_rank: RankData.RankType) -> void:
	if new_rank > current_rank:
		current_rank = new_rank
		rank_promoted.emit(current_rank)

func add_score(points: int) -> void:
	total_score += points

# Reinicia la campaña para volver a empezar desde el Login.
func reset() -> void:
	current_rank = RankData.RankType.RECLUTA
	completed_minigames = 0
	total_score = 0
