# Collectible.gd
# Suministro que cae desde arriba en el Nivel 1. Se atrapa acercando
# el avatar (el CatchArea del PlayerToken). Si toca el suelo avisa
# "missed" y el manager lo vuelve a encolar para que caiga más tarde.
extends Area2D

signal collected(item_name: String)
signal missed(item_name: String)

var item_name := "Suministro"
var fall_speed := 240.0
var falling := true
var _sway_time := 0.0

func setup(p_item_name: String, texture: Texture2D, p_speed: float) -> void:
	item_name = p_item_name
	fall_speed = p_speed
	$Icon.texture = texture
	$NameLabel.text = item_name

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_sway_time = randf() * TAU

func _process(delta: float) -> void:
	if not falling:
		return
	position.y += fall_speed * delta
	# Vaivén suave mientras cae (como si lo soltara al viento de la cordillera)
	_sway_time += delta * 2.2
	$Icon.rotation = sin(_sway_time) * 0.12
	if position.y > 680.0:
		falling = false
		missed.emit(item_name)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if not falling:
		return
	if area.is_in_group("player_catch"):
		falling = false
		collected.emit(item_name)
		queue_free()
