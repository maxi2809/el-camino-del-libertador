# Level2Manager.gd
# Nivel 2 "Consejo del Saber": desafío histórico del Cruce de los Andes.
# Seis preguntas con devolución inmediata; al terminar, video del logro
# y el ascenso a CABO con la medalla en la pantalla de promoción.
extends Control

const POINTS_PER_CORRECT := 10
const IVORY := Color(0.949, 0.925, 0.859)
const GREEN := Color(0.45, 0.85, 0.45)
const RED := Color(0.95, 0.4, 0.35)

const QUESTIONS: Array[Dictionary] = [
	{
		"q": "¿Quién lideró el Ejército de los Andes en el cruce de la cordillera?",
		"opts": ["José de San Martín", "Bernardo O'Higgins", "Manuel Belgrano", "Martín Miguel de Güemes"],
		"ok": 0,
		"dato": "San Martín entrenó a sus granaderos en El Plumerillo, Mendoza.",
	},
	{
		"q": "¿En qué año comenzó el cruce de la cordillera de los Andes?",
		"opts": ["1810", "1816", "1817", "1821"],
		"ok": 2,
		"dato": "El grueso del Ejército inició el cruce en enero de 1817.",
	},
	{
		"q": "¿Desde qué provincia partió el Ejército de los Andes?",
		"opts": ["Córdoba", "Mendoza", "Salta", "Buenos Aires"],
		"ok": 1,
		"dato": "El campamento de El Plumerillo estaba en Mendoza.",
	},
	{
		"q": "¿Qué animales fueron clave para transportar cañones y víveres por la montaña?",
		"opts": ["Cabras y ovejas", "Llamas y vicuñas", "Mulas y caballos", "Bueyes y carretas"],
		"ok": 2,
		"dato": "Miles de mulas cargaron el equipaje por los pasos de Uspallata y Los Patos.",
	},
	{
		"q": "¿Qué batalla se libró en Chile el 12 de febrero de 1817, tras el cruce?",
		"opts": ["Batalla de Maipú", "Combate de San Lorenzo", "Batalla de Chacabuco", "Sitio de Montevideo"],
		"ok": 2,
		"dato": "Chacabuco fue la primera gran victoria del Ejército en Chile.",
	},
	{
		"q": "¿Cuál era el gran objetivo del plan continental de San Martín?",
		"opts": ["Liberar Chile y luego Perú del dominio realista", "Comerciar con las colonias del Pacífico", "Fundar una nueva capital en los Andes", "Conquistar el Alto Perú"],
		"ok": 0,
		"dato": "El objetivo era liberar Chile y llegar por mar al Perú.",
	},
]

var question_index := 0
var score := 0
var answered := false

var sb_normal: StyleBoxFlat
var sb_ok: StyleBoxFlat
var sb_wrong: StyleBoxFlat

@onready var progress_label: Label = $TopBar/ProgressLabel
@onready var score_label: Label = $TopBar/ScoreLabel
@onready var question_label: Label = $Center/VBoxContainer/QuestionLabel
@onready var options_box: VBoxContainer = $Center/VBoxContainer/OptionsBox
@onready var feedback_label: Label = $Center/VBoxContainer/FeedbackLabel
@onready var next_button: Button = $Center/VBoxContainer/NextButton
@onready var end_layer: CanvasLayer = $EndLayer

func _ready() -> void:
	sb_normal = _make_style(Color(0.1, 0.15, 0.28))
	sb_ok = _make_style(Color(0.16, 0.5, 0.3))
	sb_wrong = _make_style(Color(0.55, 0.2, 0.16))
	next_button.pressed.connect(_on_next)
	$EndLayer/Center/Panel/VBoxContainer/EndBtn.pressed.connect(_on_end)
	# El video del logro queda en bucle mientras el panel esté visible
	var vid: VideoStreamPlayer = $EndLayer/Center/Panel/VBoxContainer/LogroVideo
	vid.finished.connect(vid.play)
	_show_question()

func _make_style(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_border_width_all(2)
	sb.border_color = Color(0.851, 0.643, 0.255, 1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 18.0
	sb.content_margin_top = 10.0
	sb.content_margin_right = 18.0
	sb.content_margin_bottom = 10.0
	return sb

func _show_question() -> void:
	answered = false
	feedback_label.text = ""
	next_button.visible = false
	var data: Dictionary = QUESTIONS[question_index]
	progress_label.text = "Pregunta %d / %d" % [question_index + 1, QUESTIONS.size()]
	score_label.text = "Puntaje: %d" % score
	question_label.text = data["q"]
	for child in options_box.get_children():
		child.queue_free()
	var opts: Array = data["opts"]
	for i in opts.size():
		var btn := Button.new()
		btn.text = "%s)  %s" % [char(65 + i), opts[i]]
		btn.custom_minimum_size = Vector2(780, 54)
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", IVORY)
		btn.add_theme_color_override("font_hover_color", IVORY)
		btn.add_theme_color_override("font_pressed_color", IVORY)
		btn.add_theme_color_override("font_focus_color", IVORY)
		btn.add_theme_color_override("font_disabled_color", IVORY)
		btn.add_theme_stylebox_override("normal", sb_normal)
		btn.add_theme_stylebox_override("hover", sb_normal)
		btn.add_theme_stylebox_override("pressed", sb_normal)
		btn.add_theme_stylebox_override("disabled", sb_normal)
		btn.pressed.connect(_on_option.bind(i))
		options_box.add_child(btn)

func _on_option(index: int) -> void:
	if answered:
		return
	answered = true
	var data: Dictionary = QUESTIONS[question_index]
	var ok: int = data["ok"]
	var buttons := options_box.get_children()
	for i in buttons.size():
		var b: Button = buttons[i]
		b.disabled = true
		if i == ok:
			b.add_theme_stylebox_override("normal", sb_ok)
			b.add_theme_stylebox_override("hover", sb_ok)
			b.add_theme_stylebox_override("pressed", sb_ok)
			b.add_theme_stylebox_override("disabled", sb_ok)
		elif i == index:
			b.add_theme_stylebox_override("normal", sb_wrong)
			b.add_theme_stylebox_override("hover", sb_wrong)
			b.add_theme_stylebox_override("pressed", sb_wrong)
			b.add_theme_stylebox_override("disabled", sb_wrong)
		else:
			b.modulate = Color(1, 1, 1, 0.4)
	if index == ok:
		score += POINTS_PER_CORRECT
		score_label.text = "Puntaje: %d" % score
		feedback_label.add_theme_color_override("font_color", GREEN)
		feedback_label.text = "¡Correcto, granadero! %s" % data["dato"]
	else:
		feedback_label.add_theme_color_override("font_color", RED)
		feedback_label.text = "Casi... %s" % data["dato"]
	next_button.visible = true
	next_button.text = "Siguiente pregunta" if question_index < QUESTIONS.size() - 1 else "Ver mi ascenso"

func _on_next() -> void:
	question_index += 1
	if question_index < QUESTIONS.size():
		_show_question()
	else:
		_finish()

func _finish() -> void:
	end_layer.visible = true
	$EndLayer/Center/Panel/VBoxContainer/ScoreLabel.text = "Puntaje final: %d / %d" % [
		score, QUESTIONS.size() * POINTS_PER_CORRECT
	]
	$EndLayer/Center/Panel/VBoxContainer/LogroVideo.play()

func _on_end() -> void:
	GameManager.add_score(score)
	GameManager.completed_minigames += 1
	GameManager.check_promotion()
	get_tree().change_scene_to_file("res://scenes/LevelCompleteScreen.tscn")
