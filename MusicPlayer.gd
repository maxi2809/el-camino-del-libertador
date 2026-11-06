# MusicPlayer.gd
# Autoload de música de fondo: vive fuera de las escenas, así que la
# banda sonora continúa ininterrumpida en todos los cambios de escena.
# No arranca sola: la inicia el splash al terminar (start_music), para
# no pisar el audio del logo de la presentación inicial.
extends Node

const TRACK_PATH := "res://song/BandaSonoraLibertadora.mp3"
const BASE_VOLUME_DB := -8.0

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = load(TRACK_PATH)
	if _player.stream is AudioStreamMP3:
		_player.stream.loop = true # La banda sonora repite en bucle
	_player.volume_db = BASE_VOLUME_DB
	add_child(_player)
	# Seguro: si se ejecuta una escena directamente (sin pasar por el splash),
	# la banda sonora arranca sola después de un rato.
	get_tree().create_timer(12.0).timeout.connect(func() -> void:
		if not _player.playing:
			start_music())

# Enciende la música con una entrada suave. La llama el splash
# justo antes de pasar al Login.
func start_music() -> void:
	if _player.playing:
		return
	_player.volume_db = -40.0
	_player.play()
	var tween := create_tween()
	tween.tween_property(_player, "volume_db", BASE_VOLUME_DB, 2.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func set_volume(db: float) -> void:
	_player.volume_db = db

func stop_music() -> void:
	_player.stop()
