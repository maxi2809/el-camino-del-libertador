# Splash.gd
# Pantalla de apertura de la marca (Vela Studios). Los tiempos de la
# animación se sincronizan con la duración real del audio del logo:
# fade-in del emblema, se mantiene mientras suena, fade-out al final.
# Cualquier tecla o clic salta la secuencia.
extends Control

const NEXT_SCENE := "res://scenes/LoginUI.tscn"
const FADE_IN := 1.2
const FADE_OUT := 1.2
const MIN_HOLD := 2.0
const MAX_HOLD := 10.0

var _finished := false

@onready var content: Control = $CenterContainer
@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	content.modulate.a = 0.0
	content.scale = Vector2(0.92, 0.92)
	content.pivot_offset = get_viewport_rect().size / 2.0

	# El splash dura lo que el audio: se mantiene hasta que el sting
	# está por terminar, y recién entonces hace el fade-out.
	var track_len: float = music.stream.get_length()
	var hold := clampf(track_len - FADE_IN - FADE_OUT - 0.5, MIN_HOLD, MAX_HOLD)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(content, "modulate:a", 1.0, FADE_IN) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(content, "scale", Vector2.ONE, FADE_IN + hold * 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.chain().tween_interval(hold)
	tween.chain().tween_property(self, "modulate:a", 0.0, FADE_OUT) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(_go_next)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			_go_next()

func _go_next() -> void:
	if _finished:
		return
	_finished = true
	# Fade-out del sting y recién al entrar al Login arranca la banda sonora,
	# para que el audio del logo se escuche limpio.
	var tween := create_tween()
	tween.tween_property(music, "volume_db", -40.0, 0.4)
	tween.tween_callback(func() -> void:
		MusicPlayer.start_music()
		get_tree().change_scene_to_file(NEXT_SCENE))
