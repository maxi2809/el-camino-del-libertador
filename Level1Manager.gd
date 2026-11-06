# Level1Manager.gd
# Nivel 1 "Plumerillo": los suministros caen desde arriba en posiciones
# aleatorias y el avatar personalizado los atrapa moviéndose de lado a lado.
# Consigna: atrapar 5 de cada uno antes de que termine el tiempo.
# - Al conseguirlo: medalla + panel de victoria -> LevelCompleteScreen.
# - Si se acaba el tiempo: mensaje flotante que anima a jugar nuevamente.
extends Node2D

const CollectibleScene := preload("res://scenes/Collectible.tscn")
const GOLD := Color(0.851, 0.643, 0.255)
const RED := Color(0.9, 0.28, 0.22)

const ITEM_ICONS := {
	"Poncho Cordillerano": preload("res://assets/gdd/collect_poncho.png"),
	"Pólvora Seca": preload("res://assets/gdd/collect_polvora.png"),
	"Charqui": preload("res://assets/gdd/collect_charqui.png"),
}

@export var required_per_item: int = 5
@export var game_time: float = 90.0
@export var fall_speed_min: float = 200.0
@export var fall_speed_max: float = 330.0

var pool: Array[String] = []
var counts := {}
var time_left := 0.0
var active := false
var _spawn_accum := 0.0
var _spawn_interval := 1.0

@onready var hud: CanvasLayer = $HudLayer
@onready var collectibles: Node2D = $Collectibles
@onready var timer_label: Label = $HudLayer/TimerLabel
@onready var instruction_label: Label = $HudLayer/InstructionLabel
@onready var count_labels := {
	"Poncho Cordillerano": $HudLayer/TopBar/BadgePoncho/VBox/Count,
	"Pólvora Seca": $HudLayer/TopBar/BadgePolvora/VBox/Count,
	"Charqui": $HudLayer/TopBar/BadgeCharqui/VBox/Count,
}
@onready var win_layer: CanvasLayer = $WinLayer
@onready var fail_layer: CanvasLayer = $FailLayer

func _ready() -> void:
	time_left = game_time
	for item in ITEM_ICONS:
		counts[item] = 0
	_refill_pool()
	# El avatar usa el tono elegido en la creación de personaje
	$PlayerToken/Body.texture = load("res://assets/gdd/avatar_skin_%d.png" % UserData.avatar_skin)
	$WinLayer/Center/Panel/VBox/BtnContinue.pressed.connect(_on_continue)
	$FailLayer/Center/Panel/VBox/BtnRetry.pressed.connect(_on_retry)
	# El video del logro se reproduce en bucle mientras el panel esté visible
	var logro_video: VideoStreamPlayer = $WinLayer/Center/Panel/VBox/LogroVideo
	logro_video.finished.connect(logro_video.play)
	_update_hud()
	_update_timer_label()
	active = true
	_fade_instruction()

func _process(delta: float) -> void:
	if not active:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_update_timer_label()
		_lose()
		return
	_update_timer_label()
	# Aparición de suministros desde la parte superior, en x aleatoria
	_spawn_accum += delta
	if _spawn_accum >= _spawn_interval and pool.size() > 0:
		_spawn_accum = 0.0
		_spawn_interval = randf_range(0.7, 1.3)
		_spawn_next()

func _refill_pool() -> void:
	pool.clear()
	for item in ITEM_ICONS:
		for i in required_per_item:
			pool.append(item)
	pool.shuffle()

func _spawn_next() -> void:
	var item_name: String = pool.pop_back()
	var c := CollectibleScene.instantiate()
	c.position = Vector2(randf_range(100.0, 1180.0), -80.0)
	c.setup(item_name, ITEM_ICONS[item_name], randf_range(fall_speed_min, fall_speed_max))
	# CONNECT_DEFERRED: el procesamiento corre fuera del flush de física
	c.collected.connect(_on_collectible_caught, CONNECT_DEFERRED)
	c.missed.connect(_on_collectible_missed, CONNECT_DEFERRED)
	collectibles.add_child(c)

func _on_collectible_caught(item_name: String) -> void:
	if not active:
		return
	counts[item_name] = int(counts[item_name]) + 1
	_update_hud()
	if has_node("PlayerToken"):
		$PlayerToken.celebrate()
		_spawn_float_label(item_name)
	if _total_collected() == required_per_item * ITEM_ICONS.size():
		_win()

func _on_collectible_missed(item_name: String) -> void:
	if not active:
		return
	pool.push_front(item_name)  # el ítem perdido vuelve a caer más tarde

func _total_collected() -> int:
	var total := 0
	for item in counts:
		total += int(counts[item])
	return total

func _update_hud() -> void:
	for item in count_labels:
		count_labels[item].text = "%d / %d" % [int(counts[item]), required_per_item]

func _update_timer_label() -> void:
	timer_label.text = "Tiempo: %d s" % ceili(time_left)
	if time_left <= 15.0 and active:
		timer_label.add_theme_color_override("font_color", RED)
	else:
		timer_label.add_theme_color_override("font_color", GOLD)

func _spawn_float_label(item_name: String) -> void:
	# "+1 Poncho Cordillerano" flotando sobre el avatar al atrapar
	var lbl := Label.new()
	lbl.text = "+1 %s" % item_name
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", GOLD)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.position = $PlayerToken.position + Vector2(-80.0, -320.0)
	hud.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 60.0, 1.1) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.1).set_delay(0.3)
	tw.tween_callback(lbl.queue_free)

func _freeze_gameplay() -> void:
	active = false
	$PlayerToken.controls_enabled = false
	for c in collectibles.get_children():
		c.falling = false

func _win() -> void:
	_freeze_gameplay()
	win_layer.visible = true
	# Reproduce el video del logro obtenido (queda en bucle, ver _ready)
	$WinLayer/Center/Panel/VBox/LogroVideo.play()

func _lose() -> void:
	_freeze_gameplay()
	fail_layer.visible = true
	# Mensaje flotante: pulso suave del texto motivador
	var msg: Label = $FailLayer/Center/Panel/VBox/Msg
	var tw := create_tween().set_loops()
	tw.tween_property(msg, "modulate:a", 0.55, 0.65) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(msg, "modulate:a", 1.0, 0.65) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_continue() -> void:
	GameManager.completed_minigames += 1
	GameManager.check_promotion()
	get_tree().change_scene_to_file("res://scenes/LevelCompleteScreen.tscn")

func _on_retry() -> void:
	get_tree().reload_current_scene()

func _fade_instruction() -> void:
	var tw := create_tween()
	tw.tween_interval(6.0)
	tw.tween_property(instruction_label, "modulate:a", 0.0, 1.0)
