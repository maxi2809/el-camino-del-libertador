# IntroSanMartinDialogue.gd
extends Control

@onready var speaker_name_label: Label = $DialogueBox/VBoxContainer/SpeakerName
@onready var dialogue_text_label: Label = $DialogueBox/VBoxContainer/DialogueText
@onready var continue_button: Button = $DialogueBox/VBoxContainer/ContinueButton
@onready var portrait: TextureRect = $PortraitGeneral
@onready var player_portrait: TextureRect = $PlayerPortrait

var dialogue_sequence: Array[Dictionary] = []
var current_index: int = 0

var _idle_time := 0.0

func _ready() -> void:
	dialogue_sequence = [
		{
			"speaker": "General José de San Martín",
			"text": "Bienvenido al campamento del Plumerillo, " + UserData.player_name + ". Nos aguarda una travesía titánica a través de la Cordillera de los Andes."
		},
		{
			"speaker": UserData.player_name + " (Recluta)",
			"text": "¡A sus órdenes, General! Estoy listo para contribuir a la causa de la libertad."
		},
		{
			"speaker": "General José de San Martín",
			"text": "La valentía es imprescindible, pero la victoria se construye con estrategia, observación e ingenio. Tu primera misión será asegurar la logística del campamento."
		}
	]
	
	continue_button.pressed.connect(_advance_dialogue)
	# El retrato del jugador refleja el tono elegido en la creación de avatar
	player_portrait.texture = load("res://assets/gdd/avatar_skin_%d.png" % UserData.avatar_skin)
	_show_current_dialogue()
	_start_portrait_presentation()

# Presentación de los retratos: entran con fade y desplazamiento lateral.
func _start_portrait_presentation() -> void:
	portrait.pivot_offset = portrait.size / 2.0
	portrait.position.x += 60.0
	portrait.self_modulate.a = 0.0
	player_portrait.pivot_offset = player_portrait.size / 2.0
	player_portrait.position.x -= 60.0
	player_portrait.self_modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(portrait, "self_modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(portrait, "position:x", portrait.position.x - 60.0, 0.9) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_portrait, "self_modulate:a", 1.0, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_portrait, "position:x", player_portrait.position.x + 60.0, 0.9) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_idle_time += delta
	# Respiración sutil del general (presente durante todo el diálogo)
	portrait.scale = Vector2.ONE * (1.0 + sin(_idle_time * 1.6) * 0.006)
	# Trote del caballo del jugador: rebote más marcado, como jinete en movimiento
	player_portrait.position.y = sin(_idle_time * 5.0) * 5.0
	player_portrait.scale = Vector2.ONE * (1.0 + sin(_idle_time * 5.0 + 0.6) * 0.01)

func _show_current_dialogue() -> void:
	var current_data = dialogue_sequence[current_index]
	var speaker: String = current_data["speaker"]
	speaker_name_label.text = speaker
	dialogue_text_label.text = current_data["text"]
	_focus_speaker(not speaker.contains("San Martín"))

# El hablante queda en primer plano; el otro se atenúa para que se
# entienda visualmente quién responde.
func _focus_speaker(player_talking: bool) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(portrait, "modulate:a", 0.45 if player_talking else 1.0, 0.3)
	tween.tween_property(player_portrait, "modulate:a", 1.0 if player_talking else 0.45, 0.3)

func _advance_dialogue() -> void:
	current_index += 1
	if current_index < dialogue_sequence.size():
		_show_current_dialogue()
	else:
		get_tree().change_scene_to_file("res://scenes/Level1_Plumerillo.tscn")
