# main.gd
# Desafío de Memoria de los Exploradores (minijuego 2 del Ejército de los Andes).
extends Control

const CARD_SCENE := preload("res://minigames/memory_challenge/Card.tscn")
const CARD_ASSETS_DIR := "res://assets/gdd/cards"
const CARD_BACKS_DIR := "res://assets/gdd/cards_backs"

@onready var score_label = $TopBar/HBoxContainer/ScoreLabel
@onready var time_label = $TopBar/HBoxContainer/TimeLabel
@onready var timer = $Timer
@onready var grid = $CenterContainer/GridContainer

var score = 0
var time_left = 60

var selected_cards = []
var board_locked = false # Evita clics extra mientras se resuelve una pareja
var _last_score := -1 # Para animar el puntaje solo cuando cambia

var icons = [
	"mapa", "mapa",
	"brujula", "brujula",
	"pergamino", "pergamino",
	"medalla", "medalla",
	"carta", "carta",
	"granaderos", "granaderos",
	"andes", "andes",
	"ciudad", "ciudad",
]

func _ready():
	icons.shuffle()
	create_board()
	update_ui()

func create_board():
	for i in icons.size():
		var icon_name: String = icons[i]
		var card = CARD_SCENE.instantiate()
		grid.add_child(card)

		var front = load("%s/%s.png" % [CARD_ASSETS_DIR, icon_name])
		# Cada reverso es una ficha del mosaico del logo (4x4):
		# al armar el tablero completo, se reconstruye la marca del juego.
		var back = load("%s/back_tile_%d.png" % [CARD_BACKS_DIR, i])

		card.card_selected.connect(on_card_selected)
		card.setup(icon_name, front, back)

func on_card_selected(card):
	# Ignorar/revertir clics mientras se resuelve una pareja (durante el await de 1 s)
	if board_locked:
		card.show_back()
		return

	if selected_cards.size() >= 2:
		card.show_back() # Devuelve al reverso la carta clickeada de más
		return

	selected_cards.append(card)

	if selected_cards.size() == 2:
		board_locked = true
		await get_tree().create_timer(1.0).timeout
		check_match()

func check_match():
	var card_a = selected_cards[0]
	var card_b = selected_cards[1]

	if card_a.icon_name == card_b.icon_name:
		card_a.matched = true
		card_b.matched = true

		score += 100
		update_ui()

		print("Pareja encontrada")

	else:
		card_a.show_back()
		card_b.show_back()

	selected_cards.clear()
	board_locked = false

	check_win()

func check_win():
	for card in grid.get_children():
		if !card.matched:
			return

	victory_screen()

func update_ui():
	score_label.text = "Puntos: " + str(score)
	time_label.text = "Tiempo: " + str(time_left)

	# Puntaje "salta" al actualizar para dar feedback llamativo (solo si cambió)
	if score != _last_score:
		_last_score = score
		score_label.pivot_offset = score_label.size / 2.0
		score_label.scale = Vector2.ONE * 1.25
		var tween := create_tween()
		tween.tween_property(score_label, "scale", Vector2.ONE, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Últimos 10 segundos: el tiempo se vuelve rojo y late
	if time_left <= 10:
		time_label.add_theme_color_override("font_color", Color(0.94, 0.32, 0.28))
		time_label.pivot_offset = time_label.size / 2.0
		time_label.scale = Vector2.ONE * 1.15
		var tw := create_tween()
		tw.tween_property(time_label, "scale", Vector2.ONE, 0.25) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		time_label.add_theme_color_override("font_color", Color(0.94902, 0.92549, 0.858824))

func _on_timer_timeout():
	time_left -= 1
	update_ui()

	if time_left <= 0:
		timer.stop()
		game_over()

func game_over():
	var panel = AcceptDialog.new()
	panel.title = "Fin del Juego"
	panel.dialog_text = "Se acabó el tiempo. Puntaje final: %d" % score
	panel.ok_button_text = "Reintentar"
	add_child(panel)
	panel.confirmed.connect(_on_game_over_confirmed)
	panel.popup_centered()

func _on_game_over_confirmed() -> void:
	# Reintenta el desafío desde cero
	get_tree().reload_current_scene()

func victory_screen():
	timer.stop()

	var bonus = time_left * 10

	score += bonus

	update_ui()

	# Registra el minijuego completado, el puntaje y verifica la promoción
	GameManager.completed_minigames += 1
	GameManager.add_score(score)
	GameManager.check_promotion()

	var panel = AcceptDialog.new()
	panel.title = "Victoria"
	panel.dialog_text = \
		"¡Ganaste!\n\n" + \
		"Puntaje: " + str(score) + "\n" + \
		"Tiempo restante: " + str(time_left)
	add_child(panel)
	panel.confirmed.connect(_on_victory_confirmed)
	panel.popup_centered()

func _on_victory_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/LevelCompleteScreen.tscn")
